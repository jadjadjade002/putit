import SwiftUI
import SwiftData

struct PackPresetItem: Identifiable {
    let id = UUID()
    let name: String
    let searchKeywords: [String]
    var isPacked: Bool = false
}

struct PackTemplate: Identifiable, Equatable {
    let id: String
    var title: String
    var subtitle: String
    var icon: String
    var color: Color
    var defaultItems: [String]
    
    static func == (lhs: PackTemplate, rhs: PackTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

struct PackService {
    static let defaultTemplates: [PackTemplate] = [
        PackTemplate(
            id: "travel",
            title: "เดินทาง (Travel)",
            subtitle: "พาสปอร์ต, สายชาร์จ, กระเป๋าสตางค์, ยาสามัญ",
            icon: "airplane",
            color: .indigo,
            defaultItems: ["Passport", "Wallet", "Charger", "Medicine", "Glasses"]
        ),
        PackTemplate(
            id: "work",
            title: "ไปทำงาน (Work)",
            subtitle: "โน้ตบุ๊ก, เมาส์, คีย์การ์ด, หูฟัง, สายชาร์จ",
            icon: "briefcase.fill",
            color: .blue,
            defaultItems: ["Laptop", "Mouse", "Keycard", "Headphones", "Charger"]
        ),
        PackTemplate(
            id: "daily",
            title: "ของประจำวัน (Daily)",
            subtitle: "กุญแจบ้าน, กุญแจรถ, กระเป๋าเงิน, แว่นตา",
            icon: "sun.max.fill",
            color: .orange,
            defaultItems: ["Key", "Car Key", "Wallet", "Glasses", "Umbrella"]
        )
    ]
}
