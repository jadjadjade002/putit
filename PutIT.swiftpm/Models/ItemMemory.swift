import Foundation
import SwiftData

@Model
final class ItemMemory {
    var id: UUID
    var name: String
    var note: String
    var tags: [String]
    var category: String
    var createdAt: Date
    var lastFoundAt: Date
    var foundCount: Int
    var isSample: Bool
    
    // One-to-many relationship with cascade delete
    @Relationship(deleteRule: .cascade, inverse: \MemoryEntry.item)
    var entries: [MemoryEntry] = []

    init(
        name: String,
        category: String = "General",
        tags: [String] = [],
        note: String = "",
        createdAt: Date = Date(),
        isSample: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.tags = tags
        self.note = note
        self.createdAt = createdAt
        self.lastFoundAt = createdAt
        self.foundCount = 0
        self.isSample = isSample
    }
    
    // The active current memory entry
    var currentEntry: MemoryEntry? {
        entries.first { $0.isCurrent } ?? entries.sorted { $0.storedAt > $1.storedAt }.first
    }
    
    // Historical trail sorted from newest to oldest
    var historyTrail: [MemoryEntry] {
        entries.sorted { $0.storedAt > $1.storedAt }
    }
    
    // Mark item as moved to a new entry
    func moveToNewLocation(entry: MemoryEntry) {
        for old in entries {
            old.isCurrent = false
        }
        entry.isCurrent = true
        entry.item = self
        entries.append(entry)
        lastFoundAt = Date()
    }
    
    // Confirm item is still in same place
    func recordFoundSamePlace() {
        foundCount += 1
        lastFoundAt = Date()
    }
}
