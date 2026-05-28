import SwiftUI

struct PLSettingsView: View {
    @Bindable var viewModel: PLSettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Telemetry") {
                    Toggle(
                        "Analytics",
                        isOn: Binding(
                            get: { viewModel.isAnalyticsEnabled },
                            set: { isEnabled in
                                Task {
                                    await viewModel.analyticsChanged(isEnabled)
                                }
                            }
                        )
                    )
                    Toggle(
                        "Crash Reporting",
                        isOn: Binding(
                            get: { viewModel.isCrashReportingEnabled },
                            set: { isEnabled in
                                Task {
                                    await viewModel.crashReportingChanged(isEnabled)
                                }
                            }
                        )
                    )
                }
            }
            .navigationTitle("Settings")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Settings Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadSettings()
            }
        }
    }
}
