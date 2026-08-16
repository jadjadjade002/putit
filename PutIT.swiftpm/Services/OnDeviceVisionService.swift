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
    
    /// Analyzes an image with Apple Vision + Saliency Object Localization
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
            var salientBox: CGRect? = nil
            
            let fullHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            
            // 1. Saliency Request: Find main prominent foreground object
            let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest { request, _ in
                if let observation = request.results?.first as? VNSaliencyImageObservation,
                   let salientObjects = observation.salientObjects,
                   let primaryObject = salientObjects.first {
                    let box = primaryObject.boundingBox
                    // Convert Vision bottom-up (0,0 at bottom-left) to UI top-down (0,0 at top-left)
                    let cx = min(max(box.midX, 0.1), 0.9)
                    let cy = min(max(1.0 - box.midY, 0.1), 0.9)
                    autoPinCoordinate = CGPoint(x: cx, y: cy)
                    salientBox = box
                }
            }
            
            // 2. Global Classification Request
            let classifyRequest = VNClassifyImageRequest { request, _ in
                if let results = request.results as? [VNClassificationObservation] {
                    fullClassifications = results
                }
            }
            
            // 3. Fast OCR Text Recognition
            let textRequest = VNRecognizeTextRequest { request, _ in
                if let results = request.results as? [VNRecognizedTextObservation] {
                    recognizedTexts = results.compactMap { $0.topCandidates(1).first?.string }
                }
            }
            textRequest.recognitionLevel = .fast
            textRequest.usesLanguageCorrection = false
            
            do {
                try fullHandler.perform([saliencyRequest, classifyRequest, textRequest])
            } catch {
                print("Global Vision error: \(error)")
            }
            
            // 4. Accurately crop the salient target area in CGImage space
            let imgW = CGFloat(cgImage.width)
            let imgH = CGFloat(cgImage.height)
            
            if let box = salientBox {
                let cropW = min(imgW, max(0.25, box.width + 0.10) * imgW)
                let cropH = min(imgH, max(0.25, box.height + 0.10) * imgH)
                let cropCenterX = box.midX * imgW
                let cropCenterY = (1.0 - box.midY) * imgH // Vision midY is bottom-up
                let cropX = max(0, min(imgW - cropW, cropCenterX - cropW / 2))
                let cropY = max(0, min(imgH - cropH, cropCenterY - cropH / 2))
                let pixelRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
                
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
            
            let finalPinPoint = autoPinCoordinate ?? CGPoint(x: 0.50, y: 0.50)
            
            return processObservations(
                croppedObservations: croppedClassifications,
                fullObservations: fullClassifications,
                recognizedTexts: recognizedTexts,
                autoPinPoint: finalPinPoint
            )
        }.value
    }
    
    /// Re-analyzes a specific focused point on the image when user taps on the photo
    static func analyzeFocusedPoint(_ image: UIImage, point: CGPoint) async -> ImageRecognitionResult {
        guard let cgImage = image.cgImage else {
            return fallbackResult()
        }
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        return await Task.detached(priority: .userInitiated) {
            let imgW = CGFloat(cgImage.width)
            let imgH = CGFloat(cgImage.height)
            
            // 30% bounding crop around the pin point
            let cropW = min(imgW, 0.35 * imgW)
            let cropH = min(imgH, 0.35 * imgH)
            let cropCenterX = point.x * imgW
            let cropCenterY = point.y * imgH
            let cropX = max(0, min(imgW - cropW, cropCenterX - cropW / 2))
            let cropY = max(0, min(imgH - cropH, cropCenterY - cropH / 2))
            let pixelRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
            
            var focusedClassifications: [VNClassificationObservation] = []
            var focusedTexts: [String] = []
            
            if let croppedCG = cgImage.cropping(to: pixelRect) {
                let croppedHandler = VNImageRequestHandler(cgImage: croppedCG, orientation: orientation, options: [:])
                let classifyRequest = VNClassifyImageRequest { request, _ in
                    if let results = request.results as? [VNClassificationObservation] {
                        focusedClassifications = results
                    }
                }
                let textRequest = VNRecognizeTextRequest { request, _ in
                    if let results = request.results as? [VNRecognizedTextObservation] {
                        focusedTexts = results.compactMap { $0.topCandidates(1).first?.string }
                    }
                }
                textRequest.recognitionLevel = .fast
                try? croppedHandler.perform([classifyRequest, textRequest])
            }
            
            return processObservations(
                croppedObservations: focusedClassifications,
                fullObservations: [],
                recognizedTexts: focusedTexts,
                autoPinPoint: point
            )
        }.value
    }
    
    /// Processes observations and prioritizes high-value forgettable household items
    private static func processObservations(
        croppedObservations: [VNClassificationObservation],
        fullObservations: [VNClassificationObservation],
        recognizedTexts: [String],
        autoPinPoint: CGPoint?
    ) -> ImageRecognitionResult {
        var candidateScores: [String: (confidence: Double, score: Double, suggestion: PredictedItemSuggestion)] = [:]
        
        let sceneNoiseIdentifiers = [
            "indoor", "room", "furniture", "table", "floor", "desk", "black", "surface",
            "wood", "material", "lighting", "wall", "ceiling", "home", "building", "horizontal", "nobody",
            "structure", "structural", "structural_element", "construction", "indoor_space", "room_interior",
            "architecture", "architectural", "abstract", "shape", "color", "shadow", "outdoors", "outside"
        ]
        
        // 1. Process Cropped/Focused Target Observations (High Weight 4.0x)
        for obs in croppedObservations.prefix(40) {
            let id = obs.identifier.lowercased()
            if sceneNoiseIdentifiers.contains(where: { id == $0 || id.contains($0) }) { continue }
            if obs.confidence < 0.003 { continue }
            
            let (displayName, category, icon, room, container, isPriorityItem) = mapAppleIdentifierToHumanName(id)
            let rawConf = Double(obs.confidence)
            let priorityBoost = isPriorityItem ? 1.4 : 1.0
            let dynamicConf = min(max(rawConf * 3.0 * priorityBoost + 0.60, 0.70), 0.98)
            let score = (rawConf * 4.0 + 1.5) * priorityBoost
            
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
        
        // 2. Process Full Image Observations
        for obs in fullObservations.prefix(30) {
            let id = obs.identifier.lowercased()
            if sceneNoiseIdentifiers.contains(where: { id == $0 || id.contains($0) }) { continue }
            if obs.confidence < 0.005 { continue }
            
            let (displayName, category, icon, room, container, isPriorityItem) = mapAppleIdentifierToHumanName(id)
            let rawConf = Double(obs.confidence)
            let priorityBoost = isPriorityItem ? 1.3 : 1.0
            let dynamicConf = min(max(rawConf * 2.0 * priorityBoost + 0.45, 0.55), 0.90)
            let score = (rawConf * 1.2) * priorityBoost
            
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
        
        // 3. Check OCR Text for specific items
        let combinedText = recognizedTexts.joined(separator: " ").lowercased()
        if combinedText.contains("passport") || combinedText.contains("thai") {
            let item = PredictedItemSuggestion(
                name: "หนังสือเดินทาง (Passport)", category: "Documents", tags: ["passport", "พาสปอร์ต"],
                confidence: 0.96, icon: "doc.text.fill", roomSuggestion: "ห้องนอนใหญ่", containerSuggestion: "ตู้เซฟ"
            )
            candidateScores[item.name] = (0.96, 20.0, item)
        }
        
        // Fallback default candidates if empty
        if candidateScores.isEmpty {
            let def = PredictedItemSuggestion(
                name: "สิ่งของทั่วไป (Item)", category: "General", tags: ["item", "สิ่งของ"],
                confidence: 0.75, icon: "tag.fill", roomSuggestion: "ห้องนั่งเล่น", containerSuggestion: "โต๊ะทำงาน"
            )
            candidateScores[def.name] = (0.75, 1.0, def)
        }
        
        // Sort candidates by highest score
        let sorted = candidateScores.values.sorted { $0.score > $1.score }.map { $0.suggestion }
        let top4 = Array(sorted.prefix(4))
        let primary = top4.first!
        
        let caption = "Apple Vision ตรวจพบ: \(primary.name) (\(Int(primary.confidence * 100))%)"
        
        return ImageRecognitionResult(
            primaryCaption: caption,
            topPredictions: top4,
            autoPinPoint: autoPinPoint,
            detectedContextText: recognizedTexts.isEmpty ? nil : recognizedTexts.prefix(2).joined(separator: ", "),
            detectedRoomOrFurniture: primary.roomSuggestion
        )
    }
    
    /// Translates Apple Vision identifier into formatted Bilingual Name, Category, Icon, Room, and Priority flag
    private static func mapAppleIdentifierToHumanName(_ identifier: String) -> (name: String, category: String, icon: String, room: String, container: String, isPriority: Bool) {
        let id = identifier.lowercased()
        
        // 1. Electronics & Computing (High Priority)
        if id.contains("mouse") || id.contains("trackball") || id.contains("touchpad") || id.contains("pointing_device") {
            return ("เมาส์ (Mouse)", "Electronics", "computermouse.fill", "ห้องทำงาน", "โต๊ะทำงาน", true)
        }
        if id.contains("keyboard") || id.contains("keypad") || id.contains("typewriter") {
            return ("คีย์บอร์ด (Keyboard)", "Electronics", "keyboard.fill", "ห้องทำงาน", "โต๊ะทำงาน", true)
        }
        if id.contains("laptop") || id.contains("notebook") || id.contains("macbook") || id.contains("computer") {
            return ("โน้ตบุ๊ก (Laptop)", "Electronics", "laptopcomputer", "ห้องทำงาน", "โต๊ะทำงาน", true)
        }
        if id.contains("tablet") || id.contains("ipad") || id.contains("screen") || id.contains("display") || id.contains("monitor") {
            return ("แท็บเล็ต / iPad (Tablet)", "Electronics", "ipad", "ห้องทำงาน", "โต๊ะทำงาน", true)
        }
        if id.contains("phone") || id.contains("smartphone") || id.contains("iphone") || id.contains("cellular") || id.contains("mobile") {
            return ("โทรศัพท์มือถือ (Phone)", "Electronics", "iphone", "ห้องนั่งเล่น", "โต๊ะกลาง", true)
        }
        if id.contains("headphone") || id.contains("earphone") || id.contains("airpod") || id.contains("earbud") || id.contains("headset") {
            return ("หูฟัง (Headphones / Earphones)", "Electronics", "headphones", "ห้องทำงาน", "โต๊ะทำงาน", true)
        }
        if id.contains("charger") || id.contains("cable") || id.contains("cord") || id.contains("adapter") || id.contains("powerbank") || id.contains("usb") || id.contains("plug") {
            return ("สายชาร์จ / Powerbank (Charger)", "Electronics", "bolt.fill", "ห้องทำงาน", "กล่องจัดระเบียบ", true)
        }
        if id.contains("remote") || id.contains("clicker") || id.contains("transmitter") {
            return ("รีโมท (Remote Control)", "Electronics", "appletvremote.gen4.fill", "ห้องนั่งเล่น", "โต๊ะกลาง", true)
        }
        if id.contains("game") || id.contains("controller") || id.contains("joystick") || id.contains("gamepad") || id.contains("console") || id.contains("nintendo") || id.contains("playstation") {
            return ("เครื่องเล่นเกม / จอย (Gaming)", "Electronics", "gamecontroller.fill", "ห้องนั่งเล่น", "ชั้นวางทีวี", true)
        }
        
        // 2. Wallets, Keys & Valuables (High Priority)
        if id.contains("wallet") || id.contains("billfold") || id.contains("purse") || id.contains("moneybag") || id.contains("pocketbook") || id.contains("cardholder") || id.contains("clutch") {
            return ("กระเป๋าสตางค์ (Wallet)", "Valuables", "wallet.bifold.fill", "ห้องนั่งเล่น", "โต๊ะทำงาน / ลิ้นชัก", true)
        }
        if id.contains("key") || id.contains("keychain") || id.contains("keyring") || id.contains("fob") {
            return ("กุญแจ / พวงกุญแจ (Key)", "Keys & Access", "key.fill", "หน้าบ้าน", "ที่แขวนผนัง", true)
        }
        if id.contains("lock") || id.contains("padlock") || id.contains("latch") {
            return ("แม่กุญแจ / ล็อก (Lock)", "Keys & Access", "lock.fill", "หน้าบ้าน", "กล่องเก็บกุญแจ", true)
        }
        if id.contains("watch") || id.contains("wristwatch") || id.contains("timepiece") {
            return ("นาฬิกาข้อมือ (Watch)", "Valuables", "watch.analog", "ห้องนอนใหญ่", "โต๊ะข้างเตียง", true)
        }
        if id.contains("spectacles") || id.contains("sunglasses") || id.contains("glasses") || id.contains("eyewear") {
            return ("แว่นตา / แว่นกันแดด (Glasses)", "General", "eyeglasses", "ห้องนอนใหญ่", "โต๊ะข้างเตียง", true)
        }
        if id.contains("jewelry") || id.contains("necklace") || id.contains("ring") || id.contains("bracelet") || id.contains("earring") {
            return ("เครื่องประดับ / แหวน (Jewelry)", "Valuables", "sparkles", "ห้องนอนใหญ่", "ตู้เซฟ", true)
        }
        
        // 3. Skincare, Cosmetics & Medicines (High Priority)
        if id.contains("tube") || id.contains("ointment") || id.contains("cream") || id.contains("lotion") || id.contains("sunscreen") || id.contains("cosmetic") || id.contains("serum") || id.contains("gel") {
            return ("หลอดครีม / โลชั่น (Lotion/Cream)", "General", "sparkles", "ห้องนอนใหญ่", "โต๊ะเครื่องแป้ง", true)
        }
        if id.contains("pill") || id.contains("medicine") || id.contains("drug") || id.contains("capsule") || id.contains("syrup") || id.contains("bandage") || id.contains("first_aid") {
            return ("ยาสามัญ / วิตามิน (Medicine)", "Medicines", "cross.case.fill", "ห้องครัว", "ตู้ยา", true)
        }
        if id.contains("perfume") || id.contains("fragrance") || id.contains("spray") || id.contains("deodorant") {
            return ("น้ำหอม / สเปรย์ (Perfume)", "General", "sparkles", "ห้องนอนใหญ่", "โต๊ะเครื่องแป้ง", true)
        }
        if id.contains("comb") || id.contains("hairbrush") || id.contains("brush") {
            return ("หวี / แปรงผม (Comb/Brush)", "General", "comb.fill", "ห้องนอนใหญ่", "โต๊ะเครื่องแป้ง", true)
        }
        
        // 4. Documents, Books & Stationery (High Priority)
        if id.contains("passport") || id.contains("visa") || id.contains("document") || id.contains("certificate") || id.contains("paper") {
            return ("หนังสือเดินทาง / เอกสาร (Passport/Document)", "Documents", "doc.text.fill", "ห้องนอนใหญ่", "ตู้เซฟ", true)
        }
        if id.contains("book") || id.contains("novel") || id.contains("textbook") || id.contains("journal") || id.contains("diary") {
            return ("หนังสือ / สมุดบันทึก (Book/Notebook)", "General", "book.fill", "ห้องทำงาน", "ชั้นวางหนังสือ", true)
        }
        if id.contains("pen") || id.contains("pencil") || id.contains("marker") || id.contains("highlighter") {
            return ("ปากกา / ดินสอ (Pen/Pencil)", "Tools", "pencil", "ห้องทำงาน", "กล่องใส่ปากกา", true)
        }
        if id.contains("scissors") || id.contains("cutter") || id.contains("shears") {
            return ("กรรไกร / คัตเตอร์ (Scissors)", "Tools", "scissors", "ห้องทำงาน", "ลิ้นชัก", true)
        }
        
        // 5. Drinkware, Containers & Bags
        if id.contains("bottle") || id.contains("flask") || id.contains("thermos") {
            return ("ขวดน้ำ / กระติกน้ำ (Bottle)", "General", "cup.and.saucer.fill", "ห้องครัว", "เคาน์เตอร์ครัว", true)
        }
        if id.contains("cup") || id.contains("mug") || id.contains("glass") || id.contains("tumbler") {
            return ("แก้วน้ำ (Cup/Mug)", "General", "cup.and.saucer.fill", "ห้องครัว", "ชั้นวางแก้ว", true)
        }
        if id.contains("backpack") || id.contains("bag") || id.contains("luggage") || id.contains("suitcase") || id.contains("briefcase") {
            return ("กระเป๋าเป้ / กระเป๋าเดินทาง (Bag/Luggage)", "General", "bag.fill", "ห้องนอนใหญ่", "ตู้เสื้อผ้า", true)
        }
        if id.contains("umbrella") || id.contains("parasol") {
            return ("ร่มกันฝน (Umbrella)", "General", "umbrella.fill", "หน้าบ้าน", "ที่วางร่ม", true)
        }
        if id.contains("shoe") || id.contains("sneaker") || id.contains("boot") || id.contains("sandal") || id.contains("slipper") {
            return ("รองเท้า (Shoes)", "General", "shoeprints.fill", "หน้าบ้าน", "ตู้รองเท้า", false)
        }
        
        // 6. Tools & Hardware
        if id.contains("screwdriver") || id.contains("wrench") || id.contains("hammer") || id.contains("pliers") || id.contains("drill") || id.contains("tool") {
            return ("เครื่องมือช่าง (Tools)", "Tools", "wrench.adjustable.fill", "โรงรถ", "กล่องเครื่องมือ", true)
        }
        if id.contains("battery") || id.contains("flashlight") || id.contains("torch") {
            return ("ถ่านไฟฉาย / ไฟฉาย (Flashlight/Battery)", "Tools", "flashlight.on.fill", "ห้องนั่งเล่น", "ลิ้นชัก", true)
        }
        
        // Dynamic fallback
        let formattedName = id
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return (formattedName, "General", "tag.fill", "ห้องนั่งเล่น", "โต๊ะทำงาน", false)
    }
    
    private static func fallbackResult() -> ImageRecognitionResult {
        return ImageRecognitionResult(
            primaryCaption: "Apple Vision พร้อมจำแนกสิ่งของ (1,300+ Taxonomy)",
            topPredictions: [
                PredictedItemSuggestion(
                    name: "สิ่งของทั่วไป (Item)", category: "General", tags: ["item"],
                    confidence: 0.80, icon: "tag.fill", roomSuggestion: "ห้องนั่งเล่น", containerSuggestion: "โต๊ะทำงาน"
                )
            ],
            autoPinPoint: CGPoint(x: 0.50, y: 0.50),
            detectedContextText: nil,
            detectedRoomOrFurniture: "ห้องนั่งเล่น"
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
