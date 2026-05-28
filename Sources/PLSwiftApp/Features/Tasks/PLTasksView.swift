import SwiftUI

struct PLTasksView: View {
    @Bindable var viewModel: PLTasksViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        TextField("New task", text: $viewModel.draftTitle)

                        Button {
                            Task {
                                await viewModel.addTask()
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                        }
                        .disabled(!viewModel.canAddTask)
                        .buttonStyle(.borderless)
                    }
                }

                Section {
                    Picker("Filter", selection: $viewModel.selectedFilter) {
                        ForEach(PLTaskFilter.allCases) { filter in
                            Text(filter.rawValue)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    ForEach(viewModel.filteredTasks) { task in
                        Button {
                            Task {
                                await viewModel.toggleTaskCompletion(id: task.id)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        Task {
                            await viewModel.deleteFilteredTasks(at: offsets)
                        }
                    }
                } header: {
                    Text("\(viewModel.activeTaskCount) Active")
                }
            }
            .navigationTitle("Tasks")
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(
                "Task Error",
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
                    Button("Clear Done") {
                        Task {
                            await viewModel.clearCompletedTasks()
                        }
                    }
                }
            }
            .task {
                await viewModel.loadTasks()
            }
        }
    }
}
