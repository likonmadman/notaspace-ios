//
//  Activity.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель активности
struct Activity: Identifiable, Codable {
    let id: Int
    let type: String
    let description: String
    let userId: Int?
    let pageId: Int?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, description
        case userId = "user_id"
        case pageId = "page_id"
        case createdAt = "created_at"
    }
}

/// Ответ API со списком активностей
struct ActivitiesResponse: Codable {
    let data: [Activity]
}


