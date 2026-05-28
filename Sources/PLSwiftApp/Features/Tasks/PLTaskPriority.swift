enum PLTaskPriority: String, CaseIterable, Identifiable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: Self {
        self
    }
}
