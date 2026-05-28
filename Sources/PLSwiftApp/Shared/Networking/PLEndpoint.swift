import Foundation

protocol PLEndpoint: Sendable {
    var url: URL { get }
    var method: PLHTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension PLEndpoint {
    var headers: [String: String] {
        [:]
    }

    var body: Data? {
        nil
    }
}
