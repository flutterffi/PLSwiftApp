import SwiftUI

struct PLSettingsView: View {
    @Bindable var viewModel: PLSettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Telemetry") {
                    Toggle("Analytics", isOn: $viewModel.isAnalyticsEnabled)
                    Toggle("Crash Reporting", isOn: $viewModel.isCrashReportingEnabled)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
