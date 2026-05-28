import Observation

@MainActor
@Observable
final class PLMessagesViewModel {
    var threads: [PLMessageThread] = []
    var searchText = ""
    var showsUnreadOnly = false
    var isLoading = false
    var errorMessage: String?

    private let repository: any PLMessageRepositoryProtocol

    init(repository: any PLMessageRepositoryProtocol = PLMessageRepository()) {
        self.repository = repository
    }

    var unreadThreadCount: Int {
        threads.filter(\.isUnread).count
    }

    var filteredThreads: [PLMessageThread] {
        let unreadFilteredThreads = showsUnreadOnly
            ? threads.filter(\.isUnread)
            : threads
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return unreadFilteredThreads
        }

        return unreadFilteredThreads.filter {
            $0.title.localizedCaseInsensitiveContains(query)
            || $0.preview.localizedCaseInsensitiveContains(query)
        }
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

    func toggleReadStatus(id: PLMessageThread.ID) {
        guard let index = threads.firstIndex(where: { $0.id == id }) else {
            return
        }

        threads[index].isUnread.toggle()
    }
}
