import Foundation
import SwiftData

@Model
final class PLStoredTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var sortIndex: Int

    init(id: UUID, title: String, isCompleted: Bool, sortIndex: Int) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.sortIndex = sortIndex
    }
}
