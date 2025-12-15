//
//  Workspace.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель workspace
struct Workspace: Identifiable, Codable {
    let id: Int
    let uuid: String
    let name: String
    let description: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, name, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Ответ API со списком workspace
struct WorkspacesResponse: Codable {
    let data: WorkspacesData
}

struct WorkspacesData: Codable {
    let `public`: [Workspace] // Используем обратные кавычки для зарезервированного слова
    
    enum CodingKeys: String, CodingKey {
        case `public` = "public"
    }
}

