import Foundation
import SwiftData

@Model
final class MemoryEntry {
    var id: UUID
    var storedAt: Date
    var room: String
    var container: String
    var subSpot: String
    var note: String
    
    // Binary photo data stored efficiently
    @Attribute(.externalStorage)
    var imageData: Data?
    
    // Normalized Visual Anchor Coordinates (0.0 to 1.0) relative to image aspect ratio
    var anchorX: Double?
    var anchorY: Double?
    
    var isCurrent: Bool
    
    // Inverse relationship to ItemMemory
    var item: ItemMemory?

    init(
        room: String,
        container: String = "",
        subSpot: String = "",
        note: String = "",
        imageData: Data? = nil,
        anchorX: Double? = nil,
        anchorY: Double? = nil,
        storedAt: Date = Date(),
        isCurrent: Bool = true
    ) {
        self.id = UUID()
        self.room = room
        self.container = container
        self.subSpot = subSpot
        self.note = note
        self.imageData = imageData
        self.anchorX = anchorX
        self.anchorY = anchorY
        self.storedAt = storedAt
        self.isCurrent = isCurrent
    }
    
    var locationSummary: String {
        var parts: [String] = [room]
        if !container.isEmpty { parts.append(container) }
        if !subSpot.isEmpty { parts.append(subSpot) }
        return parts.joined(separator: " › ")
    }
    
    var hasVisualAnchor: Bool {
        return anchorX != nil && anchorY != nil && imageData != nil
    }
}
