import SwiftData
import SwiftUI

@main
struct PLSwiftApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: PLStoredTask.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            PLAppView(
                taskRepository: PLTaskRepository(
                    dataSource: PLSwiftDataTaskDataSource(
                        modelContext: modelContainer.mainContext
                    )
                )
            )
        }
        .modelContainer(modelContainer)
    }
}
