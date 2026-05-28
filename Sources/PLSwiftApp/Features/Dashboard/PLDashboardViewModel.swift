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

    init(
        taskRepository: any PLTaskRepositoryProtocol = PLTaskRepository(),
        messageRepository: any PLMessageRepositoryProtocol = PLMessageRepository()
    ) {
        self.taskRepository = taskRepository
        self.messageRepository = messageRepository
    }

    func loadSummary() async {
        isLoading = true
        errorMessage = nil

        do {
            async let tasks = taskRepository.fetchTasks()
            async let threads = messageRepository.fetchThreads()
            let (loadedTasks, loadedThreads) = try await (tasks, threads)
            let openTaskCount = loadedTasks.filter { !$0.isCompleted }.count

            summaryItems = [
                PLDashboardSummary(title: "Open Tasks", value: "\(openTaskCount)"),
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
