import SwiftUI
import SwiftData

struct SmartPackView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var lang = LanguageManager.shared
    
    @Query private var allItems: [ItemMemory]
    
    @State private var selectedTemplateIndex: Int = 0
    @State private var allTemplates: [PackTemplate] = PackService.defaultTemplates
    
    // Checked items state dictionary: [templateId_itemName: Bool]
    @State private var packedState: [String: Bool] = [:]
    
    // Custom user-added items dictionary: [templateId: [String]]
    @State private var customItems: [String: [String]] = [:]
    
    // Sheet alerts for adding custom sets and items
    @State private var showAddSetSheet: Bool = false
    @State private var showAddItemSheet: Bool = false
    @State private var newSetNameText: String = ""
    @State private var newItemText: String = ""
    
    private var currentTemplate: PackTemplate {
        guard selectedTemplateIndex < allTemplates.count else {
            return allTemplates.first ?? PackService.defaultTemplates[0]
        }
        return allTemplates[selectedTemplateIndex]
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
    
    private func localizedTemplateTitle(_ template: PackTemplate) -> String {
        switch template.id {
        case "travel": return lang.text("pack_travel")
        case "work": return lang.text("pack_work")
        case "daily": return lang.text("pack_daily")
        default: return template.title
        }
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
            .navigationTitle(lang.text("smart_pack_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            .alert(lang.text("new_pack_set_title"), isPresented: $showAddSetSheet) {
                TextField(lang.text("enter_pack_set_name"), text: $newSetNameText)
                Button(lang.text("save"), action: addNewPackSet)
                Button(lang.text("cancel"), role: .cancel) { newSetNameText = "" }
            } message: {
                Text(lang.text("enter_pack_set_name"))
            }
            .alert(lang.text("add_pack_item"), isPresented: $showAddItemSheet) {
                TextField(lang.text("enter_item_name"), text: $newItemText)
                Button(lang.text("save"), action: addCustomItem)
                Button(lang.text("cancel"), role: .cancel) { newItemText = "" }
            } message: {
                Text(localizedTemplateTitle(currentTemplate))
            }
        }
    }
    
    private func addNewPackSet() {
        let trimmed = newSetNameText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let newTpl = PackTemplate(
            id: "custom_\(UUID().uuidString.prefix(6))",
            title: trimmed,
            subtitle: lang.text("pack_custom"),
            icon: "bag.fill",
            color: .purple,
            defaultItems: []
        )
        allTemplates.append(newTpl)
        selectedTemplateIndex = allTemplates.count - 1
        newSetNameText = ""
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
                ForEach(Array(allTemplates.enumerated()), id: \.offset) { index, template in
                    let isSelected = selectedTemplateIndex == index
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTemplateIndex = index
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: template.icon)
                                .font(.subheadline)
                            Text(localizedTemplateTitle(template))
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
                
                // Add New Set Button at the end of scenario pills
                Button(action: { showAddSetSheet = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text(lang.text("new_pack_set"))
                    }
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .foregroundStyle(Color.indigo)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.indigo.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    )
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Progress Card
    private var progressCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedTemplateTitle(currentTemplate))
                        .font(.headline)
                    Text("\(lang.text("pack_progress_label")) \(packedCount) / \(activeItemList.count)")
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
            
            // Single Prominent Box Button at the bottom of checklist
            Button(action: { showAddItemSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.indigo)
                    Text(lang.text("add_pack_item"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.indigo)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.indigo.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
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
    @ObservedObject private var lang = LanguageManager.shared
    
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
            
            // Text Details
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
                            Text(lang.localizeLocationText(entry.locationSummary))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    } else {
                        Text(lang.text("no_photo_in_system"))
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
