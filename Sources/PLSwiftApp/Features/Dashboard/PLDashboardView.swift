import SwiftUI

struct PLDashboardView: View {
    let viewModel: PLDashboardViewModel

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
        }
    }
}
