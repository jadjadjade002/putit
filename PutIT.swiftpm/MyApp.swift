import SwiftUI
import SwiftData

@main
struct PutITApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                ItemMemory.self,
                MemoryEntry.self,
                SavedLocation.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let containerInstance = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = containerInstance
            
            // Clean out sample demo data on launch so user starts with a clean slate
            let mainContext = containerInstance.mainContext
            Task { @MainActor in
                SampleDataSeeder.cleanSampleData(context: mainContext)
            }
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(container)
    }
}
