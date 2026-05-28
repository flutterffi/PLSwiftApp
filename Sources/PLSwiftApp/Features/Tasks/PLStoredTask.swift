import Foundation
import SwiftData

@Model
final class PLStoredTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var priorityRawValue: String
    var sortIndex: Int

    init(
        id: UUID,
        title: String,
        isCompleted: Bool,
        priorityRawValue: String = PLTaskPriority.medium.rawValue,
        sortIndex: Int
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priorityRawValue = priorityRawValue
        self.sortIndex = sortIndex
    }
}
