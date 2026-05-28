import Foundation

protocol PLMessageDataSourceProtocol: Sendable {
    func fetchThreads() async throws -> [PLMessageThread]
}

struct PLStaticMessageDataSource: PLMessageDataSourceProtocol {
    private let threads: [PLMessageThread]

    init(
        threads: [PLMessageThread] = [
            PLMessageThread(title: "Platform", preview: "Architecture baseline is ready."),
            PLMessageThread(title: "Release", preview: "Tag preparation is queued.")
        ]
    ) {
        self.threads = threads
    }

    func fetchThreads() async throws -> [PLMessageThread] {
        threads
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
            PLMessageThread(id: $0.id, title: $0.title, preview: $0.preview)
        }
    }
}

private struct PLMessageThreadResponse: Decodable {
    var id: String
    var title: String
    var preview: String
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
