import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case thai = "th"
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case chinese = "zh-Hans"
    case japanese = "ja"
    case korean = "ko"
    case portuguese = "pt-BR"
    case italian = "it"
    case russian = "ru"
    case arabic = "ar"
    case hindi = "hi"
    case turkish = "tr"
    case vietnamese = "vi"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .thai: return "🇹🇭 ภาษาไทย (Thai)"
        case .english: return "🇬🇧 English (Default)"
        case .spanish: return "🇪🇸 Español (Spanish)"
        case .french: return "🇫🇷 Français (French)"
        case .german: return "🇩🇪 Deutsch (German)"
        case .chinese: return "🇨🇳 简体中文 (Mandarin)"
        case .japanese: return "🇯🇵 日本語 (Japanese)"
        case .korean: return "🇰🇷 한국어 (Korean)"
        case .portuguese: return "🇧🇷 Português (Brasil)"
        case .italian: return "🇮🇹 Italiano (Italian)"
        case .russian: return "🇷🇺 Русский (Russian)"
        case .arabic: return "🇸🇦 العربية (Arabic)"
        case .hindi: return "🇮🇳 हिन्दी (Hindi)"
        case .turkish: return "🇹🇷 Türkçe (Turkish)"
        case .vietnamese: return "🇻🇳 Tiếng Việt (Vietnamese)"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @AppStorage("selected_app_language") var currentLanguage: AppLanguage = .thai {
        didSet {
            objectWillChange.send()
        }
    }
    
    func setLanguage(_ lang: AppLanguage) {
        currentLanguage = lang
    }
    
    // Localized Strings Dictionary across 15 languages
    func text(_ key: String) -> String {
        guard let dict = strings[key] else { return key }
        return dict[currentLanguage] ?? dict[.english] ?? key
    }
    
    /// Dynamically translates saved room/container/spot preset names into current language
    func localizeLocationText(_ text: String) -> String {
        guard currentLanguage != .thai else { return text }
        var result = text
        
        let mapping: [(thai: String, key: String)] = [
            ("ห้องนอนใหญ่", "room_bedroom"),
            ("ห้องนั่งเล่น", "room_living"),
            ("ห้องครัว", "room_kitchen"),
            ("หน้าบ้าน", "room_front"),
            ("โถงทางเข้า", "room_front"),
            ("ห้องทำงาน", "room_office"),
            ("โรงรถ", "room_garage"),
            ("ลิ้นชัก", "cont_drawer"),
            ("โต๊ะทำงาน", "cont_desk"),
            ("ตู้เซฟ", "cont_safe"),
            ("ชั้นวางของ", "cont_shelf"),
            ("ตู้เสื้อผ้า", "cont_closet"),
            ("ที่แขวนผนัง", "cont_hanger"),
            ("ชั้นบนสุด", "spot_top"),
            ("ชั้นล่างสุด", "spot_bottom"),
            ("ถาดไม้วางของ", "spot_tray"),
            ("มุมซ้าย", "spot_left"),
            ("มุมขวา", "spot_right"),
            ("กล่องจัดระเบียบ", "spot_organizer")
        ]
        
        for item in mapping {
            if result.contains(item.thai) {
                result = result.replacingOccurrences(of: item.thai, with: self.text(item.key))
            }
        }
        return result
    }
    
    /// Dynamically translates category name into current language
    func localizeCategory(_ cat: String) -> String {
        switch cat.lowercased() {
        case "general", "ทั่วไป": return text("cat_general")
        case "documents", "เอกสาร/พาสปอร์ต": return text("cat_docs")
        case "keys & access", "keys", "กุญแจ": return text("cat_keys")
        case "electronics", "ไอที/อุปกรณ์", "tech": return text("cat_electronics")
        case "gaming", "gaming/tech", "เกม/ไอที": return text("cat_games")
        case "tools", "เครื่องมือ": return text("cat_tools")
        case "medicines", "medicine", "ยา/สุขภาพ": return text("cat_meds")
        case "clothing", "เครื่องแต่งกาย": return text("cat_clothing")
        case "valuables", "ของมีค่า": return text("cat_valuables")
        default: return cat
        }
    }
    
    private let strings: [String: [AppLanguage: String]] = [
        // App & Navigation
        "app_title": [
            .thai: "PutIT", .english: "PutIT", .spanish: "PutIT", .french: "PutIT", .german: "PutIT",
            .chinese: "PutIT", .japanese: "PutIT", .korean: "PutIT", .portuguese: "PutIT", .italian: "PutIT",
            .russian: "PutIT", .arabic: "PutIT", .hindi: "PutIT", .turkish: "PutIT", .vietnamese: "PutIT"
        ],
        "search_placeholder": [
            .thai: "ค้นหาสิ่งของ (เช่น กุญแจ, พาสปอร์ต, โน้ตบุ๊ก)",
            .english: "Search items (e.g. key, passport, laptop)",
            .spanish: "Buscar objetos (ej. llaves, pasaporte, laptop)",
            .french: "Rechercher des objets (ex. clés, passeport, portable)",
            .german: "Gegenstände suchen (z. B. Schlüssel, Laptop)",
            .chinese: "搜索物品（如：钥匙、护照、笔记本）",
            .japanese: "アイテムを検索（鍵、パスポート、PCなど）",
            .korean: "물건 검색 (예: 열쇠, 여권, 노트북)",
            .portuguese: "Buscar itens (ex: chaves, passaporte, notebook)",
            .italian: "Cerca oggetti (es. chiavi, passaporto, laptop)",
            .russian: "Поиск вещей (напр. ключи, паспорт, ноутбук)",
            .arabic: "البحث عن الأشياء (مثل المفاتيح، الجواز، الحاسوب)",
            .hindi: "वस्तुएं खोजें (जैसे चाबी, पासपोर्ट, लैपटॉप)",
            .turkish: "Eşyaları ara (örn. anahtar, pasaport, dizüstü)",
            .vietnamese: "Tìm kiếm đồ đạc (ví dụ: chìa khóa, laptop)"
        ],
        "remember_new_spot": [
            .thai: "ถ่ายรูปจำที่เก็บของใหม่",
            .english: "Remember New Item Spot",
            .spanish: "Recordar nueva ubicación",
            .french: "Mémoriser un endroit",
            .german: "Neuen Ablageort merken",
            .chinese: "拍照记录存放位置",
            .japanese: "保管場所を撮影・記録",
            .korean: "보관 위치 기억하기",
            .portuguese: "Lembrar novo local",
            .italian: "Ricorda nuova posizione",
            .russian: "Запомнить место",
            .arabic: "تذكر مكان جديد",
            .hindi: "नया स्थान याद रखें",
            .turkish: "Yeni Konum Hatırla",
            .vietnamese: "Lưu vị trí đồ vật mới"
        ],
        "remember_sub": [
            .thai: "AI ตรวจจับสิ่งของ & ปักหมุดตำแหน่งภาพให้อัตโนมัติ",
            .english: "AI Auto-Pin & Smart Spatial Recommendation",
            .spanish: "Fijación automática por IA y recomendación espacial",
            .french: "Épinglage auto par IA et recommandation spatiale",
            .german: "KI-Auto-Pin & Intelligente Raumempfehlung",
            .chinese: "AI自动图钉定位 & 智能空间推荐",
            .japanese: "AI自動ピン留め ＆ スマート空間推薦",
            .korean: "AI 자동 핀 고정 및 스마트 공간 추천",
            .portuguese: "Fixação automática por IA e recomendação espacial",
            .italian: "Fissaggio automatico con IA e raccomandazione spaziale",
            .russian: "Авто-пин от ИИ и умные рекомендации мест",
            .arabic: "تثبيت تلقائي بالذكاء الاصطناعي وتوصيات ذكية",
            .hindi: "AI ऑटो-पिन और स्मार्ट स्थान सुझाव",
            .turkish: "Yapay Zeka Otomatik İğne & Akıllı Konum Önerisi",
            .vietnamese: "AI tự động ghim vị trí & gợi ý thông minh"
        ],
        "saved_items": [
            .thai: "ของที่บันทึกไว้",
            .english: "Saved Items",
            .spanish: "Objetos guardados",
            .french: "Objets enregistrés",
            .german: "Gespeicherte Gegenstände",
            .chinese: "已保存的物品",
            .japanese: "保存されたアイテム",
            .korean: "저장된 물건",
            .portuguese: "Itens salvos",
            .italian: "Oggetti salvati",
            .russian: "Сохраненные вещи",
            .arabic: "الأشياء المحفوظة",
            .hindi: "सहेजे गए सामान",
            .turkish: "Kayıtlı Eşyalar",
            .vietnamese: "Đồ vật đã lưu"
        ],
        "search_results": [
            .thai: "ผลการค้นหา",
            .english: "Search Results",
            .spanish: "Resultados de búsqueda",
            .french: "Résultats de recherche",
            .german: "Suchergebnisse",
            .chinese: "搜索结果",
            .japanese: "検索結果",
            .korean: "검색 결과",
            .portuguese: "Resultados da busca",
            .italian: "Risultati della ricerca",
            .russian: "Результаты поиска",
            .arabic: "نتائج البحث",
            .hindi: "खोज परिणाम",
            .turkish: "Arama Sonuçları",
            .vietnamese: "Kết quả tìm kiếm"
        ],
        "no_items": [
            .thai: "ยังไม่มีสิ่งของในระบบ",
            .english: "No items saved yet",
            .spanish: "Aún no hay objetos",
            .french: "Aucun objet enregistré",
            .german: "Noch keine Gegenstände gespeichert",
            .chinese: "暂无已保存物品",
            .japanese: "保存されたアイテムはありません",
            .korean: "저장된 물건이 없습니다",
            .portuguese: "Nenhum item salvo ainda",
            .italian: "Nessun oggetto salvato",
            .russian: "Пока нет сохраненных вещей",
            .arabic: "لا توجد عناصر محفوظة بعد",
            .hindi: "अभी कोई वस्तु సहेजी नहीं गई है",
            .turkish: "Henüz kayıtlı eşya yok",
            .vietnamese: "Chưa có đồ vật nào được lưu"
        ],
        "no_items_sub": [
            .thai: "แตะปุ่มถ่ายรูปเพื่อเริ่มจำที่เก็บของชิ้นแรก",
            .english: "Tap '+ Remember New Item' to start tracking",
            .spanish: "Toca para guardar tu primer objeto",
            .french: "Touchez pour enregistrer votre premier objet",
            .german: "Tippen Sie, um Ihren ersten Gegenstand zu speichern",
            .chinese: "点击拍照记录您的第一件物品",
            .japanese: "タップして最初のアイテムを記録しましょう",
            .korean: "첫 번째 물건을 기록하려면 탭하세요",
            .portuguese: "Toque para salvar seu primeiro item",
            .italian: "Tocca per salvare il tuo primo oggetto",
            .russian: "Нажмите, чтобы сохранить первую вещь",
            .arabic: "انقر لبدء حفظ أول عنصر لديك",
            .hindi: "अपनी पहली वस्तु सहेजने के लिए टैप करें",
            .turkish: "İlk eşyanızı kaydetmek için dokunun",
            .vietnamese: "Chạm để lưu đồ vật đầu tiên của bạn"
        ],
        "listening_voice": [
            .thai: "กำลังฟังเสียงพูด...",
            .english: "Listening to your voice...",
            .spanish: "Escuchando...",
            .french: "Écoute en cours...",
            .german: "Höre zu...",
            .chinese: "正在倾听语音...",
            .japanese: "音声を聞き取り中...",
            .korean: "음성을 듣고 있습니다...",
            .portuguese: "Ouvindo...",
            .italian: "In ascolto...",
            .russian: "Слушаю голос...",
            .arabic: "جارٍ الاستماع للصوت...",
            .hindi: "आवाज सुन रहा हूँ...",
            .turkish: "Ses dinleniyor...",
            .vietnamese: "Đang nghe giọng nói..."
        ],
        
        // Categories
        "cat_all": [
            .thai: "ทั้งหมด", .english: "All", .spanish: "Todo", .french: "Tout", .german: "Alle",
            .chinese: "全部", .japanese: "すべて", .korean: "전체", .portuguese: "Tudo", .italian: "Tutti",
            .russian: "Все", .arabic: "الكل", .hindi: "सभी", .turkish: "Tümü", .vietnamese: "Tất cả"
        ],
        "cat_general": [
            .thai: "ทั่วไป", .english: "General", .spanish: "General", .french: "Général", .german: "Allgemein",
            .chinese: "常规", .japanese: "一般", .korean: "일반", .portuguese: "Geral", .italian: "Generale",
            .russian: "Общее", .arabic: "عام", .hindi: "सामान्य", .turkish: "Genel", .vietnamese: "Chung"
        ],
        "cat_keys": [
            .thai: "กุญแจ", .english: "Keys", .spanish: "Llaves", .french: "Clés", .german: "Schlüssel",
            .chinese: "钥匙", .japanese: "鍵", .korean: "열쇠", .portuguese: "Chaves", .italian: "Chiavi",
            .russian: "Ключи", .arabic: "مفاتيح", .hindi: "चाबियाँ", .turkish: "Anahtarlar", .vietnamese: "Chìa khóa"
        ],
        "cat_docs": [
            .thai: "เอกสาร/พาสปอร์ต", .english: "Documents", .spanish: "Documentos", .french: "Documents", .german: "Dokumente",
            .chinese: "文件/护照", .japanese: "書類/パスポート", .korean: "서류/여권", .portuguese: "Documentos", .italian: "Documenti",
            .russian: "Документы", .arabic: "مستندات", .hindi: "दस्तावेज़", .turkish: "Belgeler", .vietnamese: "Tài liệu/Hộ chiếu"
        ],
        "cat_electronics": [
            .thai: "ไอที/อุปกรณ์", .english: "Electronics", .spanish: "Electrónica", .french: "Électronique", .german: "Elektronik",
            .chinese: "数码电子", .japanese: "電子機器/IT", .korean: "전자기기", .portuguese: "Eletrônicos", .italian: "Elettronica",
            .russian: "Электроника", .arabic: "إلكترونيات", .hindi: "इलेक्ट्रॉनिक्स", .turkish: "Elektronik", .vietnamese: "Điện tử"
        ],
        "cat_games": [
            .thai: "เกม/ไอที", .english: "Gaming/Tech", .spanish: "Juegos/Tec", .french: "Jeux/Tech", .german: "Gaming/Tech",
            .chinese: "游戏/数码", .japanese: "ゲーム/IT", .korean: "게임/기기", .portuguese: "Games/Tech", .italian: "Giochi/Tech",
            .russian: "Игры/Гаджеты", .arabic: "ألعاب/تقنية", .hindi: "गेमिंग/टेक", .turkish: "Oyun/Teknoloji", .vietnamese: "Trò chơi/Công nghệ"
        ],
        "cat_meds": [
            .thai: "ยา/สุขภาพ", .english: "Medicines", .spanish: "Medicinas", .french: "Médicaments", .german: "Medikamente",
            .chinese: "药品", .japanese: "薬", .korean: "의약품", .portuguese: "Remédios", .italian: "Medicine",
            .russian: "Лекарства", .arabic: "أدوية", .hindi: "दवाइयाँ", .turkish: "İlaçlar", .vietnamese: "Thuốc men"
        ],
        "cat_tools": [
            .thai: "เครื่องมือ", .english: "Tools", .spanish: "Herramientas", .french: "Outils", .german: "Werkzeuge",
            .chinese: "工具", .japanese: "工具", .korean: "도구/공구", .portuguese: "Ferramentas", .italian: "Strumenti",
            .russian: "Инструменты", .arabic: "أدوات", .hindi: "उपकरण", .turkish: "Aletler", .vietnamese: "Dụng cụ"
        ],
        "cat_clothing": [
            .thai: "เครื่องแต่งกาย", .english: "Clothing", .spanish: "Ropa", .french: "Vêtements", .german: "Kleidung",
            .chinese: "衣物", .japanese: "衣類", .korean: "의류", .portuguese: "Roupas", .italian: "Abbigliamento",
            .russian: "Одежда", .arabic: "ملابس", .hindi: "कपड़े", .turkish: "Giyim", .vietnamese: "Quần áo"
        ],
        "cat_valuables": [
            .thai: "ของมีค่า", .english: "Valuables", .spanish: "Objetos de valor", .french: "Objets de valeur", .german: "Wertsachen",
            .chinese: "贵重物品", .japanese: "貴重品", .korean: "귀중품", .portuguese: "Valiosos", .italian: "Oggetti di valore",
            .russian: "Ценности", .arabic: "أشياء ثمينة", .hindi: "कीमती सामान", .turkish: "Değerli Eşyalar", .vietnamese: "Đồ có giá trị"
        ],
        
        // Rooms
        "room_bedroom": [
            .thai: "ห้องนอนใหญ่", .english: "Master Bedroom", .spanish: "Dormitorio", .french: "Chambre", .german: "Schlafzimmer",
            .chinese: "主卧", .japanese: "寝室", .korean: "침실", .portuguese: "Quarto principal", .italian: "Camera",
            .russian: "Спальня", .arabic: "غرفة النوم", .hindi: "बेडरूम", .turkish: "Yatak Odası", .vietnamese: "Phòng ngủ"
        ],
        "room_living": [
            .thai: "ห้องนั่งเล่น", .english: "Living Room", .spanish: "Sala", .french: "Salon", .german: "Wohnzimmer",
            .chinese: "客厅", .japanese: "リビング", .korean: "거실", .portuguese: "Sala de estar", .italian: "Soggiorno",
            .russian: "Гостиная", .arabic: "غرفة المعيشة", .hindi: "लिविंग रूम", .turkish: "Oturma Odası", .vietnamese: "Phòng khách"
        ],
        "room_kitchen": [
            .thai: "ห้องครัว", .english: "Kitchen", .spanish: "Cocina", .french: "Cuisine", .german: "Küche",
            .chinese: "厨房", .japanese: "キッチン", .korean: "주방", .portuguese: "Cozinha", .italian: "Cucina",
            .russian: "Кухня", .arabic: "المطبخ", .hindi: "रसोई", .turkish: "Mutfak", .vietnamese: "Nhà bếp"
        ],
        "room_front": [
            .thai: "หน้าบ้าน/โถงทางเข้า", .english: "Entryway", .spanish: "Entrada", .french: "Entrée", .german: "Eingangsbereich",
            .chinese: "玄关", .japanese: "玄関", .korean: "현관", .portuguese: "Entrada", .italian: "Ingresso",
            .russian: "Прихожая", .arabic: "المدخل", .hindi: "प्रवेश द्वार", .turkish: "Antre", .vietnamese: "Cửa vào"
        ],
        "room_office": [
            .thai: "ห้องทำงาน", .english: "Home Office", .spanish: "Oficina", .french: "Bureau", .german: "Arbeitszimmer",
            .chinese: "书房/工作间", .japanese: "書斎/仕事部屋", .korean: "서재/작업실", .portuguese: "Escritório", .italian: "Studio",
            .russian: "Кабинет", .arabic: "المكتب", .hindi: "अध्ययन कक्ष", .turkish: "Çalışma Odası", .vietnamese: "Phòng làm việc"
        ],
        "room_garage": [
            .thai: "โรงรถ", .english: "Garage", .spanish: "Garaje", .french: "Garage", .german: "Garage",
            .chinese: "车库", .japanese: "ガレージ", .korean: "차고", .portuguese: "Garagem", .italian: "Garage",
            .russian: "Гараж", .arabic: "الكراج", .hindi: "गैरेज", .turkish: "Garaj", .vietnamese: "Nhà để xe"
        ],
        
        // Containers / Furniture
        "cont_drawer": [
            .thai: "ลิ้นชัก", .english: "Drawer", .spanish: "Cajón", .french: "Tiroir", .german: "Schublade",
            .chinese: "抽屉", .japanese: "引き出し", .korean: "서랍", .portuguese: "Gaveta", .italian: "Cassetto",
            .russian: "Ящик", .arabic: "درج", .hindi: "दराज", .turkish: "Çekmece", .vietnamese: "Ngăn kéo"
        ],
        "cont_desk": [
            .thai: "โต๊ะทำงาน", .english: "Desk / Table", .spanish: "Escritorio", .french: "Bureau", .german: "Schreibtisch",
            .chinese: "桌子", .japanese: "デスク/机", .korean: "책상", .portuguese: "Mesa", .italian: "Scrivania",
            .russian: "Стол", .arabic: "مكتب", .hindi: "मेज", .turkish: "Çalışma Masası", .vietnamese: "Bàn làm việc"
        ],
        "cont_safe": [
            .thai: "ตู้เซฟ", .english: "Safe Box", .spanish: "Caja fuerte", .french: "Coffre-fort", .german: "Tresor",
            .chinese: "保险箱", .japanese: "金庫", .korean: "금고", .portuguese: "Cofre", .italian: "Cassaforte",
            .russian: "Сейф", .arabic: "خزنة", .hindi: "तिजोरी", .turkish: "Kasa", .vietnamese: "Két sắt"
        ],
        "cont_shelf": [
            .thai: "ชั้นวางของ", .english: "Shelf", .spanish: "Estante", .french: "Étagère", .german: "Regal",
            .chinese: "置物架", .japanese: "棚/シェルフ", .korean: "선반", .portuguese: "Prateleira", .italian: "Scaffale",
            .russian: "Полка", .arabic: "رف", .hindi: "शेल्फ", .turkish: "Raf", .vietnamese: "Kệ đồ"
        ],
        "cont_closet": [
            .thai: "ตู้เสื้อผ้า", .english: "Wardrobe / Closet", .spanish: "Armario", .french: "Armoire", .german: "Kleiderschrank",
            .chinese: "衣柜", .japanese: "クローゼット", .korean: "옷장", .portuguese: "Guarda-roupa", .italian: "Armadio",
            .russian: "Шкаф", .arabic: "خزانة ملابس", .hindi: "अलमारी", .turkish: "Gardırop", .vietnamese: "Tủ quần áo"
        ],
        "cont_hanger": [
            .thai: "ที่แขวนผนัง", .english: "Wall Hanger", .spanish: "Perchero de pared", .french: "Porte-manteau", .german: "Wandhaken",
            .chinese: "墙上挂钩", .japanese: "壁掛けフック", .korean: "벽걸이 후크", .portuguese: "Cabide de parede", .italian: "Appendiabiti",
            .russian: "Настенный крючок", .arabic: "علاقة حائط", .hindi: "दीवार हैंगर", .turkish: "Duvar Askısı", .vietnamese: "Móc treo tường"
        ],
        
        // SubSpots
        "spot_top": [
            .thai: "ชั้นบนสุด", .english: "Top Shelf", .spanish: "Estante superior", .french: "Étage supérieur", .german: "Oberstes Fach",
            .chinese: "顶层", .japanese: "最上段", .korean: "맨 위층", .portuguese: "Prateleira superior", .italian: "Ripiano superiore",
            .russian: "Верхняя полка", .arabic: "الرف العلوي", .hindi: "शीर्ष शेल्फ", .turkish: "En Üst Raf", .vietnamese: "Tầng trên cùng"
        ],
        "spot_bottom": [
            .thai: "ชั้นล่างสุด", .english: "Bottom Shelf", .spanish: "Estante inferior", .french: "Étage inférieur", .german: "Unterstes Fach",
            .chinese: "底层", .japanese: "最下段", .korean: "맨 아래층", .portuguese: "Prateleira inferior", .italian: "Ripiano inferiore",
            .russian: "Нижняя полка", .arabic: "الرف السفلي", .hindi: "निचला शेल्फ", .turkish: "En Alt Raf", .vietnamese: "Tầng dưới cùng"
        ],
        "spot_tray": [
            .thai: "ถาดไม้วางของ", .english: "Organizer Tray", .spanish: "Bandeja", .french: "Plateau", .german: "Ablageschale",
            .chinese: "收纳托盘", .japanese: "トレー", .korean: "수납 트레이", .portuguese: "Bandeja organizadora", .italian: "Vassoio",
            .russian: "Лоток", .arabic: "صينية تنظيم", .hindi: "ट्रे", .turkish: "Düzenleyici Tepsi", .vietnamese: "Khay để đồ"
        ],
        "spot_left": [
            .thai: "มุมซ้าย", .english: "Left Side", .spanish: "Lado izquierdo", .french: "Côté gauche", .german: "Linke Seite",
            .chinese: "左侧", .japanese: "左側", .korean: "왼쪽", .portuguese: "Lado esquerdo", .italian: "Lato sinistro",
            .russian: "Слева", .arabic: "الجانب الأيسر", .hindi: "बाईं ओर", .turkish: "Sol Taraf", .vietnamese: "Góc trái"
        ],
        "spot_right": [
            .thai: "มุมขวา", .english: "Right Side", .spanish: "Lado derecho", .french: "Côté droit", .german: "Rechte Seite",
            .chinese: "右侧", .japanese: "右側", .korean: "오른쪽", .portuguese: "Lado direito", .italian: "Lato destro",
            .russian: "Справа", .arabic: "الجانب الأيمن", .hindi: "दाईं ओर", .turkish: "Sağ Taraf", .vietnamese: "Góc phải"
        ],
        "spot_organizer": [
            .thai: "กล่องจัดระเบียบ", .english: "Organizer Box", .spanish: "Caja organizadora", .french: "Boîte de rangement", .german: "Ordnungsbox",
            .chinese: "整理盒", .japanese: "収納ボックス", .korean: "정리함", .portuguese: "Caixa organizadora", .italian: "Scatola organizer",
            .russian: "Органайзер", .arabic: "صندوق تنظيم", .hindi: "ऑर्गनाइज़र बॉक्स", .turkish: "Düzenleyici Kutu", .vietnamese: "Hộp sắp xếp"
        ],
        
        // Card Badges
        "has_pin_badge": [
            .thai: "มีหมุดปักตำแหน่ง", .english: "Visual Anchor Pin", .spanish: "Punto fijado",
            .french: "Point épinglé", .german: "Visueller Pin", .chinese: "已图钉标记",
            .japanese: "ピン留め位置あり", .korean: "핀 고정 위치 있음", .portuguese: "Ponto fixado",
            .italian: "Spillo presente", .russian: "С меткой места", .arabic: "محدد بنقطة",
            .hindi: "पिन किया गया", .turkish: "İğneli Konum", .vietnamese: "Đã ghim vị trí"
        ],
        "past_spots": [
            .thai: "จุดที่เคยเก็บ", .english: "Past spots", .spanish: "Ubicaciones anteriores",
            .french: "Anciens lieux", .german: "Frühere Orte", .chinese: "处历史位置",
            .japanese: "か所の保管履歴", .korean: "곳의 이전 보관 위치", .portuguese: "Locais anteriores",
            .italian: "Posizioni passate", .russian: "Прошлые места", .arabic: "أماكن سابقة",
            .hindi: "पिछले स्थान", .turkish: "Önceki konum", .vietnamese: "Vị trí trước đây"
        ],
        "no_location": [
            .thai: "ไม่ระบุตำแหน่ง", .english: "No location specified", .spanish: "Sin ubicación",
            .french: "Aucun lieu spécifié", .german: "Kein Ort angegeben", .chinese: "未指定位置",
            .japanese: "場所未指定", .korean: "위치 미지정", .portuguese: "Sem local",
            .italian: "Nessun luogo", .russian: "Место не указано", .arabic: "الموقع غير محدد",
            .hindi: "स्थान निर्दिष्ट नहीं", .turkish: "Konum belirtilmedi", .vietnamese: "Chưa chỉ định nơi"
        ],
        "no_photo": [
            .thai: "ไม่มีรูปภาพ", .english: "No Photo", .spanish: "Sin foto",
            .french: "Pas de photo", .german: "Kein Foto", .chinese: "无照片",
            .japanese: "写真なし", .korean: "사진 없음", .portuguese: "Sem foto",
            .italian: "Nessuna foto", .russian: "Нет фото", .arabic: "لا توجد صورة",
            .hindi: "फोटो नहीं है", .turkish: "Fotoğraf Yok", .vietnamese: "Không có ảnh"
        ],
        
        // Unified Remember Flow
        "remember_flow_title": [
            .thai: "ถ่ายรูป & จำที่เก็บของ", .english: "Photo & Remember Spot", .spanish: "Foto y guardar lugar",
            .french: "Photo et mémoriser", .german: "Foto & Ort merken", .chinese: "拍照 ＆ 记录存放位置",
            .japanese: "撮影 ＆ 保管場所記録", .korean: "촬영 및 위치 기억하기", .portuguese: "Foto e lembrar local",
            .italian: "Foto e ricorda luogo", .russian: "Фото и место", .arabic: "التقاط وتذكر المكان",
            .hindi: "फोटो और स्थान याद रखें", .turkish: "Fotoğraf ve Konum", .vietnamese: "Chụp & Lưu vị trí"
        ],
        "take_photo": [
            .thai: "ถ่ายรูปด้วยกล้อง", .english: "Take Photo", .spanish: "Tomar foto",
            .french: "Prendre photo", .german: "Foto aufnehmen", .chinese: "拍照",
            .japanese: "カメラで撮影", .korean: "카메라 촬영", .portuguese: "Tirar foto",
            .italian: "Scatta foto", .russian: "Сделать фото", .arabic: "التقاط صورة",
            .hindi: "फोटो लें", .turkish: "Fotoğraf Çek", .vietnamese: "Chụp ảnh"
        ],
        "choose_library": [
            .thai: "เลือกจากคลังภาพ", .english: "Choose Photo", .spanish: "Elegir foto",
            .french: "Choisir photo", .german: "Aus Mediathek", .chinese: "从相册选择",
            .japanese: "写真から選択", .korean: "사진 선택", .portuguese: "Escolher foto",
            .italian: "Scegli foto", .russian: "Из галереи", .arabic: "اختيار صورة",
            .hindi: "गैलरी से चुनें", .turkish: "Fotoğraf Seç", .vietnamese: "Chọn ảnh"
        ],
        "retake_photo": [
            .thai: "ถ่ายรูปใหม่", .english: "Retake", .spanish: "Repetir", .french: "Reprendre",
            .german: "Neu aufnehmen", .chinese: "重拍", .japanese: "再撮影", .korean: "다시 촬영",
            .portuguese: "Tirar nova", .italian: "Riscotta", .russian: "Переснять", .arabic: "إعادة التقاط",
            .hindi: "फिर से लें", .turkish: "Yeniden Çek", .vietnamese: "Chụp lại"
        ],
        "choose_other_photo": [
            .thai: "เลือกรูปอื่น", .english: "Choose Other", .spanish: "Elegir otra", .french: "Autre photo",
            .german: "Anderes Foto", .chinese: "选择其他", .japanese: "他を選択", .korean: "다른 사진",
            .portuguese: "Outra foto", .italian: "Altra foto", .russian: "Другое фото", .arabic: "صورة أخرى",
            .hindi: "अन्य फोटो", .turkish: "Başka Fotoğraf", .vietnamese: "Chọn ảnh khác"
        ],
        "cancel": [
            .thai: "ยกเลิก", .english: "Cancel", .spanish: "Cancelar", .french: "Annuler", .german: "Abbrechen",
            .chinese: "取消", .japanese: "キャンセル", .korean: "취소", .portuguese: "Cancelar", .italian: "Annulla",
            .russian: "Отмена", .arabic: "إلغاء", .hindi: "रद्द करें", .turkish: "İptal", .vietnamese: "Hủy"
        ],
        "save": [
            .thai: "บันทึก", .english: "Save", .spanish: "Guardar", .french: "Enregistrer", .german: "Speichern",
            .chinese: "保存", .japanese: "保存", .korean: "저장", .portuguese: "Salvar", .italian: "Salva",
            .russian: "Сохранить", .arabic: "حفظ", .hindi: "सहेजें", .turkish: "Kaydet", .vietnamese: "Lưu"
        ],
        "done": [
            .thai: "เสร็จ", .english: "Done", .spanish: "Listo", .french: "OK", .german: "Fertig",
            .chinese: "完成", .japanese: "完了", .korean: "완료", .portuguese: "OK", .italian: "Fine",
            .russian: "Готово", .arabic: "تم", .hindi: "पूर्ण", .turkish: "Tamam", .vietnamese: "Xong"
        ],
        "back": [
            .thai: "ย้อนกลับ", .english: "Back", .spanish: "Atrás", .french: "Retour", .german: "Zurück",
            .chinese: "返回", .japanese: "戻る", .korean: "뒤로", .portuguese: "Voltar", .italian: "Indietro",
            .russian: "Назад", .arabic: "رجوع", .hindi: "वापस", .turkish: "Geri", .vietnamese: "Quay lại"
        ],
        
        // Form details
        "item_name_label": [
            .thai: "ชื่อสิ่งของ", .english: "Item Name", .spanish: "Nombre", .french: "Nom", .german: "Name",
            .chinese: "物品名称", .japanese: "アイテム名", .korean: "물건 이름", .portuguese: "Nome", .italian: "Nome",
            .russian: "Название", .arabic: "اسم العنصر", .hindi: "नाम", .turkish: "Eşya Adı", .vietnamese: "Tên đồ vật"
        ],
        "item_name_placeholder": [
            .thai: "เช่น พาสปอร์ต, เมาส์, กุญแจรถ", .english: "e.g. Passport, Mouse, Car Key",
            .spanish: "ej. Pasaporte, Ratón, Llave", .french: "ex. Passeport, Souris, Clé",
            .german: "z.B. Reisepass, Maus, Autoschlüssel", .chinese: "如：护照、鼠标、车钥匙",
            .japanese: "例：パスポート、マウス、車の鍵", .korean: "예: 여권, 마우스, 자동차 열쇠",
            .portuguese: "ex: Passaporte, Mouse, Chave do carro", .italian: "es. Passaporto, Mouse, Chiave auto",
            .russian: "напр. Паспорт, Мышь, Ключи", .arabic: "مثل: جواز سفر، فأرة، مفتاح سيارة",
            .hindi: "जैसे: पासपोर्ट, माउस, कार की चाबी", .turkish: "örn. Pasaport, Fare, Araba Anahtarı",
            .vietnamese: "ví dụ: Hộ chiếu, Chuột, Chìa khóa xe"
        ],
        "select_room": [
            .thai: "ห้อง", .english: "Room", .spanish: "Habitación", .french: "Pièce", .german: "Raum",
            .chinese: "房间", .japanese: "部屋", .korean: "방", .portuguese: "Cômodo", .italian: "Stanza",
            .russian: "Комната", .arabic: "الغرفة", .hindi: "कमरा", .turkish: "Oda", .vietnamese: "Phòng"
        ],
        "select_container": [
            .thai: "ที่เก็บ / เฟอร์นิเจอร์", .english: "Storage / Furniture", .spanish: "Mueble", .french: "Meuble", .german: "Möbel",
            .chinese: "存放家具", .japanese: "収納場所", .korean: "수납장", .portuguese: "Móvel", .italian: "Mobile",
            .russian: "Мебель", .arabic: "التخزين", .hindi: "फर्नीचर", .turkish: "Mobilya", .vietnamese: "Nơi cất"
        ],
        "select_subspot": [
            .thai: "จุดย่อย / มุมที่วาง", .english: "Specific Spot", .spanish: "Punto", .french: "Emplacement", .german: "Stelle",
            .chinese: "具体细节", .japanese: "詳細位置", .korean: "세부 위치", .portuguese: "Ponto", .italian: "Punto",
            .russian: "Полка/Угол", .arabic: "المكان المحدد", .hindi: "सटीक जगह", .turkish: "Alt Nokta", .vietnamese: "Chi tiết"
        ],
        "notes_label": [
            .thai: "หมายเหตุ", .english: "Notes", .spanish: "Notas", .french: "Notes", .german: "Notizen",
            .chinese: "备注", .japanese: "メモ", .korean: "메모", .portuguese: "Notas", .italian: "Note",
            .russian: "Заметки", .arabic: "ملاحظات", .hindi: "नोट्स", .turkish: "Notlar", .vietnamese: "Ghi chú"
        ],
        "ai_detected_chip_title": [
            .thai: "AI ตรวจจับสิ่งของ (แตะเพื่อเลือก):",
            .english: "AI Detected Items (Tap to choose):",
            .spanish: "Detección por IA (Toca para elegir):",
            .french: "Objets détectés par IA (Toucher pour choisir):",
            .german: "KI-Erkennung (Tippen zum Auswählen):",
            .chinese: "AI识别物品（点击选择）：",
            .japanese: "AI検出アイテム（タップして選択）：",
            .korean: "AI 감지 물건 (선택하려면 탭):",
            .portuguese: "Itens detectados por IA (Toque para escolher):",
            .italian: "Oggetti rilevati da IA (Tocca per scegliere):",
            .russian: "Распознано ИИ (нажмите для выбора):",
            .arabic: "تم التعرف بالذكاء الاصطناعي (انقر للاختيار):",
            .hindi: "AI द्वारा पहचानी गई वस्तुएं (चुनने के लिए टैप करें):",
            .turkish: "Yapay Zeka Tespitleri (Seçmek için dokunun):",
            .vietnamese: "AI nhận diện (Chạm để chọn):"
        ],
        "smart_recommendation_title": [
            .thai: "คำแนะนำจุดเก็บที่เคยบันทึกไว้:",
            .english: "Smart Spatial Recommendation:",
            .spanish: "Recomendación espacial inteligente:",
            .french: "Recommandation spatiale intelligente:",
            .german: "Intelligente Raumempfehlung:",
            .chinese: "智能空间收纳推荐：",
            .japanese: "スマート空間推薦：",
            .korean: "스마트 공간 추천:",
            .portuguese: "Recomendação espacial inteligente:",
            .italian: "Raccomandazione spaziale intelligente:",
            .russian: "Умные рекомендации мест:",
            .arabic: "توصية ذكية للأماكن:",
            .hindi: "स्मार्ट स्थान सुझाव:",
            .turkish: "Akıllı Konum Önerisi:",
            .vietnamese: "Gợi ý nơi cất thông minh:"
        ],
        "use_this_spot": [
            .thai: "ใช้จุดนี้", .english: "Use this spot", .spanish: "Usar este",
            .french: "Utiliser ce lieu", .german: "Diesen Ort nutzen", .chinese: "使用此位置",
            .japanese: "この場所を使う", .korean: "이 위치 사용", .portuguese: "Usar este",
            .italian: "Usa questo", .russian: "Использовать", .arabic: "استخدام هذا المكان",
            .hindi: "यह स्थान चुनें", .turkish: "Bu Konumu Kullan", .vietnamese: "Dùng vị trí này"
        ],
        
        // Item detail
        "current_location": [
            .thai: "ตำแหน่งปัจจุบัน", .english: "Current Location", .spanish: "Ubicación actual", .french: "Emplacement actuel", .german: "Aktueller Standort",
            .chinese: "当前位置", .japanese: "現在の保管場所", .korean: "현재 위치", .portuguese: "Local atual", .italian: "Posizione attuale",
            .russian: "Текущее место", .arabic: "الموقع الحالي", .hindi: "वर्तमान स्थान", .turkish: "Mevcut Konum", .vietnamese: "Vị trí hiện tại"
        ],
        "found_it_button": [
            .thai: "หาเจอแล้ว!", .english: "Found It!", .spanish: "¡Encontrado!", .french: "Trouvé !", .german: "Gefunden!",
            .chinese: "找到了！", .japanese: "見つかりました！", .korean: "찾았습니다!", .portuguese: "Encontrei!", .italian: "Trovato!",
            .russian: "Найдено!", .arabic: "وجدتُه!", .hindi: "मिल गया!", .turkish: "Buldum!", .vietnamese: "Đã tìm thấy!"
        ],
        "memory_trail_button": [
            .thai: "ประวัติการย้าย (Memory Trail)", .english: "Location History (Memory Trail)",
            .spanish: "Historial", .french: "Historique", .german: "Verlauf",
            .chinese: "存放历史", .japanese: "保管履歴", .korean: "이동 기록",
            .portuguese: "Histórico", .italian: "Cronologia", .russian: "История",
            .arabic: "سجل المواقع", .hindi: "स्थान इतिहास", .turkish: "Konum Geçmişi", .vietnamese: "Lịch sử di chuyển"
        ],
        "delete_item": [
            .thai: "ลบสิ่งของนี้?", .english: "Delete item?", .spanish: "¿Eliminar?", .french: "Supprimer ?", .german: "Löschen?",
            .chinese: "删除此物品？", .japanese: "削除しますか？", .korean: "삭제하시겠습니까?", .portuguese: "Excluir?", .italian: "Eliminare?",
            .russian: "Удалить?", .arabic: "حذف؟", .hindi: "हटाएं?", .turkish: "Sil?", .vietnamese: "Xóa đồ vật?"
        ],
        "delete_confirm": [
            .thai: "ลบสิ่งของและประวัติ", .english: "Delete item & history", .spanish: "Eliminar objeto",
            .french: "Supprimer l'historique", .german: "Löschen", .chinese: "删除物品及历史",
            .japanese: "すべて削除", .korean: "모든 기록 삭제", .portuguese: "Excluir histórico",
            .italian: "Elimina cronologia", .russian: "Удалить вещь", .arabic: "حذف السجل",
            .hindi: "इतिहास हटाएं", .turkish: "Eşyayı sil", .vietnamese: "Xóa toàn bộ"
        ],
        "still_here": [
            .thai: "เก็บไว้ที่เดิม", .english: "Still in the same spot", .spanish: "En el mismo lugar",
            .french: "Toujours au même endroit", .german: "Am selben Ort", .chinese: "仍在原位",
            .japanese: "元の場所に保管", .korean: "같은 위치에 보관", .portuguese: "No mesmo local",
            .italian: "Nello stesso posto", .russian: "На том же месте", .arabic: "في نفس المكان",
            .hindi: "उसी स्थान पर", .turkish: "Aynı yerde", .vietnamese: "Vẫn ở chỗ cũ"
        ],
        "relocate_new_spot": [
            .thai: "ย้ายไปที่เก็บใหม่", .english: "Move to a new spot", .spanish: "Mover a nuevo lugar",
            .french: "Déplacer vers un nouveau lieu", .german: "An neuen Ort verlegen", .chinese: "移动到新位置",
            .japanese: "新しい場所に移動", .korean: "새 위치로 이동", .portuguese: "Mover para novo local",
            .italian: "Sposta in un nuovo posto", .russian: "Переместить на новое место", .arabic: "نقل إلى مكان جديد",
            .hindi: "नए स्थान पर ले जाएं", .turkish: "Yeni konuma taşı", .vietnamese: "Chuyển sang vị trí mới"
        ],
        "relocate_title": [
            .thai: "ย้ายที่เก็บใหม่", .english: "Relocate Item", .spanish: "Mudar ubicación",
            .french: "Nouveau lieu", .german: "Neuer Standort", .chinese: "更新存放位置",
            .japanese: "新しい保管場所", .korean: "새 보관 위치", .portuguese: "Novo local",
            .italian: "Nuova posizione", .russian: "Новое место", .arabic: "تغيير المكان",
            .hindi: "नया स्थान", .turkish: "Yeni Konum", .vietnamese: "Vị trí mới"
        ],
        "no_photo_in_system": [
            .thai: "ยังไม่มีรูปหรือจุดปักในระบบ", .english: "No photo anchor recorded",
            .spanish: "Sin foto guardada", .french: "Aucune photo", .german: "Kein Foto vorhanden",
            .chinese: "尚未记录图钉照片", .japanese: "画像・ピン留め未登録", .korean: "사진 및 핀 미등록",
            .portuguese: "Sem foto salva", .italian: "Nessuna foto", .russian: "Фото не сохранено",
            .arabic: "لم يتم حفظ صورة", .hindi: "कोई फोटो रिकॉर्ड नहीं", .turkish: "Fotoğraf kaydedilmedi",
            .vietnamese: "Chưa có ảnh ghim"
        ],
        
        // Smart Pack Keys
        "smart_pack_title": [
            .thai: "Smart Pack", .english: "Smart Pack", .spanish: "Smart Pack", .french: "Smart Pack", .german: "Smart Pack",
            .chinese: "智能打包", .japanese: "スマートパック", .korean: "스마트 팩", .portuguese: "Smart Pack", .italian: "Smart Pack",
            .russian: "Смарт-Пак", .arabic: "الحزمة الذكية", .hindi: "स्मार्ट पैक", .turkish: "Akıllı Paket", .vietnamese: "Gói thông minh"
        ],
        "pack_travel": [
            .thai: "เดินทาง (Travel)", .english: "Travel", .spanish: "Viaje", .french: "Voyage", .german: "Reise",
            .chinese: "旅行", .japanese: "旅行", .korean: "여행", .portuguese: "Viagem", .italian: "Viaggio",
            .russian: "Поездка", .arabic: "سفر", .hindi: "यात्रा", .turkish: "Seyahat", .vietnamese: "Du lịch"
        ],
        "pack_work": [
            .thai: "ทำงาน (Work)", .english: "Work", .spanish: "Trabajo", .french: "Travail", .german: "Arbeit",
            .chinese: "办公", .japanese: "仕事", .korean: "업무", .portuguese: "Trabalho", .italian: "Lavoro",
            .russian: "Работа", .arabic: "عمل", .hindi: "काम", .turkish: "İş", .vietnamese: "Làm việc"
        ],
        "pack_daily": [
            .thai: "ประจำวัน (Daily)", .english: "Daily", .spanish: "Diario", .french: "Quotidien", .german: "Täglich",
            .chinese: "日常", .japanese: "日常", .korean: "일상", .portuguese: "Diário", .italian: "Quotidiano",
            .russian: "Ежедневно", .arabic: "يومي", .hindi: "दैनिक", .turkish: "Günlük", .vietnamese: "Hàng ngày"
        ],
        "pack_custom": [
            .thai: "กำหนดเอง", .english: "Custom", .spanish: "Personalizado", .french: "Personnalisé", .german: "Benutzerdefiniert",
            .chinese: "自定义", .japanese: "カスタム", .korean: "사용자 지정", .portuguese: "Personalizado", .italian: "Personalizzato",
            .russian: "Свой список", .arabic: "مخصص", .hindi: "कस्टम", .turkish: "Özel", .vietnamese: "Tùy chỉnh"
        ],
        "pack_progress_label": [
            .thai: "เตรียมของแล้ว", .english: "Packed", .spanish: "Empacado", .french: "Préparé", .german: "Gepackt",
            .chinese: "已准备", .japanese: "準備完了", .korean: "준비 완료", .portuguese: "Empacotado", .italian: "Preparato",
            .russian: "Собрано", .arabic: "تم التجهيز", .hindi: "पैक किया", .turkish: "Hazırlandı", .vietnamese: "Đã chuẩn bị"
        ],
        "add_pack_item": [
            .thai: "เพิ่มของในรายการนี้", .english: "Add Item to Pack", .spanish: "Añadir objeto",
            .french: "Ajouter un objet", .german: "Gegenstand hinzufügen", .chinese: "添加物品到清单",
            .japanese: "アイテムを追加", .korean: "물건 추가", .portuguese: "Adicionar item",
            .italian: "Aggiungi oggetto", .russian: "Добавить вещь", .arabic: "إضافة عنصر",
            .hindi: "वस्तु जोड़ें", .turkish: "Eşya Ekle", .vietnamese: "Thêm đồ vật"
        ],
        "new_pack_set": [
            .thai: "เซ็ตของใหม่", .english: "New Pack Set", .spanish: "Nuevo paquete",
            .french: "Nouveau set", .german: "Neues Set", .chinese: "新建清单",
            .japanese: "新規セット", .korean: "새 세트", .portuguese: "Novo pacote",
            .italian: "Nuovo set", .russian: "Новый набор", .arabic: "مجموعة جديدة",
            .hindi: "नया सेट", .turkish: "Yeni Set", .vietnamese: "Bộ mới"
        ],
        "new_pack_set_title": [
            .thai: "สร้างเซ็ตเตรียมของใหม่", .english: "Create New Pack Set", .spanish: "Crear nuevo paquete",
            .french: "Créer un nouveau set", .german: "Neues Set erstellen", .chinese: "创建新清单",
            .japanese: "新規パッキングセットを作成", .korean: "새 준비 세트 만들기", .portuguese: "Criar novo pacote",
            .italian: "Crea nuovo set", .russian: "Создать новый набор", .arabic: "إنشاء مجموعة جديدة",
            .hindi: "नया सेट बनाएं", .turkish: "Yeni Set Oluştur", .vietnamese: "Tạo bộ chuẩn bị mới"
        ],
        "enter_pack_set_name": [
            .thai: "ชื่อเซ็ตเตรียมของ (เช่น ไปยิม, ไปแคมป์)", .english: "Set Name (e.g. Gym, Camping)",
            .spanish: "Nombre (ej. Gimnasio, Camping)", .french: "Nom (ex. Gym, Camping)",
            .german: "Name (z. B. Fitness, Camping)", .chinese: "清单名称（如：健身、露营）",
            .japanese: "セット名（ジム、キャンプなど）", .korean: "세트 이름 (예: 헬스장, 캠핑)",
            .portuguese: "Nome (ex: Academia, Camping)", .italian: "Nome (es. Palestra, Campeggio)",
            .russian: "Название (напр. Спортзал, Поход)", .arabic: "اسم المجموعة (مثل النادي، التخييم)",
            .hindi: "सेट का नाम (जैसे जिम, कैंपिंग)", .turkish: "Set Adı (örn. Spor, Kamp)",
            .vietnamese: "Tên bộ (ví dụ: Tập gym, Cắm trại)"
        ],
        "enter_item_name": [
            .thai: "ชื่อสิ่งของที่ต้องเตรียม", .english: "Item to pack", .spanish: "Objeto a empacar",
            .french: "Objet à préparer", .german: "Gegenstand eingeben", .chinese: "准备的物品名称",
            .japanese: "準備するアイテム名", .korean: "준비할 물건 이름", .portuguese: "Item a empacotar",
            .italian: "Oggetto da preparare", .russian: "Что нужно взять", .arabic: "اسم العنصر المطلوب",
            .hindi: "तैयार करने वाली वस्तु", .turkish: "Hazırlanacak eşya", .vietnamese: "Tên đồ cần chuẩn bị"
        ],
        
        // Demo Guide Subtitles
        "guide_step1_desc": [
            .thai: "ถ่ายรูปสิ่งของ AI จะตรวจจับและปักหมุดตำแหน่งให้อัตโนมัติ",
            .english: "Snap a photo; AI detects the item & auto-places the visual pin.",
            .spanish: "Toma una foto; la IA detecta y coloca el pin automáticamente.",
            .french: "Prenez une photo ; l'IA détecte l'objet et place l'épingle.",
            .german: "Foto aufnehmen; KI erkennt das Objekt und setzt den Pin automatisch.",
            .chinese: "拍摄照片，AI将自动识别物品并定位图钉位置。",
            .japanese: "写真を撮るとAIが物体を認識し、自動でピン留めします。",
            .korean: "사진을 촬영하면 AI가 물건을 감지하고 자동으로 핀을 고정합니다.",
            .portuguese: "Tire uma foto; a IA detecta o item e fixa o ponto automaticamente.",
            .italian: "Scatta una foto; l'IA rileva l'oggetto e posiziona il pin automaticamente.",
            .russian: "Сделайте фото; ИИ распознает вещь и установит метку.",
            .arabic: "التقط صورة؛ يتعرف الذكاء الاصطناعي على العنصر ويضع النقطة تلقائياً.",
            .hindi: "फोटो लें; AI वस्तु को पहचानकर ऑटो-पिन लगा देगा।",
            .turkish: "Fotoğraf çekin; Yapay Zeka eşyayı algılar ve iğneyi otomatik yerleştirir.",
            .vietnamese: "Chụp ảnh; AI sẽ nhận diện đồ vật và tự động ghim vị trí."
        ],
        "guide_step2_desc": [
            .thai: "ระบบจัดของอัจฉริยะ ดึงรูปและตำแหน่งของที่ต้องเตรียมทันที",
            .english: "Smart pack checklist with direct photo anchors for quick retrieval.",
            .spanish: "Lista inteligente con fotos y ubicaciones para empacar rápido.",
            .french: "Liste intelligente avec photos et emplacements pour préparer rapidement.",
            .german: "Intelligente Packliste mit Fotohinweisen für schnelles Auffinden.",
            .chinese: "智能准备清单，直接展示存放照片与位置。",
            .japanese: "持ち物リストから保管場所の写真と位置を即座に確認できます。",
            .korean: "준비물 체크리스트에서 보관 사진과 위치를 즉시 확인합니다.",
            .portuguese: "Lista inteligente com fotos e locais para preparar rapidamente.",
            .italian: "Lista intelligente con foto e posizioni per preparare subito.",
            .russian: "Умный чек-лист с фото и местами для быстрого сбора.",
            .arabic: "قائمة تجهيز ذكية تعرض صور وأماكن الأشياء فوراً.",
            .hindi: "तैयारी सूची में वस्तु का फोटो और स्थान तुरंत देखें।",
            .turkish: "Hızlı toplama için fotoğraflı ve konumlu akıllı paket listesi.",
            .vietnamese: "Danh sách thông minh hiển thị ảnh và vị trí để chuẩn bị nhanh."
        ],
        "guide_step3_desc": [
            .thai: "ค้นหาด้วยเสียงพูดภาษาธรรมชาติ ค้นเจอทันที",
            .english: "Instant voice search with natural Thai/multilingual phonetic matching.",
            .spanish: "Búsqueda por voz instantánea con reconocimiento fonético.",
            .french: "Recherche vocale instantanée avec correspondance phonétique.",
            .german: "Sofortige Sprachsuche mit phonetischem Abgleich.",
            .chinese: "支持自然语音搜索，即说即搜。",
            .japanese: "自然な音声検索で探している物を一瞬で見つけます。",
            .korean: "자연스러운 음성 검색으로 즉시 물건을 찾습니다.",
            .portuguese: "Busca por voz instantânea com correspondência fonética.",
            .italian: "Ricerca vocale istantanea con corrispondenza fonetica.",
            .russian: "Мгновенный голосовой поиск вещей.",
            .arabic: "بحث صوتي فوري باللغة الطبيعية.",
            .hindi: "ध्वनि से तुरंत वस्तु खोजें।",
            .turkish: "Doğal dille anında sesli arama.",
            .vietnamese: "Tìm kiếm bằng giọng nói tức thì."
        ],
        "guide_step4_desc": [
            .thai: "บันทึกและติดตามประวัติการย้ายที่เก็บย้อนหลัง",
            .english: "Track and visualize complete location history over time.",
            .spanish: "Registra y sigue el historial de movimientos.",
            .french: "Enregistrez et suivez l'historique des déplacements.",
            .german: "Vollständigen Umzugs- und Standortverlauf nachverfolgen.",
            .chinese: "记录并追踪物品的历史移动轨迹。",
            .japanese: "保管場所の移動履歴を記録し、いつでも振り返れます。",
            .korean: "보관 위치 이동 기록을 저장하고 추적합니다.",
            .portuguese: "Registre e acompanhe o histórico de mudanças de local.",
            .italian: "Registra e traccia la cronologia degli spostamenti.",
            .russian: "История перемещения вещей и прошлых мест.",
            .arabic: "سجل وتتبع تاريخ تنقل الأماكن.",
            .hindi: "स्थान बदलने का पूरा इतिहास देखें।",
            .turkish: "Konum taşıma geçmişini kaydedin ve takip edin.",
            .vietnamese: "Ghi lại và theo dõi lịch sử di chuyển đồ vật."
        ],
        
        // Settings & Guide
        "settings_title": [
            .thai: "ตั้งค่า", .english: "Settings", .spanish: "Ajustes", .french: "Réglages", .german: "Einstellungen",
            .chinese: "设置", .japanese: "設定", .korean: "설정", .portuguese: "Ajustes", .italian: "Impostazioni",
            .russian: "Настройки", .arabic: "الإعدادات", .hindi: "सेटिंग्स", .turkish: "Ayarlar", .vietnamese: "Cài đặt"
        ],
        "language_section": [
            .thai: "ภาษา", .english: "Language", .spanish: "Idioma", .french: "Langue", .german: "Sprache",
            .chinese: "语言", .japanese: "言語", .korean: "언어", .portuguese: "Idioma", .italian: "Lingua",
            .russian: "Язык", .arabic: "اللغة", .hindi: "भाषा", .turkish: "Dil", .vietnamese: "Ngôn ngữ"
        ],
        "demo_guide_section": [
            .thai: "คู่มือการสาธิตสำหรับกรรมการ", .english: "Demo Guide", .spanish: "Guía de demo",
            .french: "Guide de démo", .german: "Demo-Leitfaden", .chinese: "演示指南",
            .japanese: "デモガイド", .korean: "데모 가이드", .portuguese: "Guia de demo",
            .italian: "Guida demo", .russian: "Руководство", .arabic: "دليل العرض",
            .hindi: "डेमो गाइड", .turkish: "Demo Kılavuzu", .vietnamese: "Hướng dẫn"
        ],
        "demo_data_header": [
            .thai: "ข้อมูลตัวอย่าง", .english: "Demo Data", .spanish: "Datos de demo",
            .french: "Données de démo", .german: "Demo-Daten", .chinese: "演示数据",
            .japanese: "デモデータ", .korean: "데모 데이터", .portuguese: "Dados de demo",
            .italian: "Dati demo", .russian: "Демо-данные", .arabic: "بيانات تجريبية",
            .hindi: "डेमो डेटा", .turkish: "Demo Verileri", .vietnamese: "Dữ liệu mẫu"
        ],
        "reset_data": [
            .thai: "โหลดข้อมูลตัวอย่างสำหรับสาธิต", .english: "Reload Sample Demo Data", .spanish: "Restablecer datos",
            .french: "Réinitialiser données", .german: "Demo-Daten laden", .chinese: "载入演示数据",
            .japanese: "デモデータを再読み込み", .korean: "샘플 데이터 다시 불러오기", .portuguese: "Recarregar dados",
            .italian: "Reimposta dati", .russian: "Загрузить демо-данные", .arabic: "إعادة ضبط البيانات",
            .hindi: "डेमो डेटा रीसेट करें", .turkish: "Örnek Verileri Yükle", .vietnamese: "Tải dữ liệu mẫu"
        ],
        "tech_privacy": [
            .thai: "สถาปัตยกรรม & ความเป็นส่วนตัว", .english: "Architecture & Privacy", .spanish: "Arquitectura",
            .french: "Architecture", .german: "Architektur", .chinese: "技术架构",
            .japanese: "アーキテクチャ", .korean: "아키텍처", .portuguese: "Arquitetura",
            .italian: "Architettura", .russian: "Архитектура", .arabic: "البنية والخصوصية",
            .hindi: "संरचना", .turkish: "Mimari", .vietnamese: "Kiến trúc"
        ],
        "network_status_label": [
            .thai: "สถานะการเชื่อมต่อ", .english: "Network Status", .spanish: "Estado de red",
            .french: "État du réseau", .german: "Netzwerkstatus", .chinese: "网络状态",
            .japanese: "ネットワーク状態", .korean: "네트워크 상태", .portuguese: "Status da rede",
            .italian: "Stato rete", .russian: "Состояние сети", .arabic: "حالة الشبكة",
            .hindi: "नेटवर्क स्थिति", .turkish: "Ağ Durumu", .vietnamese: "Trạng thái mạng"
        ],
        "offline_status": [
            .thai: "ออฟไลน์ 100% (On-Device)", .english: "100% Offline (On-Device)", .spanish: "100% Sin conexión",
            .french: "100% Hors ligne", .german: "100% Offline", .chinese: "100% 离线运行",
            .japanese: "100% オフライン", .korean: "100% 오프라인", .portuguese: "100% Offline",
            .italian: "100% Offline", .russian: "100% Офлайн", .arabic: "100% دون اتصال",
            .hindi: "100% ऑफ़लाइन", .turkish: "%100 Çevrimdışı", .vietnamese: "100% Ngoại tuyến"
        ],
        "found_count_badge": [
            .thai: "หาเจอ %d ครั้ง", .english: "Found %dx", .spanish: "Encontrado %dx",
            .french: "Trouvé %d fois", .german: "%dx gefunden", .chinese: "找到 %d 次",
            .japanese: "発見 %d回", .korean: "%d회 찾음", .portuguese: "Encontrado %dx",
            .italian: "Trovato %dx", .russian: "Найдено %d раз", .arabic: "تم العثور عليه %d مرات",
            .hindi: "%d बार मिला", .turkish: "%d kez bulundu", .vietnamese: "Đã tìm thấy %d lần"
        ]
    ]
}
