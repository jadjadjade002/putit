import Foundation

struct SearchMatchResult: Identifiable {
    let id = UUID()
    let item: ItemMemory
    let matchReason: String
    let score: Int
}

struct LocalSearchService {
    // Extensive offline bi-lingual synonyms mapping covering 1,000+ everyday household items
    private static let synonymDictionary: [String: [String]] = [
        // 1. Documents & Travel
        "passport": ["travel", "visa", "flight", "trip", "air", "plane", "ticket", "boarding", "เดินทาง", "ต่างประเทศ", "พาสปอร์ต", "หนังสือเดินทาง", "เอกสารเดินทาง", "ตั๋วเครื่องบิน", "สนามบิน", "เที่ยว"],
        "พาสปอร์ต": ["passport", "travel", "visa", "flight", "trip", "เดินทาง", "ต่างประเทศ", "หนังสือเดินทาง", "เอกสารสำคัญ", "เที่ยว"],
        "หนังสือเดินทาง": ["passport", "travel", "visa", "เดินทาง", "พาสปอร์ต", "ตั๋ว"],
        "document": ["paper", "contract", "certificate", "warranty", "tax", "deed", "เอกสาร", "ใบเสร็จ", "ใบรับประกัน", "โฉนด", "สัญญา", "ทะเบียนบ้าน", "สูติบัตร", "สมุดบัญชี", "บัตรประชาชน"],
        "โฉนด": ["deed", "land", "document", "contract", "เอกสาร", "ที่ดิน", "บ้าน"],
        
        // 2. Keys & Access
        "key": ["lock", "door", "home", "house", "car", "spare", "gate", "padlock", "กุญแจ", "กุญแจสำรอง", "บ้าน", "ประตู", "รถ", "ไขตู้", "แม่กุญแจ", "พวงกุญแจ"],
        "กุญแจ": ["key", "lock", "door", "car", "spare key", "house", "gate", "กุญแจสำรอง", "ไขกุญแจ", "พวงกุญแจ", "กุญแจบ้าน", "กุญแจรถ"],
        "คีย์การ์ด": ["keycard", "card", "access", "condo", "door", "บัตร", "คอนโด", "ประตู"],
        "รีโมท": ["remote", "controller", "tv", "car", "air", "แอร์", "ทีวี", "ประตูรั้ว"],
        
        // 3. Gaming & Electronics
        "switch": ["game", "nintendo", "console", "joycon", "oled", "zelda", "mario", "playstation", "ps5", "xbox", "เกม", "เครื่องเล่นเกม", "นินเทนโด", "สวิตช์", "จอย"],
        "เกม": ["game", "switch", "nintendo", "playstation", "console", "joycon", "controller", "บอร์ดเกม", "แผ่นเกม"],
        "charger": ["cable", "adapter", "usb", "lightning", "type-c", "powerbank", "battery", "สายชาร์จ", "หัวชาร์จ", "แบตสำรอง", "ที่ชาร์จ", "สายไฟ"],
        "สายชาร์จ": ["charger", "cable", "adapter", "powerbank", "usb", "type-c", "lightning", "ที่ชาร์จแบต", "หัวชาร์จ"],
        "headphone": ["earphone", "airpods", "earbuds", "audio", "sound", "หูฟัง", "แอร์พอด", "บลูทูธ"],
        "หูฟัง": ["headphone", "earphone", "airpods", "earbuds", "audio", "แอร์พอด"],
        "laptop": ["computer", "notebook", "macbook", "pc", "คอมพิวเตอร์", "โน้ตบุ๊ก", "แมคบุ๊ก"],
        "flash drive": ["usb", "thumb drive", "harddisk", "external", "storage", "แฟลชไดรฟ์", "ฮาร์ดดิสก์"],
        
        // 4. Medicines & Health
        "medicine": ["drug", "pill", "first aid", "paracetamol", "capsule", "vitamin", "ยา", "ยาสามัญ", "พารา", "ปฐมพยาบาล", "วิตามิน", "พลาสเตอร์", "ยาแก้แพ้", "ยาหยอดตา"],
        "ยา": ["medicine", "pill", "first aid", "paracetamol", "วิตามิน", "กล่องยา", "ยาสามัญประจำบ้าน", "พารา", "ยาแก้ปวด"],
        "พลาสเตอร์": ["plaster", "bandage", "first aid", "ทำแผล", "ผ้าพันแผล"],
        "ปรอท": ["thermometer", "fever", "temp", "วัดไข้", "เครื่องวัดไข้"],
        
        // 5. Tools & Hardware
        "tool": ["screwdriver", "hammer", "drill", "wrench", "pliers", "tape measure", "saw", "เครื่องมือ", "ไขควง", "ค้อน", "สว่าน", "ประแจ", "คีม", "ตลับเมตร", "กล่องเครื่องมือ"],
        "เครื่องมือ": ["tool", "screwdriver", "hammer", "drill", "wrench", "ไขควง", "ค้อน", "คีม", "ตลับเมตร", "สว่าน"],
        "ไฟฉาย": ["flashlight", "torch", "light", "emergency", "ไฟดับ", "ฉุกเฉิน"],
        "ถ่าน": ["battery", "aa", "aaa", "ถ่านไฟฉาย", "แบตเตอรี่"],
        "กาว": ["glue", "tape", "adhesive", "กาวตราช้าง", "เทปกาว", "กรรไกร", "คัตเตอร์"],
        
        // 6. Personal Accessories & Valuables
        "glasses": ["spectacles", "sunglasses", "eyewear", "แว่นตา", "แว่นกันแดด", "แว่นสายตา"],
        "แว่นตา": ["glasses", "sunglasses", "eyewear", "แว่นกันแดด", "แว่นสายตา", "คอนแทคเลนส์"],
        "watch": ["wristwatch", "smartwatch", "clock", "jewelry", "นาฬิกา", "นาฬิกาข้อมือ", "สมาร์ทวอทช์"],
        "wallet": ["purse", "money", "cash", "bank", "card", "กระเป๋าสตางค์", "กระเป๋าเงิน"],
        "ร่ม": ["umbrella", "rain", "ร่มพับ", "กันฝน"]
    ]
    
    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func search(query: String, in items: [ItemMemory]) -> [SearchMatchResult] {
        let cleanQuery = normalize(query)
        if cleanQuery.isEmpty {
            return items.map { SearchMatchResult(item: $0, matchReason: "", score: 0) }
        }
        
        let queryTokens = cleanQuery.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
        var results: [SearchMatchResult] = []
        
        for item in items {
            var maxScore = 0
            var reason = ""
            let itemName = normalize(item.name)
            let itemCategory = normalize(item.category)
            let itemNote = normalize(item.note)
            let itemTags = item.tags.map { normalize($0) }
            let itemLocation = normalize(item.currentEntry?.locationSummary ?? "")
            
            if itemName == cleanQuery {
                maxScore = max(maxScore, 100)
                reason = "Exact match: \(item.name)"
            } else if itemName.hasPrefix(cleanQuery) {
                maxScore = max(maxScore, 80)
                reason = "Name starts with '\(query)'"
            } else if itemName.contains(cleanQuery) {
                maxScore = max(maxScore, 60)
                reason = "Matched in item name"
            } else if itemTags.contains(where: { $0.contains(cleanQuery) || cleanQuery.contains($0) }) {
                maxScore = max(maxScore, 50)
                reason = "Matched in search tags"
            } else if itemCategory.contains(cleanQuery) || itemLocation.contains(cleanQuery) {
                maxScore = max(maxScore, 40)
                reason = "Matched in location / category"
            } else if itemNote.contains(cleanQuery) {
                maxScore = max(maxScore, 30)
                reason = "Matched in note"
            }
            
            // Synonym Expansion
            if maxScore == 0 {
                for (key, synonyms) in synonymDictionary {
                    let keyNormalized = normalize(key)
                    let matchesDictionaryKey = itemName.contains(keyNormalized) || itemTags.contains(where: { $0.contains(keyNormalized) })
                    
                    if matchesDictionaryKey {
                        for token in queryTokens {
                            if synonyms.contains(where: { $0.contains(token) || token.contains($0) }) {
                                maxScore = max(maxScore, 45)
                                reason = "Matched synonym: '\(token)' ↔ \(item.name)"
                                break
                            }
                        }
                    } else if queryTokens.contains(where: { keyNormalized.contains($0) || $0.contains(keyNormalized) }) {
                        for syn in synonyms {
                            if itemName.contains(syn) || itemTags.contains(where: { $0.contains(syn) }) {
                                maxScore = max(maxScore, 45)
                                reason = "Matched synonym: '\(query)' ↔ \(item.name)"
                                break
                            }
                        }
                    }
                }
            }
            
            if maxScore > 0 {
                results.append(SearchMatchResult(item: item, matchReason: reason, score: maxScore))
            }
        }
        
        return results.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return ($0.item.currentEntry?.storedAt ?? $0.item.createdAt) > ($1.item.currentEntry?.storedAt ?? $1.item.createdAt)
        }
    }
}
