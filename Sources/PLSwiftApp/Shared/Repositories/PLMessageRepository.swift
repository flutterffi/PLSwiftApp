protocol PLMessageRepositoryProtocol: Sendable {
    func fetchThreads() async throws -> [PLMessageThread]
    func saveThreads(_ threads: [PLMessageThread]) async throws
}

struct PLMessageRepository: PLMessageRepositoryProtocol {
    private let dataSource: any PLMessageDataSourceProtocol

    init(dataSource: any PLMessageDataSourceProtocol = PLStaticMessageDataSource()) {
        self.dataSource = dataSource
    }

    func fetchThreads() async throws -> [PLMessageThread] {
        try await dataSource.fetchThreads()
    }

    func saveThreads(_ threads: [PLMessageThread]) async throws {
        try await dataSource.saveThreads(threads)
    }
}
