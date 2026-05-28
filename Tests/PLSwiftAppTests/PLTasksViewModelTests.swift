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

    func testSearchTasks() async {
        let firstTask = PLTaskItem(title: "Review architecture")
        let secondTask = PLTaskItem(title: "Prepare release")
        let thirdTask = PLTaskItem(title: "Archive release notes", isCompleted: true)
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [firstTask, secondTask, thirdTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.searchText = "release"

        XCTAssertEqual(viewModel.filteredTasks, [secondTask, thirdTask])
    }

    func testSearchCombinesWithFilter() async {
        let activeTask = PLTaskItem(title: "Prepare release")
        let doneTask = PLTaskItem(title: "Archive release notes", isCompleted: true)
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [activeTask, doneTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.selectedFilter = .done
        viewModel.searchText = "release"

        XCTAssertEqual(viewModel.filteredTasks, [doneTask])
    }

    func testUpdateTaskTitle() async throws {
        let taskID = UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!
        let task = PLTaskItem(id: taskID, title: "Draft")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [task])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.updateTaskTitle(id: taskID, title: "  Final title  ")
        let savedTasks = try await repository.fetchTasks()

        XCTAssertEqual(viewModel.tasks, [PLTaskItem(id: taskID, title: "Final title")])
        XCTAssertEqual(savedTasks, [PLTaskItem(id: taskID, title: "Final title")])
    }

    func testUpdateTaskTitleIgnoresEmptyTitle() async throws {
        let taskID = UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!
        let task = PLTaskItem(id: taskID, title: "Keep")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [task])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.updateTaskTitle(id: taskID, title: "   ")

        XCTAssertEqual(viewModel.tasks, [task])
    }

    func testMoveTasks() async throws {
        let firstTask = PLTaskItem(title: "First")
        let secondTask = PLTaskItem(title: "Second")
        let thirdTask = PLTaskItem(title: "Third")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [firstTask, secondTask, thirdTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.moveTasks(from: IndexSet(integer: 0), to: 3)
        let savedTasks = try await repository.fetchTasks()

        XCTAssertEqual(viewModel.tasks, [secondTask, thirdTask, firstTask])
        XCTAssertEqual(savedTasks, [secondTask, thirdTask, firstTask])
    }

    func testMoveTasksRequiresAllFilter() async {
        let firstTask = PLTaskItem(title: "First")
        let secondTask = PLTaskItem(title: "Second")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [firstTask, secondTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.selectedFilter = .active
        await viewModel.moveTasks(from: IndexSet(integer: 0), to: 2)

        XCTAssertEqual(viewModel.tasks, [firstTask, secondTask])
    }

    func testMoveTasksRequiresEmptySearch() async {
        let firstTask = PLTaskItem(title: "First")
        let secondTask = PLTaskItem(title: "Second")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [firstTask, secondTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.searchText = "first"
        await viewModel.moveTasks(from: IndexSet(integer: 0), to: 2)

        XCTAssertEqual(viewModel.tasks, [firstTask, secondTask])
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

    func testSwiftDataDataSourcePreservesTaskOrder() async throws {
        let container = try ModelContainer(
            for: PLStoredTask.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let dataSource = PLSwiftDataTaskDataSource(modelContext: container.mainContext)
        let repository = PLTaskRepository(dataSource: dataSource)
        let firstTask = PLTaskItem(title: "First")
        let secondTask = PLTaskItem(title: "Second")

        try await repository.saveTasks([secondTask, firstTask])
        let loadedTasks = try await repository.fetchTasks()

        XCTAssertEqual(loadedTasks, [secondTask, firstTask])
    }
}
