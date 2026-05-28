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
