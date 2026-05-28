struct PLMessageThread: Equatable, Identifiable, Sendable {
    let id: String
    var title: String
    var preview: String

    init(id: String? = nil, title: String, preview: String) {
        self.id = id ?? title
        self.title = title
        self.preview = preview
    }
}
