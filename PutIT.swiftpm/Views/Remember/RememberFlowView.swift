import SwiftUI
import SwiftData
import PhotosUI

struct RememberFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lang = LanguageManager.shared
    
    @Query(sort: \ItemMemory.createdAt, order: .reverse) private var allItems: [ItemMemory]
    
    // Media & Visual Anchor
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var showCameraSheet: Bool = false
    @State private var anchorX: Double?
    @State private var anchorY: Double?
    
    // AI Vision & Auto-Pin State
    @State private var isAnalyzingAI: Bool = false
    @State private var aiResult: ImageRecognitionResult?
    @State private var autoPinPlaced: Bool = false
    
    // Details Form
    @State private var itemName: String = ""
    @State private var category: String = "General"
    @State private var room: String = ""
    @State private var container: String = ""
    @State private var subSpot: String = ""
    @State private var tagsText: String = ""
    @State private var note: String = ""
    
    // Quick Presets with Localization Keys
    let roomChipKeys: [String] = ["room_bedroom", "room_living", "room_kitchen", "room_front", "room_office", "room_garage"]
    let containerChipKeys: [String] = ["cont_drawer", "cont_desk", "cont_safe", "cont_shelf", "cont_closet", "cont_hanger"]
    let subSpotChipKeys: [String] = ["spot_top", "spot_bottom", "spot_tray", "spot_left", "spot_right", "spot_organizer"]
    let categoryKeys: [(key: String, id: String)] = [
        ("cat_general", "General"),
        ("cat_docs", "Documents"),
        ("cat_keys", "Keys & Access"),
        ("cat_electronics", "Electronics"),
        ("cat_tools", "Tools"),
        ("cat_meds", "Medicines"),
        ("cat_clothing", "Clothing"),
        ("cat_valuables", "Valuables")
    ]
    
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Photo & Visual Anchor Section
                        photoSectionView
                        
                        // 2. Smart Recommendation Banner (If available)
                        if let rec = smartSpatialRecommendation, room.isEmpty {
                            smartRecommendationBanner(rec: rec)
                        }
                        
                        // 3. Item Details Form
                        itemDetailsFormView
                        
                        // 4. Large Bottom Save Button
                        saveActionButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(lang.text("remember_flow_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { saveItem() }) {
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
            .onChange(of: anchorX) { _, newX in
                if let x = newX, let y = anchorY, !autoPinPlaced {
                    triggerFocusedReScan(atPoint: CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    // MARK: - Photo & Anchor Section
    private var photoSectionView: some View {
        VStack(spacing: 14) {
            if let image = pickedImage {
                VStack(spacing: 12) {
                    // Interactive Canvas with Visual Anchor Pin
                    VisualAnchorPicker(image: image, anchorX: $anchorX, anchorY: $anchorY)
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                    
                    // AI Status & Predictions Row
                    if isAnalyzingAI {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI กำลังวิเคราะห์วัตถุในรูปภาพ...")
                                .font(.caption.bold())
                                .foregroundStyle(Color.indigo)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.indigo.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } else if let result = aiResult {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color.indigo)
                                Text(lang.text("ai_detected_chip_title"))
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(result.topPredictions) { pred in
                                        Button(action: {
                                            withAnimation {
                                                itemName = pred.name.components(separatedBy: " (").first ?? pred.name
                                                category = pred.category
                                                if room.isEmpty { room = pred.roomSuggestion }
                                                if container.isEmpty { container = pred.containerSuggestion }
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: pred.icon)
                                                Text("\(pred.name) (\(Int(pred.confidence * 100))%)")
                                                    .font(.caption.weight(.semibold))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(itemName.contains(pred.name.components(separatedBy: " (").first ?? "") ? Color.indigo : Color(uiColor: .tertiarySystemGroupedBackground))
                                            .foregroundStyle(itemName.contains(pred.name.components(separatedBy: " (").first ?? "") ? Color.white : Color.primary)
                                            .clipShape(Capsule())
                                            .contentShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    
                    // Photo Actions Row
                    HStack(spacing: 12) {
                        Button(action: { showCameraSheet = true }) {
                            Label(lang.text("retake_photo"), systemImage: "camera.fill")
                                .font(.caption.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(lang.text("choose_other_photo"), systemImage: "photo.on.rectangle.angled")
                                .font(.caption.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation {
                                pickedImage = nil
                                anchorX = nil
                                anchorY = nil
                                aiResult = nil
                            }
                        }) {
                            Image(systemName: "trash")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.red)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                // No photo picked yet
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: { showCameraSheet = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text(lang.text("take_photo"))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color.indigo.gradient)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.indigo.opacity(0.25), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .font(.title2)
                                Text(lang.text("choose_library"))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundStyle(Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Smart Recommendation Banner
    private func smartRecommendationBanner(rec: (room: String, container: String, subSpot: String)) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.max.fill")
                .font(.title3)
                .foregroundStyle(Color.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(lang.text("smart_recommendation_title"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.primary)
                Text("\(rec.room) › \(rec.container)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    room = rec.room
                    if !rec.container.isEmpty { container = rec.container }
                    if !rec.subSpot.isEmpty { subSpot = rec.subSpot }
                }
            }) {
                Text(lang.text("use_this_spot"))
            }
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.yellow.opacity(0.2))
            .foregroundStyle(Color.orange)
            .clipShape(Capsule())
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - Item Details Form
    private var itemDetailsFormView: some View {
        VStack(spacing: 16) {
            // Item Name & Category
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.text("item_name_label"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.secondary)
                
                TextField(lang.text("item_name_placeholder"), text: $itemName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                Picker(lang.text("item_name_label"), selection: $category) {
                    ForEach(categoryKeys, id: \.id) { cat in
                        Text(lang.text(cat.key)).tag(cat.id)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Room
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.text("select_room"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.secondary)
                
                FlowLayout(spacing: 6) {
                    ForEach(roomChipKeys, id: \.self) { key in
                        let chipText = lang.text(key)
                        Button(action: { room = chipText }) {
                            Text(chipText)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(room == chipText ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundStyle(room == chipText ? Color.white : Color.primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                TextField(lang.text("select_room"), text: $room)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            // Storage / Furniture
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.text("select_container"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.secondary)
                
                FlowLayout(spacing: 6) {
                    ForEach(containerChipKeys, id: \.self) { key in
                        let chipText = lang.text(key)
                        Button(action: { container = chipText }) {
                            Text(chipText)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(container == chipText ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundStyle(container == chipText ? Color.white : Color.primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                TextField(lang.text("select_container"), text: $container)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            // Specific Spot
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.text("select_subspot"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.secondary)
                
                FlowLayout(spacing: 6) {
                    ForEach(subSpotChipKeys, id: \.self) { key in
                        let chipText = lang.text(key)
                        Button(action: { subSpot = chipText }) {
                            Text(chipText)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(subSpot == chipText ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundStyle(subSpot == chipText ? Color.white : Color.primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                TextField(lang.text("select_subspot"), text: $subSpot)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text(lang.text("notes_label"))
                    .font(.caption.bold())
                    .foregroundStyle(Color.secondary)
                
                TextField(lang.text("notes_label"), text: $note)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
    
    // MARK: - Save Action Button
    private var saveActionButton: some View {
        Button(action: { saveItem() }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(lang.text("save"))
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isSaveDisabled ? Color.secondary.opacity(0.5) : Color.indigo)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: isSaveDisabled ? .clear : Color.indigo.opacity(0.3), radius: 8, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isSaveDisabled)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Methods
    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.pickedImage = image
                    self.anchorX = nil
                    self.anchorY = nil
                    self.autoPinPlaced = false
                }
            }
        }
    }
    
    private func triggerAIAnalysis(image: UIImage) {
        isAnalyzingAI = true
        autoPinPlaced = false
        Task {
            let result = await OnDeviceVisionService.analyzeImage(image)
            await MainActor.run {
                self.isAnalyzingAI = false
                self.aiResult = result
                
                // Auto-place pin from Apple Vision saliency if user hasn't set one
                if self.anchorX == nil, let pt = result.autoPinPoint {
                    self.anchorX = Double(pt.x)
                    self.anchorY = Double(pt.y)
                    self.autoPinPlaced = true
                }
                
                // Auto-populate item name & category if empty
                if self.itemName.isEmpty, let top = result.topPredictions.first {
                    self.itemName = top.name.components(separatedBy: " (").first ?? top.name
                    self.category = top.category
                    if self.room.isEmpty { self.room = top.roomSuggestion }
                    if self.container.isEmpty { self.container = top.containerSuggestion }
                }
            }
        }
    }
    
    private func triggerFocusedReScan(atPoint pt: CGPoint) {
        guard let img = pickedImage else { return }
        Task {
            let result = await OnDeviceVisionService.analyzeFocusedPoint(img, point: pt)
            await MainActor.run {
                self.aiResult = result
                if let top = result.topPredictions.first {
                    withAnimation {
                        self.itemName = top.name.components(separatedBy: " (").first ?? top.name
                        self.category = top.category
                        if self.room.isEmpty { self.room = top.roomSuggestion }
                        if self.container.isEmpty { self.container = top.containerSuggestion }
                    }
                }
            }
        }
    }
    
    private func saveItem() {
        guard !isSaveDisabled else { return }
        
        let imgData = pickedImage.flatMap { ImageManager.prepareImageForStorage($0) }
        
        let newEntry = MemoryEntry(
            room: room.trimmingCharacters(in: .whitespaces),
            container: container.trimmingCharacters(in: .whitespaces).isEmpty ? "โต๊ะ / ตู้" : container.trimmingCharacters(in: .whitespaces),
            subSpot: subSpot.trimmingCharacters(in: .whitespaces),
            note: note.trimmingCharacters(in: .whitespaces),
            imageData: imgData,
            anchorX: anchorX,
            anchorY: anchorY,
            isCurrent: true
        )
        
        var tags: [String] = []
        if let ai = aiResult {
            for pred in ai.topPredictions {
                tags.append(contentsOf: pred.tags)
            }
        }
        tags.append(itemName)
        tags.append(room)
        tags.append(container)
        
        let newItem = ItemMemory(
            name: itemName.trimmingCharacters(in: .whitespaces),
            category: category,
            tags: Array(Set(tags)),
            note: note.trimmingCharacters(in: .whitespaces)
        )
        
        newItem.entries.append(newEntry)
        modelContext.insert(newItem)
        
        try? modelContext.save()
        dismiss()
    }
}
