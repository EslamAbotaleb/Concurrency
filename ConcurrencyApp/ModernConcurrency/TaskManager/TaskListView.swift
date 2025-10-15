//
//  TaskListView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import SwiftUI

struct TaskListView: View {
  @StateObject private var viewModel = TaskViewModel()
  @State private var newTaskTitle: String = ""

  var body: some View {
    NavigationView {
      VStack {
        List {
          ForEach(viewModel.tasks) { task in
            HStack {
              Text(task.title)
                .strikethrough(task.isCompleted, color: .black)
              Spacer()
              Button(action: {
                Task {
                  await viewModel.toggleTaskCompletion(id: task.id)
                }
              }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                  .foregroundColor(task.isCompleted ? .green : .gray)
              }
            }
          }
          .onDelete(perform: { indexSet in
            Task {
              for index in indexSet {
                await viewModel.deleteTask(id: viewModel.tasks[index].id)
              }
            }
          })
        }

        // Add New Task Section
        HStack {
          TextField("New Task", text: $newTaskTitle)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          Button(action: {
            Task {
                await viewModel.addTask(newTaskTitle)
              newTaskTitle = ""
            }
          }) {
            Image(systemName: "plus.circle.fill")
              .foregroundColor(.blue)
          }
          .disabled(newTaskTitle.isEmpty)
        }
        .padding()
      }
      .navigationTitle("Task Manager")
      .toolbar {
        EditButton()
      }
      .task {
        await viewModel.fetchTasks()
      }
    }
  }
}

#Preview {
    TaskListView()
}
