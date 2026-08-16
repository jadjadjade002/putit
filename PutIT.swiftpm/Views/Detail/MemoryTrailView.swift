import SwiftUI

struct MemoryTrailView: View {
    let item: ItemMemory
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Banner
                VStack(alignment: .leading, spacing: 6) {
                    Text(lang.text("memory_trail_button"))
                        .font(.title2.bold())
                    Text("\(lang.text("item_name_label")): \(item.name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Timeline Entries
                VStack(alignment: .leading, spacing: 0) {
                    let history = item.historyTrail
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, entry in
                        HStack(alignment: .top, spacing: 16) {
                            // Timeline Pillar / Dot
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(entry.isCurrent ? Color.green : Color.secondary.opacity(0.5))
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(color: entry.isCurrent ? .green.opacity(0.4) : .clear, radius: 4)
                                
                                if index < history.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.25))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 20)
                            
                            // Entry Card
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(entry.isCurrent ? lang.text("current_location") : lang.text("past_spots"))
                                        .font(.caption.bold())
                                        .foregroundStyle(entry.isCurrent ? .green : .secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule().fill(entry.isCurrent ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
                                        )
                                    
                                    Spacer()
                                    
                                    Text(entry.storedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(lang.localizeLocationText(entry.locationSummary))
                                    .font(.headline)
                                
                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                // Mini Photo with Anchor preview
                                if let imageData = entry.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    ZStack {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 140)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        if let ax = entry.anchorX, let ay = entry.anchorY {
                                            GeometryReader { geo in
                                                PulsingPinView(size: 24, color: entry.isCurrent ? .red : .orange)
                                                    .position(x: CGFloat(ax) * geo.size.width, y: CGFloat(ay) * geo.size.height)
                                            }
                                        }
                                    }
                                    .frame(height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(lang.text("memory_trail_button"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
