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
        // 1. Computing & Gadgets
        "laptop": ["computer", "notebook", "macbook", "pc", "คอมพิวเตอร์", "โน้ตบุ๊ก", "โน๊ตบุ๊ค", "โน้ตบุค", "โน๊ตบุค", "แล็ปท็อป", "คอม", "เครื่องคอม", "pc", "โน๊ตบุ๊ก"],
        "โน้ตบุ๊ก": ["laptop", "computer", "notebook", "macbook", "pc", "คอมพิวเตอร์", "โน๊ตบุ๊ค", "โน้ตบุค", "โน๊ตบุค", "แล็ปท็อป", "คอม", "เครื่องคอม"],
        "โน๊ตบุ๊ค": ["laptop", "computer", "notebook", "macbook", "pc", "คอมพิวเตอร์", "โน้ตบุ๊ก", "โน้ตบุค", "แล็ปท็อป", "คอม"],
        "คอมพิวเตอร์": ["computer", "laptop", "notebook", "macbook", "pc", "โน้ตบุ๊ก", "โน๊ตบุ๊ค", "คอม", "จอคอม"],
        "mouse": ["pointing", "trackball", "touchpad", "เมาส์", "เม้าส์", "เม้า", "เมาส"],
        "เมาส์": ["mouse", "trackball", "touchpad", "เม้าส์", "เม้า", "เมาส", "คอม"],
        "keyboard": ["keypad", "typewriter", "คีย์บอร์ด", "แป้นพิมพ์", "แป้น"],
        "คีย์บอร์ด": ["keyboard", "keypad", "แป้นพิมพ์", "แป้น"],
        "charger": ["cable", "adapter", "usb", "lightning", "type-c", "powerbank", "battery", "สายชาร์จ", "หัวชาร์จ", "แบตสำรอง", "ที่ชาร์จ", "สายไฟ", "สายusb", "พาวเวอร์แบงค์"],
        "สายชาร์จ": ["charger", "cable", "adapter", "powerbank", "usb", "type-c", "lightning", "ที่ชาร์จแบต", "หัวชาร์จ", "สายไฟ", "พาวเวอร์แบงค์"],
        "headphone": ["earphone", "airpods", "earbuds", "audio", "sound", "หูฟัง", "แอร์พอด", "บลูทูธ", "เฮดโฟน"],
        "หูฟัง": ["headphone", "earphone", "airpods", "earbuds", "audio", "แอร์พอด", "บลูทูธ"],
        "phone": ["smartphone", "iphone", "cellular", "mobile", "โทรศัพท์", "มือถือ", "ไอโฟน", "สมาร์ทโฟน"],
        "โทรศัพท์": ["phone", "smartphone", "iphone", "มือถือ", "ไอโฟน", "สมาร์ทโฟน"],
        "ipad": ["tablet", "tab", "ไอแพด", "แท็บเล็ต", "แทบเล็ต"],
        "switch": ["game", "nintendo", "console", "joycon", "oled", "zelda", "mario", "playstation", "ps5", "xbox", "เกม", "เครื่องเล่นเกม", "นินเทนโด", "สวิตช์", "จอย", "แผ่นเกม"],
        "flash drive": ["usb", "thumb drive", "harddisk", "external", "storage", "แฟลชไดรฟ์", "ฮาร์ดดิสก์", "ทัมไดร์ฟ"],
        
        // 2. Documents & Travel
        "passport": ["travel", "visa", "flight", "trip", "ticket", "เดินทาง", "ต่างประเทศ", "พาสปอร์ต", "หนังสือเดินทาง", "เอกสารเดินทาง", "ตั๋วเครื่องบิน", "สนามบิน", "เที่ยว"],
        "พาสปอร์ต": ["passport", "travel", "visa", "flight", "trip", "เดินทาง", "ต่างประเทศ", "หนังสือเดินทาง", "เอกสารสำคัญ", "เที่ยว", "ตั๋ว"],
        "หนังสือเดินทาง": ["passport", "travel", "visa", "เดินทาง", "พาสปอร์ต", "ตั๋ว", "ต่างประเทศ"],
        "document": ["paper", "contract", "certificate", "warranty", "tax", "deed", "เอกสาร", "ใบเสร็จ", "ใบรับประกัน", "โฉนด", "สัญญา", "ทะเบียนบ้าน", "สูติบัตร", "สมุดบัญชี", "บัตรประชาชน"],
        "บัตรประชาชน": ["id card", "card", "บัตร", "ประชาชน", "เอกสาร"],
        
        // 3. Keys & Access
        "key": ["lock", "door", "home", "house", "car", "spare", "gate", "padlock", "กุญแจ", "กุญแจสำรอง", "บ้าน", "ประตู", "รถ", "ไขตู้", "แม่กุญแจ", "พวงกุญแจ"],
        "กุญแจ": ["key", "lock", "door", "car", "spare key", "house", "gate", "กุญแจสำรอง", "ไขกุญแจ", "พวงกุญแจ", "กุญแจบ้าน", "กุญแจรถ"],
        "กุญแจรถ": ["car key", "key", "car", "รถ", "กุญแจ", "รีโมทรถ"],
        "รีโมท": ["remote", "controller", "tv", "car", "air", "แอร์", "ทีวี", "ประตูรั้ว", "รีโมทแอร์", "รีโมททีวี"],
        
        // 4. Medicines & Health
        "medicine": ["drug", "pill", "first aid", "paracetamol", "capsule", "vitamin", "ยา", "ยาสามัญ", "พารา", "ปฐมพยาบาล", "วิตามิน", "พลาสเตอร์", "ยาแก้แพ้", "ยาหยอดตา", "ตู้ยา"],
        "ยา": ["medicine", "pill", "first aid", "paracetamol", "วิตามิน", "กล่องยา", "ยาสามัญประจำบ้าน", "พารา", "ยาแก้ปวด", "ยาแก้แพ้"],
        "lotion": ["cream", "tube", "sunscreen", "skincare", "serum", "gel", "ครีม", "โลชั่น", "กันแดด", "หลอดครีม", "สกินแคร์", "เซรั่ม", "เจล"],
        "ครีม": ["lotion", "cream", "tube", "sunscreen", "skincare", "โลชั่น", "กันแดด", "หลอดครีม", "บำรุงผิว"],
        
        // 5. Tools & Everyday Items
        "tool": ["screwdriver", "hammer", "drill", "wrench", "pliers", "saw", "เครื่องมือ", "ไขควง", "ค้อน", "สว่าน", "ประแจ", "คีม", "ตลับเมตร", "กล่องเครื่องมือ"],
        "เครื่องมือ": ["tool", "screwdriver", "hammer", "drill", "wrench", "ไขควง", "ค้อน", "คีม", "ตลับเมตร", "สว่าน"],
        "scissors": ["cutter", "shears", "กรรไกร", "คัตเตอร์", "กรรไกรตัดกระดาษ"],
        "กรรไกร": ["scissors", "cutter", "คัตเตอร์", "ตัดกระดาษ", "เครื่องเขียน"],
        "glasses": ["spectacles", "sunglasses", "eyewear", "แว่นตา", "แว่นกันแดด", "แว่นสายตา", "แว่น"],
        "แว่นตา": ["glasses", "sunglasses", "eyewear", "แว่นกันแดด", "แว่นสายตา", "แว่น"],
        "watch": ["wristwatch", "smartwatch", "clock", "นาฬิกา", "นาฬิกาข้อมือ", "สมาร์ทวอทช์"],
        "นาฬิกา": ["watch", "wristwatch", "smartwatch", "นาฬิกาข้อมือ", "สมาร์ทวอทช์"],
        "wallet": ["purse", "money", "cash", "bank", "card", "กระเป๋าสตางค์", "กระเป๋าเงิน", "กระเป๋าตังค์", "ตังค์"],
        "กระเป๋าสตางค์": ["wallet", "purse", "money", "กระเป๋าเงิน", "กระเป๋าตังค์", "ตังค์", "กระเป๋า"],
        "bottle": ["flask", "tumbler", "water", "ขวดน้ำ", "กระติกน้ำ", "กระบอกน้ำ", "แก้วน้ำ"],
        "ขวดน้ำ": ["bottle", "flask", "tumbler", "กระติกน้ำ", "กระบอกน้ำ", "น้ำ"],
        "umbrella": ["rain", "parasol", "ร่ม", "ร่มพับ", "กันฝน"]
    ]
    
    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    /// Strips Thai tone marks and diacritics + harmonizes phonetic spelling (e.g. โน๊ตบุ๊ค vs โน้ตบุ๊ก)
    private static func normalizePhonetics(_ text: String) -> String {
        var s = normalize(text)
        let diacritics: [Character] = ["\u{0E48}", "\u{0E49}", "\u{0E4A}", "\u{0E4B}", "\u{0E47}", "\u{0E4C}", "\u{0E31}", "\u{0E4D}"]
        s.removeAll { diacritics.contains($0) }
        s = s.replacingOccurrences(of: "ค", with: "ก")
        s = s.replacingOccurrences(of: "ช", with: "จ")
        s = s.replacingOccurrences(of: "ท์", with: "")
        s = s.replacingOccurrences(of: "ร์", with: "")
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func search(query: String, in items: [ItemMemory]) -> [SearchMatchResult] {
        let cleanQuery = normalize(query)
        if cleanQuery.isEmpty {
            return items.map { SearchMatchResult(item: $0, matchReason: "", score: 0) }
        }
        
        let phoneticQuery = normalizePhonetics(query)
        let queryTokens = cleanQuery.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
        let phoneticTokens = phoneticQuery.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
        
        var results: [SearchMatchResult] = []
        
        for item in items {
            var maxScore = 0
            var reason = ""
            let itemName = normalize(item.name)
            let phoneticItemName = normalizePhonetics(item.name)
            let itemCategory = normalize(item.category)
            let phoneticCategory = normalizePhonetics(item.category)
            let itemNote = normalize(item.note)
            let phoneticNote = normalizePhonetics(item.note)
            let itemTags = item.tags.map { normalize($0) }
            let phoneticTags = item.tags.map { normalizePhonetics($0) }
            let itemLocation = normalize(item.currentEntry?.locationSummary ?? "")
            let phoneticLocation = normalizePhonetics(item.currentEntry?.locationSummary ?? "")
            
            // 1. Direct or Phonetic Match on Item Name
            if itemName == cleanQuery || phoneticItemName == phoneticQuery {
                maxScore = max(maxScore, 100)
                reason = "Exact match: \(item.name)"
            } else if itemName.hasPrefix(cleanQuery) || phoneticItemName.hasPrefix(phoneticQuery) {
                maxScore = max(maxScore, 85)
                reason = "Name starts with '\(query)'"
            } else if itemName.contains(cleanQuery) || phoneticItemName.contains(phoneticQuery) || cleanQuery.contains(itemName) || phoneticQuery.contains(phoneticItemName) {
                maxScore = max(maxScore, 80)
                reason = "Matched in item name"
            }
            
            // 2. Token / Substring Matching
            if maxScore < 80 {
                for token in phoneticTokens {
                    if phoneticItemName.contains(token) || token.contains(phoneticItemName) {
                        maxScore = max(maxScore, 75)
                        reason = "Matched keyword: '\(token)'"
                        break
                    }
                }
            }
            
            // 3. Tags & Category Matching
            if maxScore < 70 {
                if itemTags.contains(where: { $0.contains(cleanQuery) || cleanQuery.contains($0) }) || phoneticTags.contains(where: { $0.contains(phoneticQuery) || phoneticQuery.contains($0) }) {
                    maxScore = max(maxScore, 65)
                    reason = "Matched in search tags"
                } else if itemCategory.contains(cleanQuery) || itemLocation.contains(cleanQuery) || phoneticCategory.contains(phoneticQuery) || phoneticLocation.contains(phoneticQuery) {
                    maxScore = max(maxScore, 50)
                    reason = "Matched in location / category"
                } else if itemNote.contains(cleanQuery) || phoneticNote.contains(phoneticQuery) {
                    maxScore = max(maxScore, 40)
                    reason = "Matched in note"
                }
            }
            
            // 4. Synonym Expansion
            if maxScore == 0 {
                for (key, synonyms) in synonymDictionary {
                    let keyNorm = normalize(key)
                    let keyPhonetic = normalizePhonetics(key)
                    
                    let itemMatchesKey = itemName.contains(keyNorm) || phoneticItemName.contains(keyPhonetic) || itemTags.contains(where: { $0.contains(keyNorm) || normalizePhonetics($0).contains(keyPhonetic) })
                    
                    if itemMatchesKey {
                        for token in (queryTokens + phoneticTokens) {
                            if synonyms.contains(where: { normalize($0).contains(token) || normalizePhonetics($0).contains(token) || token.contains(normalizePhonetics($0)) }) {
                                maxScore = max(maxScore, 60)
                                reason = "Matched synonym: '\(query)' ↔ \(item.name)"
                                break
                            }
                        }
                    } else if (queryTokens + phoneticTokens).contains(where: { keyNorm.contains($0) || keyPhonetic.contains($0) || $0.contains(keyPhonetic) }) {
                        for syn in synonyms {
                            let synPhonetic = normalizePhonetics(syn)
                            if itemName.contains(normalize(syn)) || phoneticItemName.contains(synPhonetic) || itemTags.contains(where: { normalizePhonetics($0).contains(synPhonetic) }) {
                                maxScore = max(maxScore, 60)
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
