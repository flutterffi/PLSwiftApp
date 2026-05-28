import SwiftUI

struct PLDashboardView: View {
    @Bindable var viewModel: PLDashboardViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    ForEach(viewModel.summaryItems) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text(item.value)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Dashboard Error",
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await viewModel.loadSummary()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.loadSummary()
            }
            .task {
                await viewModel.loadSummary()
            }
        }
    }
}
