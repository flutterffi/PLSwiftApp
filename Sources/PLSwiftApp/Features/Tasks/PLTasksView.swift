import SwiftUI

struct PLTasksView: View {
    @Bindable var viewModel: PLTasksViewModel
    @State private var editTaskID: PLTaskItem.ID?
    @State private var editTitle = ""
    @State private var editPriority: PLTaskPriority = .medium

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

                    Picker("Priority", selection: $viewModel.draftPriority) {
                        ForEach(PLTaskPriority.allCases) { priority in
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
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
                                Text(task.priority.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Edit") {
                                editTaskID = task.id
                                editTitle = task.title
                                editPriority = task.priority
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete { offsets in
                        Task {
                            await viewModel.deleteFilteredTasks(at: offsets)
                        }
                    }
                    .onMove { offsets, destination in
                        Task {
                            await viewModel.moveTasks(from: offsets, to: destination)
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
            .searchable(
                text: $viewModel.searchText,
                placement: .automatic,
                prompt: "Search tasks"
            )
            .sheet(
                isPresented: Binding(
                    get: { editTaskID != nil },
                    set: { isPresented in
                        if !isPresented {
                            editTaskID = nil
                            editTitle = ""
                            editPriority = .medium
                        }
                    }
                )
            ) {
                NavigationStack {
                    Form {
                        TextField("Task title", text: $editTitle)
                        Picker("Priority", selection: $editPriority) {
                            ForEach(PLTaskPriority.allCases) { priority in
                                Text(priority.rawValue)
                                    .tag(priority)
                            }
                        }
                    }
                    .navigationTitle("Edit Task")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                editTaskID = nil
                                editTitle = ""
                                editPriority = .medium
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                guard let editTaskID else {
                                    return
                                }
                                Task {
                                    await viewModel.updateTask(
                                        id: editTaskID,
                                        title: editTitle,
                                        priority: editPriority
                                    )
                                    self.editTaskID = nil
                                    editTitle = ""
                                    editPriority = .medium
                                }
                            }
                            .disabled(editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}
