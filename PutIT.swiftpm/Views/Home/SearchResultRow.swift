import SwiftUI

struct ItemCardVisualRow: View {
    let result: SearchMatchResult
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Photo with Aspect-Fit / Fill
            ZStack(alignment: .topTrailing) {
                if let imageData = result.item.currentEntry?.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.indigo.opacity(0.12))
                        .frame(height: 160)
                    
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                
                // Visual Anchor Badge
                if result.item.currentEntry?.hasVisualAnchor == true {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text(lang.text("has_pin_badge"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .padding(10)
                }
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(result.item.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if result.item.entries.count > 1 {
                        Text("\(result.item.entries.count) \(lang.text("past_spots"))")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange.opacity(0.2)))
                            .foregroundStyle(.orange)
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.indigo)
                    Text(result.item.currentEntry?.locationSummary ?? lang.text("no_location"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                if !result.matchReason.isEmpty && result.score > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                        Text(result.matchReason)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.indigo.opacity(0.12)))
                }
            }
            .padding(12)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)
    }
}
