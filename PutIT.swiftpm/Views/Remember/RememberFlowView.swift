import SwiftUI
import SwiftData
import PhotosUI

struct RememberFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lang = LanguageManager.shared
    
    @Query(sort: \ItemMemory.createdAt, order: .reverse) private var allItems: [ItemMemory]
    
    @State private var currentStep: Int = 1
    
    // Step 1: Media, Anchor & AI
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var showCameraSheet: Bool = false
    @State private var anchorX: Double?
    @State private var anchorY: Double?
    
    // AI Vision & Auto-Pin State
    @State private var isAnalyzingAI: Bool = false
    @State private var aiResult: ImageRecognitionResult?
    @State private var autoPinPlaced: Bool = false
    
    // Step 2: Details
    @State private var itemName: String = ""
    @State private var category: String = "General"
    @State private var room: String = ""
    @State private var container: String = ""
    @State private var subSpot: String = ""
    @State private var tagsText: String = ""
    @State private var note: String = ""
    
    // Quick Presets (Clean, no noisy emoji)
    let roomChips: [String] = ["ห้องนอนใหญ่", "ห้องนั่งเล่น", "ห้องครัว", "หน้าบ้าน", "ห้องทำงาน", "โรงรถ"]
    let containerChips: [String] = ["ลิ้นชัก", "โต๊ะทำงาน", "ตู้เซฟ", "ชั้นวางของ", "ตู้เสื้อผ้า", "ที่แขวนผนัง"]
    let subSpotChips: [String] = ["ชั้นบนสุด", "ชั้นล่างสุด", "ถาดไม้วางของ", "มุมซ้ายหน้า", "มุมขวา", "กล่องจัดระเบียบ"]
    let categories: [String] = ["General", "Documents", "Keys & Access", "Electronics", "Tools", "Medicines", "Clothing", "Valuables"]
    
    private var isSaveDisabled: Bool {
        itemName.trimmingCharacters(in: .whitespaces).isEmpty || room.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // Smart Spatial Recommendation based on similar existing items
    private var smartSpatialRecommendation: (room: String, container: String, subSpot: String)? {
        guard let matchingItem = allItems.first(where: { $0.category == category && $0.currentEntry != nil && !$0.isSample }),
              let entry = matchingItem.currentEntry else {
            return nil
        }
        return (entry.room, entry.container, entry.subSpot)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                if currentStep == 1 {
                    stepOneMediaAndAnchorView
                } else {
                    stepTwoDetailsFormView
                }
            }
            .navigationTitle(currentStep == 1 ? lang.text("step1_title") : lang.text("step2_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarLeadingContent
                toolbarTrailingContent
            }
            .sheet(isPresented: $showCameraSheet) {
                CameraPicker(selectedImage: $pickedImage)
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                handlePhotoSelection(newItem)
            }
            .onChange(of: pickedImage) { _, newImage in
                if let img = newImage {
                    triggerAIAnalysis(image: img)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if currentStep == 2 {
                Button(action: { withAnimation { currentStep = 1 } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(lang.text("back"))
                    }
                    .font(.body.bold())
                    .foregroundStyle(Color.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { dismiss() }) {
                    Text(lang.text("cancel"))
                        .font(.body)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if currentStep == 1 {
                Button(action: {
                    withAnimation { currentStep = 2 }
                }) {
                    HStack(spacing: 4) {
                        Text(lang.text("next"))
                        Image(systemName: "chevron.right")
                    }
                    .font(.body.bold())
                    .foregroundStyle(Color.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    saveItem()
                }) {
                    Text(lang.text("save"))
                        .font(.body.bold())
                        .foregroundStyle(isSaveDisabled ? Color.secondary : Color.indigo)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isSaveDisabled)
            }
        }
    }
    
    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.pickedImage = uiImage
                    self.anchorX = nil
                    self.anchorY = nil
                    self.autoPinPlaced = false
                    triggerAIAnalysis(image: uiImage)
                }
            }
        }
    }
    
    // Trigger Offline Vision AI Analysis & Auto-Pin
    private func triggerAIAnalysis(image: UIImage) {
        isAnalyzingAI = true
        Task {
            let result = await OnDeviceVisionService.analyzeImage(image)
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.aiResult = result
                    self.isAnalyzingAI = false
                    
                    if let pin = result.autoPinPoint {
                        self.anchorX = Double(pin.x)
                        self.anchorY = Double(pin.y)
                        self.autoPinPlaced = true
                    }
                    
                    if let top = result.topPredictions.first, self.itemName.isEmpty {
                        self.applyPrediction(top)
                    }
                }
            }
        }
    }
    
    private func applyPrediction(_ pred: PredictedItemSuggestion) {
        self.itemName = pred.name
        self.category = pred.category
        self.tagsText = pred.tags.joined(separator: ", ")
        if self.room.isEmpty { self.room = pred.roomSuggestion }
        if self.container.isEmpty { self.container = pred.containerSuggestion }
    }
    
    // MARK: - Step 1 View
    private var stepOneMediaAndAnchorView: some View {
        VStack(spacing: 12) {
            if let image = pickedImage {
                photoPickedSection(image: image)
            } else {
                noPhotoPlaceholderSection
            }
        }
    }
    
    private func photoPickedSection(image: UIImage) -> some View {
        VStack(spacing: 12) {
            VisualAnchorPicker(image: image, anchorX: $anchorX, anchorY: $anchorY)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
            
            if autoPinPlaced {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow)
                    Text("AI ปักหมุดให้อัตโนมัติ (แตะเพื่อย้ายตำแหน่งได้)")
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.indigo.opacity(0.12)))
            }
            
            aiPredictionCard
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button(action: { showCameraSheet = true }) {
                    Label(lang.text("retake_photo"), systemImage: "camera.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label(lang.text("choose_other_photo"), systemImage: "photo.on.rectangle")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
    }
    
    private var noPhotoPlaceholderSection: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 44))
                    .foregroundStyle(.indigo)
            }
            
            VStack(spacing: 6) {
                Text(lang.text("remember_new_spot"))
                    .font(.title3.bold())
                Text("AI จะระบุสิ่งของและปักหมุดตำแหน่งบนภาพให้อัตโนมัติ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            
            VStack(spacing: 14) {
                Button(action: { showCameraSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text(lang.text("take_photo"))
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.stack.fill")
                        Text(lang.text("choose_library"))
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    withAnimation { currentStep = 2 }
                }) {
                    Text(lang.text("skip_photo"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    // AI Predictions Card
    private var aiPredictionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isAnalyzingAI {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Apple Vision วิเคราะห์ภาพ & Auto-Pin...")
                        .font(.caption.bold())
                        .foregroundStyle(.indigo)
                }
                .padding(.vertical, 4)
            } else if let result = aiResult {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.indigo)
                        Text(result.primaryCaption)
                            .font(.caption.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(result.topPredictions) { pred in
                                Button(action: {
                                    withAnimation { applyPrediction(pred) }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: pred.icon)
                                            .font(.caption2)
                                        Text(pred.name)
                                            .font(.caption2.bold())
                                        Text("\(Int(pred.confidence * 100))%")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(itemName == pred.name ? Color.white : Color.indigo)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(itemName == pred.name ? Color.indigo : Color.indigo.opacity(0.12))
                                    .foregroundStyle(itemName == pred.name ? Color.white : Color.indigo)
                                    .clipShape(Capsule())
                                    .contentShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Step 2 View
    private var stepTwoDetailsFormView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let rec = smartSpatialRecommendation, room.isEmpty || container.isEmpty {
                    smartSpatialRecommendationBadge(rec: rec)
                }
                
                itemNameFieldSection
                roomFieldSection
                containerFieldSection
                subSpotFieldSection
                notesFieldSection
                
                Spacer(minLength: 30)
            }
            .padding(.top, 10)
        }
    }
    
    private func smartSpatialRecommendationBadge(rec: (room: String, container: String, subSpot: String)) -> some View {
        Button(action: {
            withAnimation {
                self.room = rec.room
                self.container = rec.container
                self.subSpot = rec.subSpot
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Smart Spatial Recommendation")
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                    Text("ปกติของหมวดนี้เก็บไว้ที่: \(rec.room) › \(rec.container) (แตะเพื่อใช้)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.turn.down.right")
                    .font(.caption.bold())
                    .foregroundStyle(.indigo)
            }
            .padding(12)
            .background(Color.yellow.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.yellow.opacity(0.3), lineWidth: 1))
            .contentShape(Rectangle())
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
    
    private var itemNameFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(lang.text("item_name_label"), systemImage: "pencil.line")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            TextField("ชื่อสิ่งของ", text: $itemName)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    private var roomFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(lang.text("select_room"), systemImage: "house.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: 6) {
                ForEach(roomChips, id: \.self) { r in
                    Button(action: { self.room = r }) {
                        Text(r)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(room == r ? Color.indigo : Color(uiColor: .tertiarySystemGroupedBackground))
                            .foregroundStyle(room == r ? Color.white : Color.primary)
                            .clipShape(Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            TextField("ห้อง", text: $room)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    private var containerFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(lang.text("select_container"), systemImage: "archivebox.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: 6) {
                ForEach(containerChips, id: \.self) { c in
                    Button(action: { self.container = c }) {
                        Text(c)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(container == c ? Color.indigo : Color(uiColor: .tertiarySystemGroupedBackground))
                            .foregroundStyle(container == c ? Color.white : Color.primary)
                            .clipShape(Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            TextField("ที่เก็บ / เฟอร์นิเจอร์", text: $container)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    private var subSpotFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(lang.text("select_subspot"), systemImage: "scope")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: 6) {
                ForEach(subSpotChips, id: \.self) { s in
                    Button(action: { self.subSpot = s }) {
                        Text(s)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(subSpot == s ? Color.indigo : Color(uiColor: .tertiarySystemGroupedBackground))
                            .foregroundStyle(subSpot == s ? Color.white : Color.primary)
                            .clipShape(Capsule())
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            TextField("จุดย่อย / มุมที่วาง", text: $subSpot)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    private var notesFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.text("notes_label"))
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            TextField("หมายเหตุเพิ่มเติม...", text: $note)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
    // MARK: - Save Logic
    private func saveItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespaces)
        let trimmedRoom = room.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty && !trimmedRoom.isEmpty else { return }
        
        let tags = tagsText
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let newItem = ItemMemory(
            name: trimmedName,
            category: category,
            tags: tags,
            note: note.trimmingCharacters(in: .whitespaces),
            createdAt: Date(),
            isSample: false
        )
        
        var imageData: Data? = nil
        if let img = pickedImage {
            imageData = ImageManager.prepareImageForStorage(img)
        }
        
        let initialEntry = MemoryEntry(
            room: trimmedRoom,
            container: container.trimmingCharacters(in: .whitespaces),
            subSpot: subSpot.trimmingCharacters(in: .whitespaces),
            note: note.trimmingCharacters(in: .whitespaces),
            imageData: imageData,
            anchorX: anchorX,
            anchorY: anchorY,
            storedAt: Date(),
            isCurrent: true
        )
        
        newItem.entries.append(initialEntry)
        modelContext.insert(newItem)
        
        let newLocation = SavedLocation(
            room: trimmedRoom,
            container: container.trimmingCharacters(in: .whitespaces),
            subSpot: subSpot.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(newLocation)
        
        try? modelContext.save()
        dismiss()
    }
}
