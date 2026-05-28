import Foundation
import Observation

@MainActor
@Observable
final class PLDashboardViewModel {
    var title = "Operations"
    var summaryItems: [PLDashboardSummary] = []
    var isLoading = false
    var errorMessage: String?

    private let taskRepository: any PLTaskRepositoryProtocol
    private let messageRepository: any PLMessageRepositoryProtocol
    private let dateProvider: @Sendable () -> Date

    init(
        taskRepository: any PLTaskRepositoryProtocol = PLTaskRepository(),
        messageRepository: any PLMessageRepositoryProtocol = PLMessageRepository(),
        dateProvider: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.taskRepository = taskRepository
        self.messageRepository = messageRepository
        self.dateProvider = dateProvider
    }

    func loadSummary() async {
        isLoading = true
        errorMessage = nil

        do {
            async let tasks = taskRepository.fetchTasks()
            async let threads = messageRepository.fetchThreads()
            let (loadedTasks, loadedThreads) = try await (tasks, threads)
            let openTaskCount = loadedTasks.filter { !$0.isCompleted }.count
            let highPriorityTaskCount = loadedTasks.filter {
                !$0.isCompleted && $0.priority == .high
            }.count
            let dueTodayTaskCount = loadedTasks.filter {
                guard !$0.isCompleted, let dueDate = $0.dueDate else {
                    return false
                }
                return Calendar.current.isDate(dueDate, inSameDayAs: dateProvider())
            }.count
            let overdueTaskCount = loadedTasks.filter {
                guard !$0.isCompleted, let dueDate = $0.dueDate else {
                    return false
                }
                return dueDate < Calendar.current.startOfDay(for: dateProvider())
            }.count

            summaryItems = [
                PLDashboardSummary(title: "Open Tasks", value: "\(openTaskCount)"),
                PLDashboardSummary(title: "High Priority", value: "\(highPriorityTaskCount)"),
                PLDashboardSummary(title: "Due Today", value: "\(dueTodayTaskCount)"),
                PLDashboardSummary(title: "Overdue", value: "\(overdueTaskCount)"),
                PLDashboardSummary(title: "Messages", value: "\(loadedThreads.count)"),
                PLDashboardSummary(title: "Status", value: openTaskCount == 0 ? "Clear" : "Active")
            ]
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct PLDashboardSummary: Equatable, Identifiable {
    let id: String
    var title: String
    var value: String

    init(id: String? = nil, title: String, value: String) {
        self.id = id ?? title
        self.title = title
        self.value = value
    }
}
