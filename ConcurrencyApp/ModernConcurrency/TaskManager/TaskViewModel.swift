//
//  TaskViewModel.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import Foundation

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskManager.TaskItem] = []
    private let taskManager = TaskManager()
    
    func fetchTasks() async {
        tasks = await taskManager.getTasks()
    }
    func addTask(_ task: String) async {
        await taskManager.addTask(title: task)
        await fetchTasks()
    }
    func toggleTaskCompletion(id: UUID) async {
        await taskManager.toggleTaskCompletion(id: id)
        await fetchTasks()
    }
    func deleteTask(id: UUID) async {
        await taskManager.deleteTask(id: id)
        await fetchTasks()
    }
}
