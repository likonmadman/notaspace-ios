//
//  TasksViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для экрана задач
@MainActor
final class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let taskService = TaskService()
    private let pageService = PageService()
    
    /// Загрузить список страниц с задачами
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Получаем все страницы типа "task"
            let pagesResponse = try await pageService.getPages(type: "task")
            let taskPages = pagesResponse.data
            
            // Загружаем задачи для каждой страницы
            var allTasks: [Task] = []
            for page in taskPages {
                do {
                    let tasksResponse = try await taskService.getTasks(pageId: page.uuid)
                    allTasks.append(contentsOf: tasksResponse.data)
                } catch {
                    // Пропускаем страницы с ошибками
                    continue
                }
            }
            
            tasks = allTasks.sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            errorMessage = "Не удалось загрузить задачи: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Обновить список задач
    func refresh() async {
        await loadTasks()
    }
}






