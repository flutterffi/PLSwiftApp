protocol PLMessageRepositoryProtocol: Sendable {
    func fetchThreads() async throws -> [PLMessageThread]
}

struct PLMessageRepository: PLMessageRepositoryProtocol {
    private let dataSource: any PLMessageDataSourceProtocol

    init(dataSource: any PLMessageDataSourceProtocol = PLStaticMessageDataSource()) {
        self.dataSource = dataSource
    }

    func fetchThreads() async throws -> [PLMessageThread] {
        try await dataSource.fetchThreads()
    }
}
