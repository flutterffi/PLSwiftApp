@testable import PLSwiftApp
import Foundation
import XCTest

@MainActor
final class PLMessagesViewModelTests: XCTestCase {
    func testLoadThreads() async {
        let thread = PLMessageThread(title: "Build", preview: "Async messages are ready.")
        let repository = PLMessageRepository(
            dataSource: PLStaticMessageDataSource(threads: [thread])
        )
        let viewModel = PLMessagesViewModel(repository: repository)

        await viewModel.loadThreads()

        XCTAssertEqual(viewModel.threads, [thread])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchThreads() async {
        let firstThread = PLMessageThread(title: "Build", preview: "Async messages are ready.")
        let secondThread = PLMessageThread(title: "Release", preview: "Tag is ready.")
        let repository = PLMessageRepository(
            dataSource: PLStaticMessageDataSource(threads: [firstThread, secondThread])
        )
        let viewModel = PLMessagesViewModel(repository: repository)

        await viewModel.loadThreads()
        viewModel.searchText = "tag"

        XCTAssertEqual(viewModel.filteredThreads, [secondThread])
    }

    func testUnreadFilter() async {
        let unreadThread = PLMessageThread(title: "Build", preview: "Ready.")
        let readThread = PLMessageThread(title: "Release", preview: "Queued.", isUnread: false)
        let repository = PLMessageRepository(
            dataSource: PLStaticMessageDataSource(threads: [unreadThread, readThread])
        )
        let viewModel = PLMessagesViewModel(repository: repository)

        await viewModel.loadThreads()
        viewModel.showsUnreadOnly = true

        XCTAssertEqual(viewModel.unreadThreadCount, 1)
        XCTAssertEqual(viewModel.filteredThreads, [unreadThread])
    }

    func testToggleReadStatus() async {
        let thread = PLMessageThread(id: "build", title: "Build", preview: "Ready.")
        let repository = PLMessageRepository(
            dataSource: PLStaticMessageDataSource(threads: [thread])
        )
        let viewModel = PLMessagesViewModel(repository: repository)

        await viewModel.loadThreads()
        viewModel.toggleReadStatus(id: "build")

        XCTAssertEqual(
            viewModel.threads,
            [PLMessageThread(id: "build", title: "Build", preview: "Ready.", isUnread: false)]
        )
    }

    func testRemoteDataSourceDecodesThreads() async throws {
        let endpoint = PLTestEndpoint()
        let payload = """
        [
          {
            "id": "platform",
            "title": "Platform",
            "preview": "Remote messages are ready."
            ,
            "isUnread": false
          }
        ]
        """.data(using: .utf8)!
        let apiClient = PLAPIClient { request in
            XCTAssertEqual(request.url, endpoint.url)
            XCTAssertEqual(request.httpMethod, "GET")
            return (
                payload,
                HTTPURLResponse(
                    url: endpoint.url,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        }
        let dataSource = PLRemoteMessageDataSource(
            apiClient: apiClient,
            endpoint: endpoint
        )

        let threads = try await dataSource.fetchThreads()

        XCTAssertEqual(
            threads,
            [
                PLMessageThread(
                    id: "platform",
                    title: "Platform",
                    preview: "Remote messages are ready.",
                    isUnread: false
                )
            ]
        )
    }

    func testAPIClientRejectsHTTPError() async {
        let endpoint = PLTestEndpoint()
        let apiClient = PLAPIClient { _ in
            (
                Data(),
                HTTPURLResponse(
                    url: endpoint.url,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!
            )
        }

        do {
            let _: Data = try await apiClient.requestData(endpoint)
            XCTFail("Expected HTTP error")
        } catch let error as PLNetworkError {
            XCTAssertEqual(error, .httpStatus(500))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct PLTestEndpoint: PLEndpoint {
    var url: URL {
        URL(string: "https://api.example.com/test")!
    }

    var method: PLHTTPMethod {
        .get
    }
}
