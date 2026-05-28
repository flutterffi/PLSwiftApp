protocol PLTaskRepositoryProtocol: Sendable {
    func fetchTasks() async throws -> [PLTaskItem]
    func saveTasks(_ tasks: [PLTaskItem]) async throws
}

struct PLTaskRepository: PLTaskRepositoryProtocol {
    private let dataSource: any PLTaskDataSourceProtocol

    init(dataSource: any PLTaskDataSourceProtocol = PLInMemoryTaskDataSource()) {
        self.dataSource = dataSource
    }

    func fetchTasks() async throws -> [PLTaskItem] {
        try await dataSource.fetchTasks()
    }

    func saveTasks(_ tasks: [PLTaskItem]) async throws {
        try await dataSource.saveTasks(tasks)
    }
}
