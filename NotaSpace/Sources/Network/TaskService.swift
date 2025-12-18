//
//  TaskService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы с задачами
final class TaskService {
    private let apiClient = APIClient.shared
    
    /// Получить список задач для страницы
    func getTasks(pageId: String) async throws -> TasksResponse {
        return try await apiClient.request(
            endpoint: "/page/\(pageId)/tasks",
            method: .get
        )
    }
    
    /// Создать задачу
    func createTask(pageId: String, title: String, description: String?, columnId: String?) async throws -> Task {
        struct CreateTaskRequest: Codable {
            let title: String
            let description: String?
            let columnId: String?
            
            enum CodingKeys: String, CodingKey {
                case title, description
                case columnId = "column_id"
            }
        }
        
        struct TaskResponse: Codable {
            let data: Task
        }
        
        let request = CreateTaskRequest(title: title, description: description, columnId: columnId)
        let response: TaskResponse = try await apiClient.request(
            endpoint: "/page/\(pageId)/tasks",
            method: .post,
            body: request
        )
        return response.data
    }
    
    /// Обновить задачу
    func updateTask(pageId: String, taskId: String, title: String?, description: String?, status: String?) async throws -> Task {
        struct UpdateTaskRequest: Codable {
            let title: String?
            let description: String?
            let status: String?
        }
        
        struct TaskResponse: Codable {
            let data: Task
        }
        
        let request = UpdateTaskRequest(title: title, description: description, status: status)
        let response: TaskResponse = try await apiClient.request(
            endpoint: "/page/\(pageId)/tasks/\(taskId)",
            method: .put,
            body: request
        )
        return response.data
    }
    
    /// Удалить задачу
    func deleteTask(pageId: String, taskId: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/page/\(pageId)/tasks/\(taskId)",
            method: .delete
        )
    }
}




