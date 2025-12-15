//
//  Block.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель блока страницы
struct Block: Identifiable, Codable {
    let id: String // uuid
    let type: String
    let content: String
    let position: Int
    let pageId: Int?
    let commentsCount: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, content, position
        case pageId = "page_id"
        case commentsCount = "comments_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Расширенная модель страницы с блоками
struct PageDetail: Codable {
    let id: String // uuid
    let title: String?
    let type: String
    let blocks: [Block]?
    let createdAt: String
    let updatedAt: String
    let permissions: PagePermissions?
    
    enum CodingKeys: String, CodingKey {
        case id, title, type, blocks
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case permissions
    }
}

/// Права доступа к странице
struct PagePermissions: Codable {
    let view: Bool
    let comment: Bool
    let update: Bool
}

/// Ответ API для детальной страницы
struct PageDetailResponse: Codable {
    let data: PageDetail
}

