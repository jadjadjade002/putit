import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ItemMemory.createdAt, order: .reverse) private var allItems: [ItemMemory]
    @ObservedObject private var lang = LanguageManager.shared
    @StateObject private var voiceSearch = VoiceSearchManager()
    
    @State private var searchText: String = ""
    @State private var selectedCategoryIndex: Int = 0
    @State private var showRememberSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    @State private var showSmartPackSheet: Bool = false
    
    private var categoryKeys: [String] {
        ["cat_all", "cat_keys", "cat_docs", "cat_games", "cat_meds", "cat_tools"]
    }
    
    private var categoryIcons: [String] {
        ["square.grid.2x2", "key.fill", "doc.text.fill", "gamecontroller.fill", "cross.case.fill", "wrench.adjustable.fill"]
    }
    
    // Filtered items (exclude sample items)
    private var searchResults: [SearchMatchResult] {
        let validItems = allItems.filter { !$0.isSample }
        
        let categoryFiltered: [ItemMemory]
        switch selectedCategoryIndex {
        case 1: // Keys
            categoryFiltered = validItems.filter { $0.category == "Keys & Access" }
        case 2: // Documents
            categoryFiltered = validItems.filter { $0.category == "Documents" }
        case 3: // Electronics / Gaming
            categoryFiltered = validItems.filter { $0.category == "Electronics" }
        case 4: // Medicines
            categoryFiltered = validItems.filter { $0.category == "Medicines" }
        case 5: // Tools
            categoryFiltered = validItems.filter { $0.category == "Tools" }
        default:
            categoryFiltered = validItems
        }
        
        return LocalSearchService.search(query: searchText, in: categoryFiltered)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Search Bar with Voice Search
                    searchBarSection
                    
                    // Voice Search Live Indicator
                    if voiceSearch.isRecording {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("กำลังฟังเสียงพูด...")
                                .font(.caption.bold())
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // 2. Main Hero Action Card: 100% Focused on Photo & AI Auto-Pin
                    mainHeroPhotoCardSection
                    
                    // 3. Category Filter Pills
                    categoryFilterSection
                    
                    // 4. Memory Items Cards List
                    memoryItemsListSection
                }
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(lang.text("app_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape")
                            .font(.body)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Smart Pack Shortcut Button in Toolbar
                    Button(action: { showSmartPackSheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checklist")
                                .font(.body.bold())
                            Text("Smart Pack")
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.indigo.opacity(0.12)))
                        .foregroundStyle(Color.indigo)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Main + Add Photo Button in Toolbar
                    Button(action: { showRememberSheet = true }) {
                        Image(systemName: "plus")
                            .font(.body.bold())
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showRememberSheet) {
                RememberFlowView()
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
            }
            .sheet(isPresented: $showSmartPackSheet) {
                SmartPackView()
            }
            .onAppear {
                SampleDataSeeder.seedInitialDataIfNeeded(context: modelContext)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBarSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.indigo)
                .font(.headline)
            
            TextField(lang.text("search_placeholder"), text: $searchText)
                .font(.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Button(action: {
                voiceSearch.toggleListening { transcript in
                    self.searchText = transcript
                }
            }) {
                ZStack {
                    if voiceSearch.isRecording {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 36, height: 36)
                    }
                    Image(systemName: voiceSearch.isRecording ? "waveform.circle.fill" : "mic.fill")
                        .foregroundStyle(voiceSearch.isRecording ? .red : .indigo)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(voiceSearch.isRecording ? Color.red : Color.clear, lineWidth: 1.5)
        )
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    // MARK: - Big Hero Action Card: 100% Focused on Photo & AI Auto-Pin
    private var mainHeroPhotoCardSection: some View {
        Button(action: {
            showRememberSheet = true
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 48, height: 48)
                    Image(systemName: "camera.viewfinder")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(lang.text("remember_new_spot"))
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(lang.text("remember_sub"))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.indigo, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.indigo.opacity(0.28), radius: 6, y: 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
    
    // MARK: - Category Filter Pills
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(categoryKeys.enumerated()), id: \.offset) { index, key in
                    let isSelected = selectedCategoryIndex == index
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategoryIndex = index
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: categoryIcons[index])
                                .font(.caption2)
                            Text(lang.text(key))
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.indigo : Color(uiColor: .secondarySystemGroupedBackground))
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
    
    // MARK: - Memory Items Cards List
    private var memoryItemsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(searchText.isEmpty ? "\(lang.text("saved_items")) (\(searchResults.count))" : "\(lang.text("search_results")) (\(searchResults.count))")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            if searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    Text(lang.text("no_items"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("แตะปุ่มถ่ายรูปเพื่อเริ่มจำที่เก็บของชิ้นแรก")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(searchResults) { result in
                        NavigationLink(destination: ItemDetailView(item: result.item)) {
                            ItemCardVisualRow(result: result)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
