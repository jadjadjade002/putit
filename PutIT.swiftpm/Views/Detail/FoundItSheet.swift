import SwiftUI
import SwiftData
import PhotosUI

struct FoundItSheet: View {
    @Bindable var item: ItemMemory
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lang = LanguageManager.shared
    
    @State private var mode: FoundMode = .choice
    
    // New location fields
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var showCameraSheet: Bool = false
    @State private var anchorX: Double?
    @State private var anchorY: Double?
    
    @State private var room: String = ""
    @State private var container: String = ""
    @State private var subSpot: String = ""
    @State private var moveReason: String = ""
    
    let roomChipKeys: [String] = ["room_bedroom", "room_living", "room_kitchen", "room_front", "room_office", "room_garage"]
    let containerChipKeys: [String] = ["cont_drawer", "cont_desk", "cont_safe", "cont_shelf", "cont_closet", "cont_hanger"]
    let subSpotChipKeys: [String] = ["spot_top", "spot_bottom", "spot_tray", "spot_left", "spot_right", "spot_organizer"]
    
    enum FoundMode {
        case choice
        case moving
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                if mode == .choice {
                    choiceView
                } else {
                    relocationFormView
                }
            }
            .navigationTitle(mode == .choice ? lang.text("found_it_button") : lang.text("relocate_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        if mode == .moving {
                            withAnimation { mode = .choice }
                        } else {
                            dismiss()
                        }
                    }) {
                        Text(mode == .choice ? lang.text("cancel") : lang.text("back"))
                            .font(.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                if mode == .moving {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { saveRelocation() }) {
                            Text(lang.text("save"))
                                .font(.body.bold())
                                .foregroundStyle(room.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary : Color.indigo)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(room.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showCameraSheet) {
                CameraPicker(selectedImage: $pickedImage)
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.pickedImage = uiImage
                            self.anchorX = nil
                            self.anchorY = nil
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Choice View
    private var choiceView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)
            }
            
            VStack(spacing: 6) {
                Text(lang.text("found_it_button"))
                    .font(.title2.bold())
                Text("\(lang.text("item_name_label")): \(item.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 14) {
                // Option 1: Same Place
                Button(action: {
                    item.recordFoundSamePlace()
                    try? modelContext.save()
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.text("still_here"))
                                .font(.headline)
                            Text(item.currentEntry?.locationSummary ?? "")
                                .font(.caption)
                                .opacity(0.85)
                        }
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                // Option 2: Moved to a New Spot
                Button(action: {
                    withAnimation { mode = .moving }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lang.text("relocate_new_spot"))
                                .font(.headline)
                            Text(lang.text("remember_flow_title"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.primary)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Relocation Form
    private var relocationFormView: some View {
        ScrollView {
            VStack(spacing: 18) {
                if let img = pickedImage {
                    VisualAnchorPicker(image: img, anchorX: $anchorX, anchorY: $anchorY)
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Button(action: { showCameraSheet = true }) {
                            Label(lang.text("retake_photo"), systemImage: "camera")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(lang.text("choose_other_photo"), systemImage: "photo")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                } else {
                    HStack(spacing: 12) {
                        Button(action: { showCameraSheet = true }) {
                            Label(lang.text("take_photo"), systemImage: "camera.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.indigo)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(lang.text("choose_library"), systemImage: "photo.on.rectangle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
                
                // Room
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.text("select_room"))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(roomChipKeys, id: \.self) { key in
                            let r = lang.text(key)
                            Button(action: { self.room = r }) {
                                Text(r)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(room == r ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
                                    .foregroundStyle(room == r ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    TextField(lang.text("select_room"), text: $room)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                // Container
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.text("select_container"))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(containerChipKeys, id: \.self) { key in
                            let c = lang.text(key)
                            Button(action: { self.container = c }) {
                                Text(c)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(container == c ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
                                    .foregroundStyle(container == c ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    TextField(lang.text("select_container"), text: $container)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                // SubSpot
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.text("select_subspot"))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(subSpotChipKeys, id: \.self) { key in
                            let s = lang.text(key)
                            Button(action: { self.subSpot = s }) {
                                Text(s)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(subSpot == s ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
                                    .foregroundStyle(subSpot == s ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    TextField(lang.text("select_subspot"), text: $subSpot)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
            }
            .padding(.top, 12)
        }
    }
    
    private func saveRelocation() {
        let trimmedRoom = room.trimmingCharacters(in: .whitespaces)
        guard !trimmedRoom.isEmpty else { return }
        
        var imageData: Data? = nil
        if let img = pickedImage {
            imageData = ImageManager.prepareImageForStorage(img)
        }
        
        let newEntry = MemoryEntry(
            room: trimmedRoom,
            container: container.trimmingCharacters(in: .whitespaces),
            subSpot: subSpot.trimmingCharacters(in: .whitespaces),
            note: moveReason.trimmingCharacters(in: .whitespaces),
            imageData: imageData,
            anchorX: anchorX,
            anchorY: anchorY,
            storedAt: Date(),
            isCurrent: true
        )
        
        item.moveToNewLocation(entry: newEntry)
        
        let loc = SavedLocation(
            room: trimmedRoom,
            container: container.trimmingCharacters(in: .whitespaces),
            subSpot: subSpot.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(loc)
        
        try? modelContext.save()
        dismiss()
    }
}
