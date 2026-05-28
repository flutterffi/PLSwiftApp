@testable import PLSwiftApp
import SwiftData
import XCTest

@MainActor
final class PLTasksViewModelTests: XCTestCase {
    func testLoadTasks() async {
        let task = PLTaskItem(title: "Loaded task")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [task])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()

        XCTAssertEqual(viewModel.tasks, [task])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testAddTask() async {
        let taskID = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
        let repository = PLTaskRepository(dataSource: PLInMemoryTaskDataSource(tasks: []))
        let viewModel = PLTasksViewModel(repository: repository, idProvider: { taskID })

        viewModel.draftTitle = "Ship baseline"
        await viewModel.addTask()

        XCTAssertEqual(viewModel.draftTitle, "")
        XCTAssertEqual(viewModel.tasks, [PLTaskItem(id: taskID, title: "Ship baseline")])
    }

    func testToggleDeleteAndClearTasks() async {
        let firstTaskID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let secondTaskID = UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(
                tasks: [
                    PLTaskItem(id: firstTaskID, title: "Done later"),
                    PLTaskItem(id: secondTaskID, title: "Remove later")
                ]
            )
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.toggleTaskCompletion(id: firstTaskID)
        await viewModel.deleteTasks(at: IndexSet(integer: 1))
        await viewModel.clearCompletedTasks()

        XCTAssertEqual(viewModel.tasks, [])
    }

    func testFilteredTasks() async {
        let activeTask = PLTaskItem(title: "Open")
        let doneTask = PLTaskItem(title: "Done", isCompleted: true)
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [activeTask, doneTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()

        viewModel.selectedFilter = .active
        XCTAssertEqual(viewModel.filteredTasks, [activeTask])

        viewModel.selectedFilter = .done
        XCTAssertEqual(viewModel.filteredTasks, [doneTask])

        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.filteredTasks, [activeTask, doneTask])
    }

    func testDeleteFilteredTasks() async throws {
        let firstTask = PLTaskItem(title: "Keep")
        let secondTask = PLTaskItem(title: "Delete", isCompleted: true)
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [firstTask, secondTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.selectedFilter = .done
        await viewModel.deleteFilteredTasks(at: IndexSet(integer: 0))
        let savedTasks = try await repository.fetchTasks()

        XCTAssertEqual(viewModel.tasks, [firstTask])
        XCTAssertEqual(savedTasks, [firstTask])
    }

    func testSwiftDataDataSourcePersistsTasks() async throws {
        let container = try ModelContainer(
            for: PLStoredTask.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let dataSource = PLSwiftDataTaskDataSource(modelContext: container.mainContext)
        let repository = PLTaskRepository(dataSource: dataSource)
        let task = PLTaskItem(title: "Persisted task", isCompleted: true)

        try await repository.saveTasks([task])
        let loadedTasks = try await repository.fetchTasks()

        XCTAssertEqual(loadedTasks, [task])
    }
}
