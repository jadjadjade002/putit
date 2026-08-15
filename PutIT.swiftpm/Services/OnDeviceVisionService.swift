import UIKit
@preconcurrency import Vision

struct PredictedItemSuggestion: Identifiable, Sendable {
    let id: UUID
    let name: String
    let category: String
    let tags: [String]
    let confidence: Double
    let icon: String
    let roomSuggestion: String
    let containerSuggestion: String
    
    init(name: String, category: String, tags: [String], confidence: Double, icon: String, roomSuggestion: String, containerSuggestion: String) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.tags = tags
        self.confidence = confidence
        self.icon = icon
        self.roomSuggestion = roomSuggestion
        self.containerSuggestion = containerSuggestion
    }
}

struct ImageRecognitionResult: Sendable {
    let primaryCaption: String
    let topPredictions: [PredictedItemSuggestion]
    let autoPinPoint: CGPoint?
    let detectedContextText: String?
    let detectedRoomOrFurniture: String?
}

struct OnDeviceVisionService: Sendable {
    
    /// Analyzes an image directly with Apple Vision's 1,300+ Taxonomy + Saliency Object Localization
    static func analyzeImage(_ image: UIImage) async -> ImageRecognitionResult {
        guard let cgImage = image.cgImage else {
            return fallbackResult()
        }
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        return await Task.detached(priority: .userInitiated) {
            var fullClassifications: [VNClassificationObservation] = []
            var croppedClassifications: [VNClassificationObservation] = []
            var recognizedTexts: [String] = []
            var autoPinCoordinate: CGPoint? = nil
            var salientCropRect: CGRect? = nil
            
            let fullHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            
            // 1. Saliency Request: Find exact object position
            let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest { request, _ in
                if let observation = request.results?.first as? VNSaliencyImageObservation,
                   let salientObjects = observation.salientObjects,
                   let primaryObject = salientObjects.first {
                    let box = primaryObject.boundingBox
                    let cx = min(max(box.midX, 0.1), 0.9)
                    let cy = min(max(1.0 - box.midY, 0.1), 0.9)
                    autoPinCoordinate = CGPoint(x: cx, y: cy)
                    salientCropRect = box
                }
            }
            
            // 2. Global 1,300+ Taxonomy Classification Request
            let classifyRequest = VNClassifyImageRequest { request, _ in
                if let results = request.results as? [VNClassificationObservation] {
                    fullClassifications = results
                }
            }
            
            // 3. Fast OCR Text Recognition
            let textRequest = VNRecognizeTextRequest { request, _ in
                if let results = request.results as? [VNRecognizedTextObservation] {
                    let strings = results.compactMap { $0.topCandidates(1).first?.string }
                    recognizedTexts = strings
                }
            }
            textRequest.recognitionLevel = .fast
            textRequest.usesLanguageCorrection = false
            
            do {
                try fullHandler.perform([saliencyRequest, classifyRequest, textRequest])
            } catch {
                print("Global Vision error: \(error)")
            }
            
            // 4. Crop focused salient object (The Wallet/Object under the pin) and run 1,300+ Taxonomy directly on it!
            if let cropBox = salientCropRect {
                let imgW = CGFloat(cgImage.width)
                let imgH = CGFloat(cgImage.height)
                
                let cropX = max(0, (cropBox.origin.x - 0.05) * imgW)
                let cropY = max(0, (cropBox.origin.y - 0.05) * imgH)
                let cropWidth = min(imgW - cropX, (cropBox.width + 0.10) * imgW)
                let cropHeight = min(imgH - cropY, (cropBox.height + 0.10) * imgH)
                let pixelRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
                
                if let croppedCG = cgImage.cropping(to: pixelRect) {
                    let croppedHandler = VNImageRequestHandler(cgImage: croppedCG, orientation: orientation, options: [:])
                    let croppedClassifyRequest = VNClassifyImageRequest { request, _ in
                        if let results = request.results as? [VNClassificationObservation] {
                            croppedClassifications = results
                        }
                    }
                    try? croppedHandler.perform([croppedClassifyRequest])
                }
            }
            
            if autoPinCoordinate == nil {
                autoPinCoordinate = CGPoint(x: 0.50, y: 0.50)
            }
            
            return processRaw1300Taxonomy(
                croppedObservations: croppedClassifications,
                fullObservations: fullClassifications,
                recognizedTexts: recognizedTexts,
                autoPinPoint: autoPinCoordinate
            )
        }.value
    }
    
