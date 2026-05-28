enum PLTaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case done = "Done"

    var id: Self {
        self
    }
}
