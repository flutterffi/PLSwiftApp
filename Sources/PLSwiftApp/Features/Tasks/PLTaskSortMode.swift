enum PLTaskSortMode: String, CaseIterable, Identifiable {
    case manual = "Manual"
    case priority = "Priority"
    case dueDate = "Due Date"

    var id: Self {
        self
    }
}
