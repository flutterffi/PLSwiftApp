import Foundation

struct PLAPIClient: Sendable {
    var send: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    func request<T: Decodable>(_ endpoint: any PLEndpoint) async throws -> T {
        let data = try await requestData(endpoint)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func requestData(_ endpoint: any PLEndpoint) async throws -> Data {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.httpBody = endpoint.body

        let (data, response) = try await send(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PLNetworkError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw PLNetworkError.httpStatus(httpResponse.statusCode)
        }

        return data
    }
}

extension PLAPIClient {
    static let live = PLAPIClient { request in
        try await URLSession.shared.data(for: request)
    }
}

enum PLNetworkError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int)
}
