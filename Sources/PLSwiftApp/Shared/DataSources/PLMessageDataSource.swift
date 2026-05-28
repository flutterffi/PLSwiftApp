import Foundation

protocol PLMessageDataSourceProtocol: Sendable {
    func fetchThreads() async throws -> [PLMessageThread]
    func saveThreads(_ threads: [PLMessageThread]) async throws
}

actor PLStaticMessageDataSource: PLMessageDataSourceProtocol {
    private var threads: [PLMessageThread]

    init(
        threads: [PLMessageThread] = [
            PLMessageThread(title: "Platform", preview: "Architecture baseline is ready."),
            PLMessageThread(title: "Release", preview: "Tag preparation is queued.", isUnread: false)
        ]
    ) {
        self.threads = threads
    }

    func fetchThreads() async throws -> [PLMessageThread] {
        threads
    }

    func saveThreads(_ threads: [PLMessageThread]) async throws {
        self.threads = threads
    }
}

struct PLRemoteMessageDataSource: PLMessageDataSourceProtocol {
    private let apiClient: PLAPIClient
    private let endpoint: any PLEndpoint

    init(
        apiClient: PLAPIClient = .live,
        endpoint: any PLEndpoint = PLMessageEndpoint.threads
    ) {
        self.apiClient = apiClient
        self.endpoint = endpoint
    }

    func fetchThreads() async throws -> [PLMessageThread] {
        let response: [PLMessageThreadResponse] = try await apiClient.request(endpoint)
        return response.map {
            PLMessageThread(
                id: $0.id,
                title: $0.title,
                preview: $0.preview,
                isUnread: $0.isUnread ?? true
            )
        }
    }

    func saveThreads(_ threads: [PLMessageThread]) async throws {}
}

private struct PLMessageThreadResponse: Decodable {
    var id: String
    var title: String
    var preview: String
    var isUnread: Bool?
}

enum PLMessageEndpoint: PLEndpoint {
    case threads

    var url: URL {
        URL(string: "https://api.example.com/messages/threads")!
    }

    var method: PLHTTPMethod {
        .get
    }

    var headers: [String: String] {
        ["Accept": "application/json"]
    }
}
