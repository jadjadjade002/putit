import SwiftUI
import SwiftData

struct SmartPackView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lang = LanguageManager.shared
    @Query(sort: \ItemMemory.createdAt, order: .reverse) private var allItems: [ItemMemory]
    
    @State private var selectedTemplateIndex: Int = 0
    @State private var packedState: [String: Bool] = [:]
    @State private var customItems: [String: [String]] = [:]
    @State private var newItemText: String = ""
    @State private var showAddItemSheet: Bool = false
    
    private var currentTemplate: PackTemplate {
        PackService.templates[selectedTemplateIndex]
    }
    
    private var activeItemList: [String] {
        let base = currentTemplate.defaultItems
        let extra = customItems[currentTemplate.id] ?? []
        return base + extra
    }
    
    private var packedCount: Int {
        activeItemList.filter { packedState["\(currentTemplate.id)_\($0)"] == true }.count
    }
    
    private var progressPercentage: Double {
        guard !activeItemList.isEmpty else { return 0.0 }
        return Double(packedCount) / Double(activeItemList.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Scenario Selector
                    scenarioPickerSection
                    
                    // Progress Card
                    progressCardSection
                    
                    // Checklist Items
                    checklistSection
                }
                .padding(.vertical, 12)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Smart Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showAddItemSheet = true }) {
                        Image(systemName: "plus")
                            .font(.body.bold())
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text(lang.text("done"))
                            .font(.body.bold())
                            .foregroundStyle(Color.indigo)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .alert("เพิ่มของในรายการจัดของ", isPresented: $showAddItemSheet) {
                TextField("ชื่อสิ่งของ เช่น แว่นตา, ยาประจำตัว", text: $newItemText)
                Button("เพิ่ม", action: addCustomItem)
                Button("ยกเลิก", role: .cancel) { newItemText = "" }
            } message: {
                Text("เพิ่มสิ่งของในรายการ \(currentTemplate.title)")
            }
        }
    }
    
    private func addCustomItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var current = customItems[currentTemplate.id] ?? []
        if !current.contains(trimmed) {
            current.append(trimmed)
            customItems[currentTemplate.id] = current
        }
        newItemText = ""
    }
    
    // MARK: - Scenario Picker
    private var scenarioPickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(PackService.templates.enumerated()), id: \.offset) { index, template in
                    let isSelected = selectedTemplateIndex == index
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTemplateIndex = index
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: template.icon)
                                .font(.subheadline)
                            Text(template.title.components(separatedBy: " (").first ?? template.title)
                                .font(.subheadline.bold())
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isSelected ? template.color : Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Progress Card
    private var progressCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentTemplate.title)
                        .font(.headline)
                    Text("เตรียมของแล้ว \(packedCount) จาก \(activeItemList.count) ชิ้น")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(.title3.bold())
                    .foregroundStyle(progressPercentage == 1.0 ? .green : currentTemplate.color)
            }
            
            ProgressView(value: progressPercentage)
                .tint(progressPercentage == 1.0 ? .green : currentTemplate.color)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // MARK: - Checklist Section
    private var checklistSection: some View {
        VStack(spacing: 10) {
            ForEach(activeItemList, id: \.self) { itemName in
                let key = "\(currentTemplate.id)_\(itemName)"
                let isPacked = packedState[key] ?? false
                let matchedItem = findMatchingSavedItem(for: itemName)
                
                PackItemRow(
                    itemName: itemName,
                    isPacked: isPacked,
                    matchedItem: matchedItem,
                    onToggle: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            packedState[key] = !isPacked
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func findMatchingSavedItem(for name: String) -> ItemMemory? {
        let cleanName = name.lowercased().trimmingCharacters(in: .whitespaces)
        return allItems.first(where: { item in
            !item.isSample && (
                item.name.localizedCaseInsensitiveContains(cleanName) ||
                item.category.localizedCaseInsensitiveContains(cleanName) ||
                item.tags.contains(where: { $0.localizedCaseInsensitiveContains(cleanName) })
            )
        })
    }
}

// MARK: - Pack Item Row
struct PackItemRow: View {
    let itemName: String
    let isPacked: Bool
    let matchedItem: ItemMemory?
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox with large tap target
            Button(action: onToggle) {
                Image(systemName: isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isPacked ? .green : .secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Text Details (Tapping text also toggles checkbox!)
            Button(action: onToggle) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(itemName)
                        .font(.body.weight(isPacked ? .regular : .semibold))
                        .strikethrough(isPacked, color: .secondary)
                        .foregroundStyle(isPacked ? .secondary : .primary)
                    
                    if let item = matchedItem, let entry = item.currentEntry {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                                .foregroundStyle(.indigo)
                            Text(entry.locationSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    } else {
                        Text("ยังไม่มีรูปหรือจุดปักในระบบ")
                            .font(.caption2)
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // If item has visual anchor, show link to view spot!
            if let item = matchedItem {
                NavigationLink(destination: ItemDetailView(item: item)) {
                    HStack(spacing: 4) {
                        if let imgData = item.currentEntry?.imageData, let uiImg = UIImage(data: imgData) {
                            Image(uiImage: uiImg)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                )
                        } else {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 44, height: 44)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(isPacked ? 0.75 : 1.0)
    }
}
