import Observation

@MainActor
@Observable
final class PLMessagesViewModel {
    var threads: [PLMessageThread] = []
    var isLoading = false
    var errorMessage: String?

    private let repository: any PLMessageRepositoryProtocol

    init(repository: any PLMessageRepositoryProtocol = PLMessageRepository()) {
        self.repository = repository
    }

    func loadThreads() async {
        isLoading = true
        errorMessage = nil

        do {
            threads = try await repository.fetchThreads()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshThreads() async {
        await loadThreads()
    }
}
