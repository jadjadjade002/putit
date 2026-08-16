import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Bindable var item: ItemMemory
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lang = LanguageManager.shared
    
    @State private var showFoundItSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // 1. Hero Visual Anchor Banner
                heroVisualAnchorSection
                
                // 2. Location Summary Card
                locationCardSection
                
                // 3. Primary Action Buttons
                actionsSection
                
                // 4. Metadata (Notes & Tags)
                metadataSection
            }
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showFoundItSheet) {
            FoundItSheet(item: item)
        }
        .confirmationDialog(lang.text("delete_item"), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button(lang.text("delete_confirm"), role: .destructive) {
                modelContext.delete(item)
                try? modelContext.save()
                dismiss()
            }
            Button(lang.text("cancel"), role: .cancel) {}
        } message: {
            Text(lang.text("delete_item"))
        }
    }
    
    // MARK: - Hero Visual Anchor Section
    private var heroVisualAnchorSection: some View {
        ZStack {
            if let entry = item.currentEntry,
               let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData) {
                
                GeometryReader { geo in
                    let containerSize = geo.size
                    let imageSize = uiImage.size
                    let imageFitRect = aspectFitRect(imageSize: imageSize, containerSize: containerSize)
                    
                    ZStack {
                        Color.black
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: containerSize.width, height: containerSize.height)
                        
                        // Pulsing Pin placed at normalized coordinates
                        if let ax = entry.anchorX, let ay = entry.anchorY, imageFitRect.width > 0 {
                            let pinX = imageFitRect.origin.x + (CGFloat(ax) * imageFitRect.width)
                            let pinY = imageFitRect.origin.y + (CGFloat(ay) * imageFitRect.height)
                            
                            PulsingPinView(size: 44, color: .red, title: "HERE")
                                .position(x: pinX, y: pinY)
                        }
                    }
                }
                .frame(height: 330)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text(lang.text("no_photo"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Location Card
    private var locationCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(lang.text("current_location"), systemImage: "mappin.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                
                Spacer()
                
                if let storedAt = item.currentEntry?.storedAt {
                    Text(timeAgoDisplay(storedAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                if let entry = item.currentEntry {
                    HStack(spacing: 10) {
                        Image(systemName: "house.fill")
                            .foregroundStyle(.indigo)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(lang.text("room_label"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(entry.room)
                                .font(.body.bold())
                        }
                    }
                    
                    if !entry.container.isEmpty {
                        HStack(spacing: 10) {
                            Image(systemName: "archivebox.fill")
                                .foregroundStyle(.indigo)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(lang.text("container_label"))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(entry.container)
                                    .font(.body.weight(.medium))
                            }
                        }
                    }
                    
                    if !entry.subSpot.isEmpty {
                        HStack(spacing: 10) {
                            Image(systemName: "scope")
                                .foregroundStyle(.indigo)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(lang.text("subspot_label"))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(entry.subSpot)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Big Found It Button
            Button(action: { showFoundItSheet = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text(lang.text("found_it_button"))
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .green.opacity(0.3), radius: 6, y: 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Memory Trail Navigation Link
            NavigationLink(destination: MemoryTrailView(item: item)) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.indigo)
                    Text("\(lang.text("memory_trail_button")) (\(item.entries.count))")
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Metadata Section
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lang.text("notes_label"))
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                // Category & Found Stats
                HStack {
                    Label(item.category, systemImage: "tag.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.indigo.opacity(0.12)))
                        .foregroundStyle(.indigo)
                    
                    Spacer()
                    
                    if item.foundCount > 0 {
                        Text("Found \(item.foundCount)x")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                }
                
                // Tags
                if !item.tags.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.12)))
                        }
                    }
                }
                
                // Note
                if !item.note.isEmpty {
                    Divider()
                    Text(item.note)
                        .font(.body)
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal)
        }
    }
    
    private func aspectFitRect(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0 && imageSize.height > 0 && containerSize.width > 0 && containerSize.height > 0 else {
            return .zero
        }
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        if containerAspect > imageAspect {
            let height = containerSize.height
            let width = height * imageAspect
            let x = (containerSize.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: height)
        } else {
            let width = containerSize.width
            let height = width / imageAspect
            let y = (containerSize.height - height) / 2
            return CGRect(x: 0, y: y, width: width, height: height)
        }
    }
    
    private func timeAgoDisplay(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
