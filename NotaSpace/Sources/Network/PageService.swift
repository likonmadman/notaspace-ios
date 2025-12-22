//
//  PageService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы со страницами
final class PageService {
    private let apiClient = APIClient.shared
    
    /// Получить список страниц
    func getPages(
        sort: String? = nil,
        status: String? = nil,
        type: String? = nil,
        favorite: Bool? = nil,
        perPage: Int? = nil
    ) async throws -> PagesResponse {
        var params: [String: String] = [:]
        if let sort = sort {
            params["sort"] = sort
        }
        if let status = status {
            params["status"] = status
        }
        if let type = type {
            params["type"] = type
        }
        if let favorite = favorite {
            params["favorite"] = favorite ? "1" : "0"
        }
        if let perPage = perPage {
            params["perPage"] = String(perPage)
        }
        
        let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = queryString.isEmpty ? "/page" : "/page?\(queryString)"
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .get
        )
    }
    
    /// Получить страницу по ID (список)
    func getPage(id: String) async throws -> Page {
        struct PageResponse: Codable {
            let data: Page
        }
        
        let response: PageResponse = try await apiClient.request(
            endpoint: "/page/\(id)",
            method: .get
        )
        return response.data
    }
    
    /// Получить детальную страницу с блоками
    func getPageDetail(id: String) async throws -> PageDetail {
        let response: PageDetailResponse = try await apiClient.request(
            endpoint: "/page/\(id)",
            method: .get
        )
        return response.data
    }
    
    /// Обновить блоки страницы
    func updatePageBlocks(pageId: String, blocks: [Block]) async throws -> PageDetail {
        struct UpdateBlocksRequest: Codable {
            let blocks: [BlockUpdate]
        }
        
        struct BlockUpdate: Codable {
            let id: String?
            let type: String
            let content: String
            let position: Int
        }
        
        struct PageDetailResponse: Codable {
            let data: PageDetail
        }
        
        let blockUpdates = blocks.map { block in
            BlockUpdate(id: block.id, type: block.type, content: block.content, position: block.position)
        }
        
        let request = UpdateBlocksRequest(blocks: blockUpdates)
        let response: PageDetailResponse = try await apiClient.request(
            endpoint: "/page/\(pageId)",
            method: .put,
            body: request
        )
        return response.data
    }
    
    /// Создать страницу
    func createPage(title: String, type: String, workspaceId: Int?) async throws -> Page {
        struct CreatePageRequest: Codable {
            let title: String
            let type: String
            let workspaceId: Int?
            
            enum CodingKeys: String, CodingKey {
                case title, type
                case workspaceId = "workspace_id"
            }
        }
        
        struct PageResponse: Codable {
            let data: Page
        }
        
        let request = CreatePageRequest(title: title, type: type, workspaceId: workspaceId)
        let response: PageResponse = try await apiClient.request(
            endpoint: "/page",
            method: .post,
            body: request
        )
        return response.data
    }
    
    /// Обновить страницу
    func updatePage(id: String, title: String?) async throws -> Page {
        struct UpdatePageRequest: Codable {
            let title: String?
        }
        
        struct PageResponse: Codable {
            let data: Page
        }
        
        let request = UpdatePageRequest(title: title)
        let response: PageResponse = try await apiClient.request(
            endpoint: "/page/\(id)",
            method: .put,
            body: request
        )
        return response.data
    }
    
    /// Удалить страницу
    func deletePage(id: String) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/page/\(id)",
            method: .delete
        )
    }
    
    /// Переключить избранное
    func toggleFavorite(pageId: String) async throws -> Bool {
        struct FavoriteResponse: Codable {
            let favorite: Bool
        }
        
        let response: FavoriteResponse = try await apiClient.request(
            endpoint: "/page/\(pageId)/favorite",
            method: .post
        )
        return response.favorite
    }
}