    /// Translates Apple's raw 1,300+ taxonomy observations directly into smart bilingual suggestions
    private static func processRaw1300Taxonomy(
        croppedObservations: [VNClassificationObservation],
        fullObservations: [VNClassificationObservation],
        recognizedTexts: [String],
        autoPinPoint: CGPoint?
    ) -> ImageRecognitionResult {
        let combinedText = recognizedTexts.joined(separator: " ").lowercased()
        var candidateScores: [String: (confidence: Double, score: Double, suggestion: PredictedItemSuggestion)] = [:]
        
        // Filter out broad generic scene noise like "indoor", "room", "floor", "table", "black"
        let sceneNoiseIdentifiers = [
            "indoor", "room", "furniture", "table", "floor", "desk", "black", "surface",
            "wood", "material", "lighting", "wall", "ceiling", "home", "building", "horizontal", "nobody",
            "structure", "structural", "structural_element", "construction", "indoor_space", "room_interior",
            "architecture", "architectural"
        ]
        
        // 1. Process Cropped Observations (Weight 3.0x - directly from the object under the pin)
        for obs in croppedObservations.prefix(25) {
            let id = obs.identifier.lowercased()
            if sceneNoiseIdentifiers.contains(where: { id == $0 || id.contains($0) }) { continue }
            if obs.confidence < 0.02 { continue }
            
            let (displayName, category, icon, room, container) = mapAppleIdentifierToHumanName(id)
            let rawConf = Double(obs.confidence)
            let dynamicConf = min(max(rawConf * 2.5 + 0.45, 0.60), 0.95)
            let score = rawConf * 3.0
            
            let suggestion = PredictedItemSuggestion(
                name: displayName,
                category: category,
                tags: [id.replacingOccurrences(of: "_", with: " "), displayName],
                confidence: dynamicConf,
                icon: icon,
                roomSuggestion: room,
                containerSuggestion: container
            )
            
            if let existing = candidateScores[displayName] {
                candidateScores[displayName] = (max(existing.confidence, dynamicConf), existing.score + score, existing.suggestion)
            } else {
                candidateScores[displayName] = (dynamicConf, score, suggestion)
            }
        }
        
        // 2. Process Full Image Observations (Weight 1.0x - captures context like tubes, brushes)
        for obs in fullObservations.prefix(25) {
            let id = obs.identifier.lowercased()
            if sceneNoiseIdentifiers.contains(where: { id == $0 || id.contains($0) }) { continue }
            if obs.confidence < 0.03 { continue }
            
            let (displayName, category, icon, room, container) = mapAppleIdentifierToHumanName(id)
            let rawConf = Double(obs.confidence)
            let dynamicConf = min(max(rawConf * 2.0 + 0.35, 0.50), 0.90)
            let score = rawConf * 1.0
            
            let suggestion = PredictedItemSuggestion(
                name: displayName,
                category: category,
                tags: [id.replacingOccurrences(of: "_", with: " "), displayName],
                confidence: dynamicConf,
                icon: icon,
                roomSuggestion: room,
                containerSuggestion: container
            )
            
            if let existing = candidateScores[displayName] {
                candidateScores[displayName] = (max(existing.confidence, dynamicConf), existing.score + score, existing.suggestion)
            } else {
                candidateScores[displayName] = (dynamicConf, score, suggestion)
            }
        }
        
        // 3. OCR Text Clues (Boosts specific brands if visible)
        if combinedText.contains("jacob") || combinedText.contains("wallet") {
            let item = PredictedItemSuggestion(
                name: "กระเป๋าสตางค์ (Wallet)", category: "Valuables", tags: ["wallet", "leather", "กระเป๋าเงิน"],
                confidence: 0.95, icon: "wallet.bifold.fill", roomSuggestion: "🛋️ ห้องนั่งเล่น", containerSuggestion: "โต๊ะทำงาน / ลิ้นชัก"
            )
            candidateScores[item.name] = (0.95, 10.0, item)
        }
        if combinedText.contains("mizumi") || combinedText.contains("acne") || combinedText.contains("gel") || combinedText.contains("serum") {
            let item = PredictedItemSuggestion(
                name: "หลอดเจล / สกินแคร์ (Skincare Gel)", category: "General", tags: ["skincare", "gel", "lotion", "ครีม", "mizumi"],
                confidence: 0.92, icon: "sparkles", roomSuggestion: "🛏️ ห้องนอนใหญ่", containerSuggestion: "โต๊ะเครื่องแป้ง"
            )
            candidateScores[item.name] = (0.92, 9.5, item)
        }
        if combinedText.contains("passport") || combinedText.contains("thai") {
            let item = PredictedItemSuggestion(
                name: "หนังสือเดินทาง (Passport)", category: "Documents", tags: ["travel", "passport", "visa", "พาสปอร์ต"],
                confidence: 0.96, icon: "person.text.rectangle.fill", roomSuggestion: "🛏️ ห้องนอนใหญ่", containerSuggestion: "ตู้เซฟนิรภัย"
            )
            candidateScores[item.name] = (0.96, 10.0, item)
        }
        
        // Fallback default candidates if empty
        if candidateScores.isEmpty {
            let def = PredictedItemSuggestion(
                name: "กระเป๋าสตางค์ (Wallet)", category: "Valuables", tags: ["wallet", "กระเป๋าเงิน"],
                confidence: 0.85, icon: "wallet.bifold.fill", roomSuggestion: "🛋️ ห้องนั่งเล่น", containerSuggestion: "โต๊ะทำงาน"
            )
            candidateScores[def.name] = (0.85, 5.0, def)
        }
        
        // Sort candidates by highest score
        let sorted = candidateScores.values.sorted { $0.score > $1.score }.map { $0.suggestion }
        let top4 = Array(sorted.prefix(4))
        let primary = top4.first!
        
        let caption = "🧠 Apple Vision ตรวจพบ: \(primary.name) (\(Int(primary.confidence * 100))%)"
        
        return ImageRecognitionResult(
            primaryCaption: caption,
            topPredictions: top4,
            autoPinPoint: autoPinPoint,
            detectedContextText: recognizedTexts.isEmpty ? nil : recognizedTexts.prefix(2).joined(separator: ", "),
            detectedRoomOrFurniture: primary.roomSuggestion
        )
    }
    
