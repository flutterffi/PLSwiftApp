import Foundation
import Observation

@Observable
@MainActor
final class PLTasksViewModel {
    var draftTitle = ""
    var tasks: [PLTaskItem] = []
    var selectedFilter: PLTaskFilter = .all
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
        switch selectedFilter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .done:
            return tasks.filter(\.isCompleted)
        }
    }

    var canAddTask: Bool {
        !trimmedDraftTitle.isEmpty
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

        tasks.append(PLTaskItem(id: idProvider(), title: title))
        draftTitle = ""
        await saveTasks()
    }

    func toggleTaskCompletion(id: PLTaskItem.ID) async {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return
        }

        tasks[index].isCompleted.toggle()
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

    func clearCompletedTasks() async {
        tasks.removeAll { $0.isCompleted }
        await saveTasks()
    }

    private var trimmedDraftTitle: String {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveTasks() async {
        do {
            try await repository.saveTasks(tasks)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
