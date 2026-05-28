import Observation

@Observable
final class PLDashboardViewModel {
    var title = "Operations"
    var summaryItems: [PLDashboardSummary] = [
        PLDashboardSummary(title: "Open Tasks", value: "3"),
        PLDashboardSummary(title: "Messages", value: "2"),
        PLDashboardSummary(title: "Status", value: "Ready")
    ]
}

struct PLDashboardSummary: Equatable, Identifiable {
    let id: String
    var title: String
    var value: String

    init(id: String? = nil, title: String, value: String) {
        self.id = id ?? title
        self.title = title
        self.value = value
    }
}
