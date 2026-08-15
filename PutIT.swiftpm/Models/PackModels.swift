import SwiftUI
import SwiftData

struct PackPresetItem: Identifiable {
    let id = UUID()
    let name: String
    let searchKeywords: [String]
    var isPacked: Bool = false
}

struct PackTemplate: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var defaultItems: [String]
}

struct PackService {
    static let templates: [PackTemplate] = [
        PackTemplate(
            id: "travel",
            title: "เดินทาง & ท่องเที่ยว (Travel)",
            subtitle: "พาสปอร์ต, สายชาร์จ, กระเป๋าสตางค์, ยาสามัญ",
            icon: "airplane",
            color: .indigo,
            defaultItems: ["Passport", "Wallet", "Charger", "Medicine", "Glasses"]
        ),
        PackTemplate(
            id: "work",
            title: "ไปทำงาน / ออกข้างนอก (Work)",
            subtitle: "โน้ตบุ๊ก, เมาส์, คีย์การ์ด, หูฟัง, สายชาร์จ",
            icon: "briefcase.fill",
            color: .blue,
            defaultItems: ["Laptop", "Mouse", "Keycard", "Headphones", "Charger"]
        ),
        PackTemplate(
            id: "daily",
            title: "ของจำเป็นประจำวัน (Daily)",
            subtitle: "กุญแจบ้าน, กุญแจรถ, กระเป๋าเงิน, แว่นตา",
            icon: "sun.max.fill",
            color: .orange,
            defaultItems: ["Key", "Car Key", "Wallet", "Glasses", "Umbrella"]
        )
    ]
}
