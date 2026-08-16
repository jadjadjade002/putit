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
            .thai: "+ ถ่ายรูปจำที่เก็บของใหม่",
            .english: "+ Remember New Item Spot",
            .spanish: "+ Recordar nueva ubicación",
            .french: "+ Mémoriser un endroit",
            .german: "+ Neuen Ablageort merken",
            .chinese: "+ 拍照记录存放位置",
            .japanese: "+ 保管場所を撮影・記録",
            .korean: "+ 보관 위치 기억하기",
            .portuguese: "+ Lembrar novo local",
            .italian: "+ Ricorda nuova posizione",
            .russian: "+ Запомнить место",
            .arabic: "+ تذكر مكان جديد",
            .hindi: "+ नया स्थान याद रखें",
            .turkish: "+ Yeni Konum Hatırla",
            .vietnamese: "+ Lưu vị trí đồ vật mới"
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
        "no_search_match": [
            .thai: "ไม่พบสิ่งของที่ตรงกับการค้นหา",
            .english: "No items matched your search",
            .spanish: "No se encontraron objetos",
            .french: "Aucun objet trouvé",
            .german: "Keine übereinstimmenden Gegenstände",
            .chinese: "未找到匹配的物品",
            .japanese: "一致するアイテムは見つかりませんでした",
            .korean: "일치하는 물건을 찾을 수 없습니다",
            .portuguese: "Nenhum item encontrado",
            .italian: "Nessun oggetto corrispondente trovato",
            .russian: "Ничего не найдено",
            .arabic: "لم يتم العثور على أي نتائج",
            .hindi: "कोई मिलती-जुलती वस्तु नहीं मिली",
            .turkish: "Aramanızla eşleşen eşya bulunamadı",
            .vietnamese: "Không tìm thấy đồ vật phù hợp"
        ],
        
        // Categories
        "cat_all": [
            .thai: "ทั้งหมด", .english: "All", .spanish: "Todo", .french: "Tout", .german: "Alle",
            .chinese: "全部", .japanese: "すべて", .korean: "전체", .portuguese: "Tudo", .italian: "Tutti",
            .russian: "Все", .arabic: "الكل", .hindi: "सभी", .turkish: "Tümü", .vietnamese: "Tất cả"
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
        "skip_photo": [
            .thai: "ข้ามรูปถ่าย (บันทึกเฉพาะข้อความ)", .english: "Skip photo (Text only)",
            .spanish: "Omitir foto", .french: "Passer la photo", .german: "Foto überspringen",
            .chinese: "跳过照片", .japanese: "写真をスキップ", .korean: "사진 건너뛰기",
            .portuguese: "Pular foto", .italian: "Salta foto", .russian: "Пропустить фото",
            .arabic: "تخطي الصورة", .hindi: "फोटो छोड़ें", .turkish: "Fotoğrafı Atla",
            .vietnamese: "Bỏ qua ảnh"
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
        
        // Form details
        "item_name_label": [
            .thai: "ชื่อสิ่งของ", .english: "Item Name", .spanish: "Nombre", .french: "Nom", .german: "Name",
            .chinese: "物品名称", .japanese: "アイテム名", .korean: "물건 이름", .portuguese: "Nome", .italian: "Nome",
            .russian: "Название", .arabic: "اسم العنصر", .hindi: "नाम", .turkish: "Eşya Adı", .vietnamese: "Tên đồ vật"
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
        
        // Item detail
        "current_location": [
            .thai: "ตำแหน่งปัจจุบัน", .english: "Current Location", .spanish: "Ubicación actual", .french: "Emplacement actuel", .german: "Aktueller Standort",
            .chinese: "当前位置", .japanese: "現在の保管場所", .korean: "현재 위치", .portuguese: "Local atual", .italian: "Posizione attuale",
            .russian: "Текущее место", .arabic: "الموقع الحالي", .hindi: "वर्तमान स्थान", .turkish: "Mevcut Konum", .vietnamese: "Vị trí hiện tại"
        ],
        "room_label": [
            .thai: "ห้อง:", .english: "Room:", .spanish: "Habitación:", .french: "Pièce:", .german: "Raum:",
            .chinese: "房间:", .japanese: "部屋:", .korean: "방:", .portuguese: "Cômodo:", .italian: "Stanza:",
            .russian: "Комната:", .arabic: "الغرفة:", .hindi: "कमरा:", .turkish: "Oda:", .vietnamese: "Phòng:"
        ],
        "container_label": [
            .thai: "ที่เก็บ:", .english: "Storage:", .spanish: "Mueble:", .french: "Meuble:", .german: "Möbel:",
            .chinese: "收纳:", .japanese: "保管場所:", .korean: "수납:", .portuguese: "Móvel:", .italian: "Mobile:",
            .russian: "Мебель:", .arabic: "الأثاث:", .hindi: "फर्नीचर:", .turkish: "Mobilya:", .vietnamese: "Nơi cất:"
        ],
        "subspot_label": [
            .thai: "จุดย่อย:", .english: "Spot:", .spanish: "Punto:", .french: "Emplacement:", .german: "Stelle:",
            .chinese: "细节:", .japanese: "詳細:", .korean: "세부:", .portuguese: "Ponto:", .italian: "Punto:",
            .russian: "Угол:", .arabic: "الموقع:", .hindi: "स्थान:", .turkish: "Alt nokta:", .vietnamese: "Chi tiết:"
        ],
        "found_it_button": [
            .thai: "หาเจอแล้ว! (Found It)", .english: "Found It!", .spanish: "¡Encontrado!", .french: "Trouvé !", .german: "Gefunden!",
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
            .thai: "+ เพิ่มของในรายการนี้", .english: "+ Add Item to Pack", .spanish: "+ Añadir objeto",
            .french: "+ Ajouter un objet", .german: "+ Gegenstand hinzufügen", .chinese: "+ 添加物品到清单",
            .japanese: "+ アイテムを追加", .korean: "+ 물건 추가", .portuguese: "+ Adicionar item",
            .italian: "+ Aggiungi oggetto", .russian: "+ Добавить вещь", .arabic: "+ إضافة عنصر",
            .hindi: "+ वस्तु जोड़ें", .turkish: "+ Eşya Ekle", .vietnamese: "+ Thêm đồ vật"
        ],
        "new_pack_set": [
            .thai: "+ เซ็ตของใหม่", .english: "+ New Pack Set", .spanish: "+ Nuevo paquete",
            .french: "+ Nouveau set", .german: "+ Neues Set", .chinese: "+ 新建清单",
            .japanese: "+ 新規セット", .korean: "+ 새 세트", .portuguese: "+ Novo pacote",
            .italian: "+ Nuovo set", .russian: "+ Новый набор", .arabic: "+ مجموعة جديدة",
            .hindi: "+ नया सेट", .turkish: "+ Yeni Set", .vietnamese: "+ Bộ mới"
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
        "offline_status": [
            .thai: "ออฟไลน์ 100% (On-Device)", .english: "100% Offline (On-Device)", .spanish: "100% Sin conexión",
            .french: "100% Hors ligne", .german: "100% Offline", .chinese: "100% 离线运行",
            .japanese: "100% オフライン", .korean: "100% 오프라인", .portuguese: "100% Offline",
            .italian: "100% Offline", .russian: "100% Офлайн", .arabic: "100% دون اتصال",
            .hindi: "100% ऑफ़लाइन", .turkish: "%100 Çevrimdışı", .vietnamese: "100% Ngoại tuyến"
        ]
    ]
}
