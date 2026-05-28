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
        XCTAssertEqual(viewModel.draftPriority, .medium)
        XCTAssertEqual(viewModel.tasks, [PLTaskItem(id: taskID, title: "Ship baseline")])
    }

    func testAddTaskWithPriority() async {
        let taskID = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!
        let repository = PLTaskRepository(dataSource: PLInMemoryTaskDataSource(tasks: []))
        let viewModel = PLTasksViewModel(repository: repository, idProvider: { taskID })

        viewModel.draftTitle = "Escalate release"
        viewModel.draftPriority = .high
        await viewModel.addTask()

        XCTAssertEqual(
            viewModel.tasks,
            [PLTaskItem(id: taskID, title: "Escalate release", priority: .high)]
        )
        XCTAssertEqual(viewModel.draftPriority, .medium)
    }

    func testAddTaskWithDueDate() async {
        let taskID = UUID(uuidString: "88888888-8888-8888-8888-888888888888")!
        let dueDate = Date(timeIntervalSince1970: 1_800_000_000)
        let repository = PLTaskRepository(dataSource: PLInMemoryTaskDataSource(tasks: []))
        let viewModel = PLTasksViewModel(repository: repository, idProvider: { taskID })

        viewModel.draftTitle = "Schedule release"
        viewModel.isDraftDueDateEnabled = true
        viewModel.draftDueDate = dueDate
        await viewModel.addTask()

        XCTAssertEqual(
            viewModel.tasks,
            [PLTaskItem(id: taskID, title: "Schedule release", dueDate: dueDate)]
        )
        XCTAssertFalse(viewModel.isDraftDueDateEnabled)
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

    func testSortTasksByPriority() async {
        let lowTask = PLTaskItem(title: "Low", priority: .low)
        let highTask = PLTaskItem(title: "High", priority: .high)
        let mediumTask = PLTaskItem(title: "Medium", priority: .medium)
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [lowTask, highTask, mediumTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.sortMode = .priority

        XCTAssertEqual(viewModel.filteredTasks, [highTask, mediumTask, lowTask])
    }

    func testSortTasksByDueDate() async {
        let undatedTask = PLTaskItem(title: "Undated")
        let laterTask = PLTaskItem(
            title: "Later",
            dueDate: Date(timeIntervalSince1970: 1_900_000_000)
        )
        let earlierTask = PLTaskItem(
            title: "Earlier",
            dueDate: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [undatedTask, laterTask, earlierTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.sortMode = .dueDate

        XCTAssertEqual(viewModel.filteredTasks, [earlierTask, laterTask, undatedTask])
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

    func testUpdateTaskPriority() async throws {
        let taskID = UUID(uuidString: "77777777-7777-7777-7777-777777777777")!
        let task = PLTaskItem(id: taskID, title: "Draft")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [task])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.updateTask(
            id: taskID,
            title: "Final title",
            priority: .high,
            dueDate: nil
        )
        let savedTasks = try await repository.fetchTasks()
        let expectedTask = PLTaskItem(
            id: taskID,
            title: "Final title",
            priority: .high
        )

        XCTAssertEqual(viewModel.tasks, [expectedTask])
        XCTAssertEqual(savedTasks, [expectedTask])
    }

    func testUpdateTaskDueDate() async throws {
        let taskID = UUID(uuidString: "66666666-6666-6666-6666-666666666666")!
        let dueDate = Date(timeIntervalSince1970: 1_800_000_000)
        let task = PLTaskItem(id: taskID, title: "Draft")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [task])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.updateTask(
            id: taskID,
            title: "Final title",
            priority: .high,
            dueDate: dueDate
        )
        let savedTasks = try await repository.fetchTasks()
        let expectedTask = PLTaskItem(
            id: taskID,
            title: "Final title",
            priority: .high,
            dueDate: dueDate
        )

        XCTAssertEqual(viewModel.tasks, [expectedTask])
        XCTAssertEqual(savedTasks, [expectedTask])
    }

    func testUpdateTaskClearsDueDate() async throws {
        let taskID = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!
        let dueDate = Date(timeIntervalSince1970: 1_800_000_000)
        let task = PLTaskItem(id: taskID, title: "Draft", dueDate: dueDate)
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [task])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        await viewModel.updateTask(
            id: taskID,
            title: "Final title",
            priority: nil,
            dueDate: .some(nil)
        )
        let expectedTask = PLTaskItem(id: taskID, title: "Final title")

        XCTAssertEqual(viewModel.tasks, [expectedTask])
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

    func testMoveTasksRequiresManualSort() async {
        let firstTask = PLTaskItem(title: "First")
        let secondTask = PLTaskItem(title: "Second")
        let repository = PLTaskRepository(
            dataSource: PLInMemoryTaskDataSource(tasks: [firstTask, secondTask])
        )
        let viewModel = PLTasksViewModel(repository: repository)

        await viewModel.loadTasks()
        viewModel.sortMode = .priority
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
        let task = PLTaskItem(
            title: "Persisted task",
            isCompleted: true,
            priority: .high,
            dueDate: Date(timeIntervalSince1970: 1_800_000_000)
        )

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
