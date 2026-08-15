import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var langManager = LanguageManager.shared
    
    @State private var showLanguageSlideSheet: Bool = false
    @State private var showResetAlert: Bool = false
    @State private var resetSuccess: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                // Section 1: Language
                Section(header: Text(langManager.text("language_section"))) {
                    Button(action: {
                        showLanguageSlideSheet = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.indigo.opacity(0.12))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "globe")
                                    .foregroundStyle(.indigo)
                                    .font(.subheadline)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(langManager.currentLanguage.displayName)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                // Section 2: Demo Guide
                Section(header: Text(langManager.text("demo_guide_section"))) {
                    VStack(alignment: .leading, spacing: 10) {
                        demoStepRow(number: "1", title: "AI Auto-Pin", desc: "ถ่ายรูปสิ่งของ AI จะตรวจจับและปักหมุดตำแหน่งให้อัตโนมัติ")
                        demoStepRow(number: "2", title: "Smart Pack", desc: "ระบบจัดของอัจฉริยะ ดึงรูปและตำแหน่งของที่ต้องเตรียมทันที")
                        demoStepRow(number: "3", title: "Voice Search", desc: "ค้นหาด้วยเสียงพูดภาษาธรรมชาติ ค้นเจอทันที")
                        demoStepRow(number: "4", title: "Memory Trail", desc: "บันทึกและติดตามประวัติการย้ายที่เก็บย้อนหลัง")
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 3: Demo Data Reset
                Section(header: Text("Demo Data")) {
                    Button(role: .destructive, action: { showResetAlert = true }) {
                        Label(langManager.text("reset_data"), systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                // Section 4: Architecture & Privacy
                Section(header: Text(langManager.text("tech_privacy"))) {
                    HStack {
                        Label("Network Status", systemImage: "antenna.radiowaves.left.and.right.slash")
                        Spacer()
                        Text(langManager.text("offline_status"))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("AI Engine", systemImage: "brain.head.profile")
                        Spacer()
                        Text("Apple Neural Engine (1,300+ Vision)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Local Storage", systemImage: "internaldrive.fill")
                        Spacer()
                        Text("Apple SwiftData")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(langManager.text("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text(langManager.text("done"))
                            .font(.body.bold())
                            .foregroundStyle(Color.indigo)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showLanguageSlideSheet) {
                LanguagePickerSlideSheet()
            }
            .alert("Reset Demo Data?", isPresented: $showResetAlert) {
                Button("Reset to Default Demo Data", role: .destructive) {
                    SampleDataSeeder.resetAndRepopulateDemoData(context: modelContext)
                    resetSuccess = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will restore sample items with Visual Anchors.")
            }
            .alert("Demo Data Reset!", isPresented: $resetSuccess) {
                Button("OK") {}
            } message: {
                Text("Sample items have been restored.")
            }
        }
    }
    
    private func demoStepRow(number: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.indigo))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Slide Sheet for 15 Languages
struct LanguagePickerSlideSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var langManager = LanguageManager.shared
    @State private var filterQuery: String = ""
    
    private var filteredLanguages: [AppLanguage] {
        if filterQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return AppLanguage.allCases
        }
        return AppLanguage.allCases.filter {
            $0.displayName.localizedCaseInsensitiveContains(filterQuery) ||
            $0.rawValue.localizedCaseInsensitiveContains(filterQuery)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredLanguages) { lang in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                langManager.setLanguage(lang)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                dismiss()
                            }
                        }) {
                            HStack(spacing: 14) {
                                Text(lang.displayName)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if langManager.currentLanguage == lang {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.indigo)
                                }
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Select Language (15)")
                }
            }
            .searchable(text: $filterQuery, prompt: "Search language / ค้นหาภาษา...")
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text(langManager.text("done"))
                            .font(.body.bold())
                            .foregroundStyle(Color.indigo)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
