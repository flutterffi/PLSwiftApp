import SwiftUI

struct PLMessagesView: View {
    let viewModel: PLMessagesViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.threads) { thread in
                VStack(alignment: .leading, spacing: 4) {
                    Text(thread.title)
                        .font(.headline)
                    Text(thread.preview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Messages")
        }
    }
}
