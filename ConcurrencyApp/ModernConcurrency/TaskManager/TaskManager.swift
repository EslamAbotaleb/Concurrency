//
//  TaskManager.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import Foundation

actor TaskManager {
    private var tasks: [TaskItem] = []
    
    struct TaskItem: Identifiable {
      let id: UUID
      var title: String
      var isCompleted: Bool

      init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
      }
    }
    
    func addTask(title: String) {
        let newTask = TaskItem(title: title)
        tasks.append(newTask)
    }
    func toggleTaskCompletion(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    func deleteTask(id: UUID) {
      tasks.removeAll { $0.id == id }
    }

    func getTasks() -> [TaskItem] {
      return tasks
    }
}
