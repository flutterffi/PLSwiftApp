import SwiftUI

struct PLMessagesView: View {
    @Bindable var viewModel: PLMessagesViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Unread Only", isOn: $viewModel.showsUnreadOnly)
                }

                Section {
                    ForEach(viewModel.filteredThreads) { thread in
                        HStack(spacing: 10) {
                            if thread.isUnread {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 8, height: 8)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(thread.title)
                                    .font(.headline)
                                Text(thread.preview)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(thread.isUnread ? "Mark Read" : "Mark Unread") {
                                viewModel.toggleReadStatus(id: thread.id)
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .searchable(
                text: $viewModel.searchText,
                placement: .automatic,
                prompt: "Search messages"
            )
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Message Error",
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
                            await viewModel.refreshThreads()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshThreads()
            }
            .task {
                await viewModel.loadThreads()
            }
        }
    }
}
