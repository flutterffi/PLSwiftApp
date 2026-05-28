import Foundation

struct PLTaskItem: Equatable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: PLTaskPriority
    var dueDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        priority: PLTaskPriority = .medium,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
    }
}
