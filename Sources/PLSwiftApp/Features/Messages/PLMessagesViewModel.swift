import Observation

@Observable
final class PLMessagesViewModel {
    var threads: [PLMessageThread] = [
        PLMessageThread(title: "Platform", preview: "Architecture baseline is ready."),
        PLMessageThread(title: "Release", preview: "Tag preparation is queued.")
    ]
}

struct PLMessageThread: Equatable, Identifiable {
    let id: String
    var title: String
    var preview: String

    init(id: String? = nil, title: String, preview: String) {
        self.id = id ?? title
        self.title = title
        self.preview = preview
    }
}
