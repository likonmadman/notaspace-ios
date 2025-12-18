//
//  TrashItem.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Элемент корзины
struct TrashItem: Identifiable, Codable {
    let id: Int
    let type: String // "page" или "workspace"
    let title: String?
    let deletedAt: String
    let workspaceName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, title
        case deletedAt = "deleted_at"
        case workspaceName = "workspace_name"
    }
}

/// Ответ API со списком элементов корзины
struct TrashResponse: Codable {
    let data: [TrashItem]
}




