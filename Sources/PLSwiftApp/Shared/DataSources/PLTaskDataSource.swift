import Foundation
import SwiftData

protocol PLTaskDataSourceProtocol: Sendable {
    func fetchTasks() async throws -> [PLTaskItem]
    func saveTasks(_ tasks: [PLTaskItem]) async throws
}

actor PLInMemoryTaskDataSource: PLTaskDataSourceProtocol {
    private var tasks: [PLTaskItem]

    init(
        tasks: [PLTaskItem] = [
            PLTaskItem(title: "Review architecture", isCompleted: true),
            PLTaskItem(title: "Prepare release tag"),
            PLTaskItem(title: "Validate core flow")
        ]
    ) {
        self.tasks = tasks
    }

    func fetchTasks() async throws -> [PLTaskItem] {
        tasks
    }

    func saveTasks(_ tasks: [PLTaskItem]) async throws {
        self.tasks = tasks
    }
}

@MainActor
final class PLSwiftDataTaskDataSource: PLTaskDataSourceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchTasks() async throws -> [PLTaskItem] {
        var descriptor = FetchDescriptor<PLStoredTask>(
            sortBy: [SortDescriptor<PLStoredTask>(\.sortIndex)]
        )
        descriptor.includePendingChanges = true

        return try modelContext.fetch(descriptor).map {
            PLTaskItem(
                id: $0.id,
                title: $0.title,
                isCompleted: $0.isCompleted,
                priority: PLTaskPriority(rawValue: $0.priorityRawValue) ?? .medium
            )
        }
    }

    func saveTasks(_ tasks: [PLTaskItem]) async throws {
        try modelContext.delete(model: PLStoredTask.self)

        for (index, task) in tasks.enumerated() {
            modelContext.insert(
                PLStoredTask(
                    id: task.id,
                    title: task.title,
                    isCompleted: task.isCompleted,
                    priorityRawValue: task.priority.rawValue,
                    sortIndex: index
                )
            )
        }

        try modelContext.save()
    }
}
