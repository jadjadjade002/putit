import Foundation
import SwiftData

@Model
final class SavedLocation {
    var id: UUID
    var room: String
    var container: String
    var subSpot: String
    var usageCount: Int
    var lastUsedAt: Date

    init(room: String, container: String = "", subSpot: String = "") {
        self.id = UUID()
        self.room = room
        self.container = container
        self.subSpot = subSpot
        self.usageCount = 1
        self.lastUsedAt = Date()
    }
    
    var fullDisplayPath: String {
        var parts: [String] = [room]
        if !container.isEmpty { parts.append(container) }
        if !subSpot.isEmpty { parts.append(subSpot) }
        return parts.joined(separator: " › ")
    }
}
