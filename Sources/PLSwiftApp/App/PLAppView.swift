import SwiftUI

struct PLAppView: View {
    @State private var appModel = PLAppModel()
    @State private var dashboardViewModel = PLDashboardViewModel()
    @State private var tasksViewModel = PLTasksViewModel()
    @State private var messagesViewModel = PLMessagesViewModel()
    @State private var settingsViewModel = PLSettingsViewModel()

    var body: some View {
        @Bindable var appModel = appModel

        TabView(selection: $appModel.selectedTab) {
            PLDashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }
                .tag(PLTab.dashboard)

            PLTasksView(viewModel: tasksViewModel)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(PLTab.tasks)

            PLMessagesView(viewModel: messagesViewModel)
                .tabItem {
                    Label("Messages", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(PLTab.messages)

            PLSettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(PLTab.settings)
        }
    }
}
