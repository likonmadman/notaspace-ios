//
//  Page.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель страницы
struct Page: Identifiable, Codable {
    let id: Int
    let uuid: String
    let title: String?
    let type: String
    let status: String?
    let favorite: Bool?
    let workspaceId: Int?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, title, type, status, favorite
        case workspaceId = "workspace_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Ответ API со списком страниц
struct PagesResponse: Codable {
    let data: [Page]
    let currentPage: Int?
    let lastPage: Int?
    let perPage: Int?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case data
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}






