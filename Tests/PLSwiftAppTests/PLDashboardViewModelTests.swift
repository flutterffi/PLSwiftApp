@testable import PLSwiftApp
import XCTest

@MainActor
final class PLDashboardViewModelTests: XCTestCase {
    func testLoadSummary() async {
        let taskRepository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(
                tasks: [
                    PLTaskItem(title: "Complete", isCompleted: true),
                    PLTaskItem(title: "Open")
                ]
            )
        )
        let messageRepository = PLMessageRepository(
            dataSource: PLStaticMessageDataSource(
                threads: [
                    PLMessageThread(title: "Platform", preview: "Ready."),
                    PLMessageThread(title: "Release", preview: "Queued.")
                ]
            )
        )
        let viewModel = PLDashboardViewModel(
            taskRepository: taskRepository,
            messageRepository: messageRepository
        )

        await viewModel.loadSummary()

        XCTAssertEqual(
            viewModel.summaryItems,
            [
                PLDashboardSummary(title: "Open Tasks", value: "1"),
                PLDashboardSummary(title: "Messages", value: "2"),
                PLDashboardSummary(title: "Status", value: "Active")
            ]
        )
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadSummaryReportsClearStatus() async {
        let taskRepository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(
                tasks: [
                    PLTaskItem(title: "Complete", isCompleted: true)
                ]
            )
        )
        let viewModel = PLDashboardViewModel(
            taskRepository: taskRepository,
            messageRepository: PLMessageRepository(
                dataSource: PLStaticMessageDataSource(threads: [])
            )
        )

        await viewModel.loadSummary()

        XCTAssertEqual(
            viewModel.summaryItems,
            [
                PLDashboardSummary(title: "Open Tasks", value: "0"),
                PLDashboardSummary(title: "Messages", value: "0"),
                PLDashboardSummary(title: "Status", value: "Clear")
            ]
        )
    }
}
