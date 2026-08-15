import Foundation
import SwiftData
import UIKit

struct SampleDataSeeder {
    @MainActor
    static func seedInitialDataIfNeeded(context: ModelContext) {
        // Automatically clean out any existing demo sample items to provide a clean user experience
        cleanSampleData(context: context)
    }
    
    @MainActor
    static func cleanSampleData(context: ModelContext) {
        let itemFetch = FetchDescriptor<ItemMemory>()
        if let allItems = try? context.fetch(itemFetch) {
            for item in allItems where item.isSample {
                context.delete(item)
            }
            try? context.save()
        }
    }
    
    @MainActor
    static func resetAndRepopulateDemoData(context: ModelContext) {
        // Clear all existing data
        let itemFetch = FetchDescriptor<ItemMemory>()
        if let allItems = try? context.fetch(itemFetch) {
            for item in allItems {
                context.delete(item)
            }
        }
        
        let locFetch = FetchDescriptor<SavedLocation>()
        if let allLocs = try? context.fetch(locFetch) {
            for loc in allLocs {
                context.delete(loc)
            }
        }
        
        try? context.save()
        populateDemoData(context: context)
    }
    
    @MainActor
    private static func populateDemoData(context: ModelContext) {
        // 1. Saved Locations for autocomplete
        let loc1 = SavedLocation(room: "🛏️ ห้องนอนใหญ่", container: "ตู้เซฟในตู้เสื้อผ้า", subSpot: "ชั้นบนสุด ซองกำมะหยี่")
        let loc2 = SavedLocation(room: "🛋️ ห้องนั่งเล่น", container: "ลิ้นชักชั้นวางทีวี #2", subSpot: "ถาดไม้วางของฝั่งซ้าย")
        let loc3 = SavedLocation(room: "🛋️ ห้องนั่งเล่น", container: "ชั้นวางคอนโซลทีวี", subSpot: "ช่องขวาข้างแท่น Dock")
        let loc4 = SavedLocation(room: "💼 ห้องทำงาน", container: "ลิ้นชักโต๊ะทำงาน", subSpot: "กล่องจัดระเบียบ")
        
        context.insert(loc1)
        context.insert(loc2)
        context.insert(loc3)
        context.insert(loc4)
        
        // 2. Demo Item: Passport (หนังสือเดินทาง)
        let passport = ItemMemory(
            name: "หนังสือเดินทาง (Passport)",
            category: "Documents",
            tags: ["travel", "visa", "flight", "เอกสารสำคัญ", "ต่างประเทศ", "หนังสือเดินทาง", "พาสปอร์ต", "เที่ยว"],
            note: "หมดอายุปี 2028 เก็บในซองกำมะหยี่กันน้ำ ชั้นบนสุดของตู้เซฟ",
            createdAt: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            isSample: true
        )
        
        let passportImageData = ImageManager.createSafeBoxPassportScene()
        let passportEntry = MemoryEntry(
            room: "🛏️ ห้องนอนใหญ่ (Master Bedroom)",
            container: "ตู้เซฟนิรภัยในตู้เสื้อผ้า",
            subSpot: "ชั้นบนสุด ในซองกำมะหยี่สีน้ำเงิน",
            note: "วางอยู่ข้างสมุดบัญชีและเงินสำรองฉุกเฉิน",
            imageData: passportImageData,
            anchorX: 0.50,
            anchorY: 0.39,
            storedAt: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            isCurrent: true
        )
        passport.entries.append(passportEntry)
        context.insert(passport)
        
        // 3. Demo Item: Spare House Key (กุญแจสำรอง) with Memory Trail
        let spareKey = ItemMemory(
            name: "กุญแจบ้านสำรอง (Spare Key)",
            category: "Keys & Access",
            tags: ["key", "lock", "house", "door", "กุญแจ", "บ้าน", "ประตู", "สำรอง"],
            note: "กุญแจสีเงินป้ายแท็กสีน้ำเงิน สำหรับไขประตูล็อกหน้าบ้าน",
            createdAt: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            isSample: true
        )
        
        let oldKeyImageData = ImageManager.createTVStandKeyScene()
        let oldKeyEntry = MemoryEntry(
            room: "🍳 ห้องครัว (Kitchen)",
            container: "เคาน์เตอร์ไอส์แลนด์",
            subSpot: "ที่แขวนกุญแจแม่เหล็กติดผนัง",
            note: "ที่เดิม: คนเดินชนบ่อย เลยย้ายไปเก็บในลิ้นชักห้องนั่งเล่นแทน",
            imageData: oldKeyImageData,
            anchorX: 0.36,
            anchorY: 0.62,
            storedAt: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            isCurrent: false
        )
        
        let currentKeyImageData = ImageManager.createTVStandKeyScene()
        let currentKeyEntry = MemoryEntry(
            room: "🛋️ ห้องนั่งเล่น (Living Room)",
            container: "ตู้ชั้นวางทีวี (ลิ้นชักที่ 2)",
            subSpot: "ถาดไม้วางของมุมซ้ายหน้า",
            note: "ย้ายมาที่นี่เพื่อความปลอดภัยและหยิบใช้ง่าย",
            imageData: currentKeyImageData,
            anchorX: 0.36,
            anchorY: 0.62,
            storedAt: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
            isCurrent: true
        )
        spareKey.entries.append(oldKeyEntry)
        spareKey.entries.append(currentKeyEntry)
        spareKey.foundCount = 3
        context.insert(spareKey)
        
        // 4. Demo Item: Nintendo Switch OLED
        let nintendoSwitch = ItemMemory(
            name: "เครื่องเกม Nintendo Switch OLED",
            category: "Electronics",
            tags: ["game", "switch", "nintendo", "console", "joycon", "เกม", "นินเทนโด", "สวิตช์"],
            note: "พร้อม Joy-Con สีขาว และตลับเกม Zelda เสียบอยู่ข้างใน",
            createdAt: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
            isSample: true
        )
        
        let switchImageData = ImageManager.createGamingShelfScene()
        let switchEntry = MemoryEntry(
            room: "🛋️ ห้องนั่งเล่น (Living Room)",
            container: "ชั้นวางคอนโซลทีวี",
            subSpot: "ช่องขวาข้างแท่นวาง Docking Station",
            note: "เสียบชาร์จไว้บนแท่น Dock พร้อมผ้าคลุมกันฝุ่น",
            imageData: switchImageData,
            anchorX: 0.68,
            anchorY: 0.61,
            storedAt: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
            isCurrent: true
        )
        nintendoSwitch.entries.append(switchEntry)
        context.insert(nintendoSwitch)
        
        try? context.save()
    }
}
