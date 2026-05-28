import Foundation
import Observation

@Observable
@MainActor
final class PLTasksViewModel {
    var draftTitle = ""
    var draftPriority: PLTaskPriority = .medium
    var isDraftDueDateEnabled = false
    var draftDueDate = Date()
    var tasks: [PLTaskItem] = []
    var selectedFilter: PLTaskFilter = .all
    var sortMode: PLTaskSortMode = .manual
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    private let repository: any PLTaskRepositoryProtocol
    private let idProvider: @Sendable () -> UUID

    init(
        repository: any PLTaskRepositoryProtocol = PLTaskRepository(),
        idProvider: @escaping @Sendable () -> UUID = { UUID() }
    ) {
        self.repository = repository
        self.idProvider = idProvider
    }

    var activeTaskCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    var filteredTasks: [PLTaskItem] {
        let filteredTasks = switch selectedFilter {
        case .all:
            tasks
        case .active:
            tasks.filter { !$0.isCompleted }
        case .done:
            tasks.filter(\.isCompleted)
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchedTasks = if query.isEmpty {
            filteredTasks
        } else {
            filteredTasks.filter {
                $0.title.localizedCaseInsensitiveContains(query)
            }
        }

        return sortTasks(searchedTasks)
    }

    var canAddTask: Bool {
        !trimmedDraftTitle.isEmpty
    }

    var canReorderTasks: Bool {
        selectedFilter == .all
        && sortMode == .manual
        && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadTasks() async {
        isLoading = true
        errorMessage = nil

        do {
            tasks = try await repository.fetchTasks()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addTask() async {
        let title = trimmedDraftTitle
        guard !title.isEmpty else {
            return
        }

        tasks.append(
            PLTaskItem(
                id: idProvider(),
                title: title,
                priority: draftPriority,
                dueDate: isDraftDueDateEnabled ? draftDueDate : nil
            )
        )
        draftTitle = ""
        draftPriority = .medium
        isDraftDueDateEnabled = false
        draftDueDate = Date()
        await saveTasks()
    }

    func toggleTaskCompletion(id: PLTaskItem.ID) async {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        tasks[index].isCompleted.toggle()
        await saveTasks()
    }

    func updateTaskTitle(id: PLTaskItem.ID, title: String) async {
        await updateTask(id: id, title: title, priority: nil, dueDate: nil)
    }

    func updateTask(
        id: PLTaskItem.ID,
        title: String,
        priority: PLTaskPriority?,
        dueDate: Date??
    ) async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty,
              let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        tasks[index].title = trimmedTitle
        if let priority {
            tasks[index].priority = priority
        }
        if let dueDate {
            tasks[index].dueDate = dueDate
        }
        await saveTasks()
    }

    func deleteTasks(at offsets: IndexSet) async {
        for offset in offsets.sorted(by: >) {
            tasks.remove(at: offset)
        }
        await saveTasks()
    }

    func deleteFilteredTasks(at offsets: IndexSet) async {
        let idsToDelete = offsets.compactMap { offset in
            filteredTasks.indices.contains(offset) ? filteredTasks[offset].id : nil
        }
        tasks.removeAll { idsToDelete.contains($0.id) }
        await saveTasks()
    }

    func moveTasks(from offsets: IndexSet, to destination: Int) async {
        guard canReorderTasks else {
            return
        }

        let movingTasks = offsets.sorted().map { tasks[$0] }
        tasks.remove(atOffsets: offsets)

        let removedBeforeDestination = offsets.filter { $0 < destination }.count
        let adjustedDestination = destination - removedBeforeDestination
        tasks.insert(contentsOf: movingTasks, at: adjustedDestination)
        await saveTasks()
    }

    func clearCompletedTasks() async {
        tasks.removeAll { $0.isCompleted }
        await saveTasks()
    }

    private var trimmedDraftTitle: String {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sortTasks(_ tasks: [PLTaskItem]) -> [PLTaskItem] {
        switch sortMode {
        case .manual:
            return tasks
        case .priority:
            return tasks.sorted {
                if $0.priority.rank == $1.priority.rank {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.priority.rank > $1.priority.rank
            }
        case .dueDate:
            return tasks.sorted {
                switch ($0.dueDate, $1.dueDate) {
                case let (lhs?, rhs?):
                    if lhs == rhs {
                        return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    }
                    return lhs < rhs
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
        }
    }

    private func saveTasks() async {
        do {
            try await repository.saveTasks(tasks)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
