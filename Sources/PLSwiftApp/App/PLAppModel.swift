import Observation

enum PLTab: String, CaseIterable, Equatable {
    case dashboard
    case tasks
    case messages
    case settings
}

@Observable
final class PLAppModel {
    var selectedTab: PLTab = .dashboard
}
