struct PLMessageThread: Equatable, Identifiable, Sendable {
    let id: String
    var title: String
    var preview: String
    var isUnread: Bool

    init(
        id: String? = nil,
        title: String,
        preview: String,
        isUnread: Bool = true
    ) {
        self.id = id ?? title
        self.title = title
        self.preview = preview
        self.isUnread = isUnread
    }
}