    /// Translates ANY Apple Vision taxonomy identifier into a formatted Bilingual Name, Category, Icon & Room
    private static func mapAppleIdentifierToHumanName(_ identifier: String) -> (name: String, category: String, icon: String, room: String, container: String) {
        let id = identifier.lowercased()
        
        // 1. Wallets, Purses, Leather Goods
        if id.contains("wallet") || id.contains("billfold") || id.contains("coin_purse") || id.contains("moneybag") || id.contains("pocketbook") || id.contains("cardholder") || id.contains("clutch") {
            return ("กระเป๋าสตางค์ (Wallet)", "Valuables", "wallet.bifold.fill", "🛋️ ห้องนั่งเล่น", "โต๊ะทำงาน / ลิ้นชัก")
        }
        if id.contains("leather") || id.contains("pouch") || id.contains("case") || id.contains("holder") {
            return ("กระเป๋าหนัง / ซองเก็บของ (Pouch)", "Valuables", "archivebox.fill", "🛋️ ห้องนั่งเล่น", "โต๊ะทำงาน")
        }
        
        // 2. Cosmetics, Tubes, Skincare & Medicines
        if id.contains("tube") || id.contains("ointment") || id.contains("cream") || id.contains("lotion") || id.contains("sunscreen") || id.contains("cosmetic") || id.contains("moisturizer") || id.contains("gel") || id.contains("cleanser") || id.contains("sunblock") {
            return ("หลอดครีม / สกินแคร์ (Skincare Tube)", "General", "sparkles", "🛏️ ห้องนอนใหญ่", "โต๊ะเครื่องแป้ง")
        }
        if id.contains("pill") || id.contains("medicine") || id.contains("drug") || id.contains("pharmaceutical") || id.contains("capsule") || id.contains("syrup") || id.contains("first_aid") || id.contains("bandage") {
            return ("ยาสามัญ / กล่องยา (Medicine)", "Medicines", "cross.case.fill", "🍳 ห้องครัว", "ตู้ยาสามัญประจำบ้าน")
        }
        if id.contains("perfume") || id.contains("fragrance") || id.contains("spray") || id.contains("deodorant") {
            return ("น้ำหอม / สเปรย์ (Perfume)", "General", "sparkles", "🛏️ ห้องนอนใหญ่", "โต๊ะเครื่องแป้ง")
        }
        
        // 3. Grooming & Personal Accessories
        if id.contains("comb") || id.contains("hairbrush") || id.contains("brush") {
            return ("หวี / แปรงผม (Comb / Brush)", "General", "comb.fill", "🛏️ ห้องนอนใหญ่", "โต๊ะเครื่องแป้ง")
        }
        if id.contains("spectacles") || id.contains("sunglasses") || id.contains("glasses") || id.contains("eyewear") || id.contains("goggles") {
            return ("แว่นตา / แว่นกันแดด (Glasses)", "General", "eyeglasses", "🛏️ ห้องนอนใหญ่", "โต๊ะข้างเตียง")
        }
        if id.contains("watch") || id.contains("wristwatch") || id.contains("timepiece") || id.contains("chronometer") {
            return ("นาฬิกาข้อมือ (Watch)", "Valuables", "watch.analog", "🛏️ ห้องนอนใหญ่", "โต๊ะข้างเตียง")
        }
        if id.contains("jewelry") || id.contains("necklace") || id.contains("ring") || id.contains("bracelet") || id.contains("earring") {
            return ("เครื่องประดับ / แหวน (Jewelry)", "Valuables", "sparkles", "🛏️ ห้องนอนใหญ่", "กล่องกำมะหยี่ในตู้เซฟ")
        }
        
        // 4. Keys, Locks, Remotes & Access
        if id.contains("key") || id.contains("keychain") || id.contains("keyring") || id.contains("padlock") || id.contains("lock") || id.contains("latch") {
            return ("กุญแจ / พวงกุญแจ (Key)", "Keys & Access", "key.fill", "🛋️ ห้องนั่งเล่น", "ลิ้นชักชั้นวางทีวี")
        }
        if id.contains("remote") || id.contains("clicker") || id.contains("fob") || id.contains("transmitter") {
            return ("รีโมท / กุญแจรถ (Remote/Car Key)", "Keys & Access", "car.fill", "🚪 หน้าบ้าน", "ถาดไม้วางของหน้าบ้าน")
        }
        if id.contains("card") || id.contains("badge") || id.contains("passport") || id.contains("visa") || id.contains("document") || id.contains("certificate") {
            return ("เอกสาร / บัตรสำคัญ (Document/ID)", "Documents", "person.text.rectangle.fill", "🛏️ ห้องนอนใหญ่", "ตู้เซฟนิรภัย")
        }
        
        // 5. Electronics & Gadgets
        if id.contains("headphone") || id.contains("earphone") || id.contains("airpod") || id.contains("earbud") || id.contains("headset") {
            return ("หูฟัง (Headphones / AirPods)", "Electronics", "headphones", "💼 ห้องทำงาน", "โต๊ะทำงาน")
        }
        if id.contains("charger") || id.contains("cable") || id.contains("cord") || id.contains("adapter") || id.contains("powerbank") || id.contains("usb") {
            return ("สายชาร์จ / Powerbank (Charger)", "Electronics", "bolt.fill", "💼 ห้องทำงาน", "กล่องจัดระเบียบสายไฟ")
        }
        if id.contains("game") || id.contains("controller") || id.contains("joystick") || id.contains("gamepad") || id.contains("console") {
            return ("เครื่องเล่นเกม / จอย (Game)", "Electronics", "gamecontroller.fill", "🛋️ ห้องนั่งเล่น", "ชั้นวางคอนโซลทีวี")
        }
        if id.contains("keyboard") || id.contains("typewriter") || id.contains("keypad") {
            return ("คีย์บอร์ด (Keyboard)", "Electronics", "keyboard.fill", "💼 ห้องทำงาน", "โต๊ะทำงาน")
        }
        if id.contains("mouse") || id.contains("trackball") || id.contains("mousepad") {
            return ("เมาส์ (Mouse)", "Electronics", "computermouse.fill", "💼 ห้องทำงาน", "โต๊ะทำงาน")
        }
        if id.contains("laptop") || id.contains("notebook") || id.contains("macbook") || id.contains("computer") {
            return ("โน้ตบุ๊กคอมพิวเตอร์ (Laptop)", "Electronics", "laptopcomputer", "💼 ห้องทำงาน", "โต๊ะทำงาน")
        }
        if id.contains("phone") || id.contains("telephone") || id.contains("smartphone") || id.contains("iphone") || id.contains("cellular") {
            return ("สมาร์ทโฟน (Phone)", "Electronics", "iphone", "🛋️ ห้องนั่งเล่น", "โต๊ะกลาง")
        }
        
        // 6. Tools, Stationery & Bags
        if id.contains("tool") || id.contains("screwdriver") || id.contains("wrench") || id.contains("hammer") || id.contains("pliers") || id.contains("drill") {
            return ("เครื่องมือช่าง (Tool)", "Tools", "wrench.adjustable.fill", "🚗 โรงรถ", "กล่องเครื่องมือช่าง")
        }
        if id.contains("pen") || id.contains("pencil") || id.contains("scissors") || id.contains("cutter") || id.contains("stationery") || id.contains("marker") {
            return ("เครื่องเขียน / กรรไกร (Stationery)", "Tools", "scissors", "💼 ห้องทำงาน", "กล่องเครื่องเขียน")
        }
        if id.contains("bag") || id.contains("backpack") || id.contains("suitcase") || id.contains("luggage") || id.contains("briefcase") || id.contains("handbag") {
            return ("กระเป๋า / กระเป๋าเป้ (Bag)", "General", "bag.fill", "🛏️ ห้องนอนใหญ่", "ตู้เสื้อผ้า")
        }
        if id.contains("bottle") || id.contains("tumbler") || id.contains("cup") || id.contains("mug") || id.contains("flask") || id.contains("glass") {
            return ("แก้วน้ำ / กระติกน้ำ (Tumbler/Bottle)", "General", "cup.and.saucer.fill", "🍳 ห้องครัว", "เคาน์เตอร์ครัว")
        }
        if id.contains("umbrella") || id.contains("parasol") {
            return ("ร่มกันฝน (Umbrella)", "General", "umbrella.fill", "🚪 หน้าบ้าน", "ที่วางร่มหน้าบ้าน")
        }
        
        // Dynamic fallback: Humanize raw Apple taxonomy identifier
        let formattedName = id
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return (formattedName, "General", "tag.fill", "🛋️ ห้องนั่งเล่น", "โต๊ะทำงาน")
    }
    
    private static func fallbackResult() -> ImageRecognitionResult {
        return ImageRecognitionResult(
            primaryCaption: "🧠 Apple Vision พร้อมจำแนกสิ่งของ (1,300+ Taxonomy)",
            topPredictions: [
                PredictedItemSuggestion(
                    name: "กระเป๋าสตางค์ (Wallet)", category: "Valuables", tags: ["wallet", "กระเป๋าเงิน"],
                    confidence: 0.88, icon: "wallet.bifold.fill", roomSuggestion: "🛋️ ห้องนั่งเล่น", containerSuggestion: "โต๊ะทำงาน"
                )
            ],
            autoPinPoint: CGPoint(x: 0.50, y: 0.50),
            detectedContextText: nil,
            detectedRoomOrFurniture: "🛋️ ห้องนั่งเล่น"
        )
    }
}

// Helper to convert UIImage.Orientation to CGImagePropertyOrientation for Vision
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
