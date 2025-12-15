//
//  Task.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель задачи
struct Task: Identifiable, Codable {
    let id: Int
    let uuid: String
    let title: String
    let description: String?
    let status: String?
    let priority: String?
    let favorite: Bool?
    let pageId: Int?
    let columnId: String?
    let assigneeId: Int?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, title, description, status, priority, favorite
        case pageId = "page_id"
        case columnId = "column_id"
        case assigneeId = "assignee_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Ответ API со списком задач
struct TasksResponse: Codable {
    let data: [Task]
}


