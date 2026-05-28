@testable import PLSwiftApp
import XCTest

@MainActor
final class PLDashboardViewModelTests: XCTestCase {
    func testLoadSummary() async {
        let today = Date(timeIntervalSince1970: 1_800_000_000)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let taskRepository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(
                tasks: [
                    PLTaskItem(title: "Complete", isCompleted: true),
                    PLTaskItem(title: "Open"),
                    PLTaskItem(title: "High", priority: .high),
                    PLTaskItem(title: "Due Today", dueDate: today),
                    PLTaskItem(title: "Overdue", dueDate: yesterday)
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
            messageRepository: messageRepository,
            dateProvider: { today }
        )

        await viewModel.loadSummary()

        XCTAssertEqual(
            viewModel.summaryItems,
            [
                PLDashboardSummary(title: "Open Tasks", value: "4"),
                PLDashboardSummary(title: "High Priority", value: "1"),
                PLDashboardSummary(title: "Due Today", value: "1"),
                PLDashboardSummary(title: "Overdue", value: "1"),
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
                PLDashboardSummary(title: "High Priority", value: "0"),
                PLDashboardSummary(title: "Due Today", value: "0"),
                PLDashboardSummary(title: "Overdue", value: "0"),
                PLDashboardSummary(title: "Messages", value: "0"),
                PLDashboardSummary(title: "Status", value: "Clear")
            ]
        )
    }
}
