//
//  TrashService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы с корзиной
final class TrashService {
    private let apiClient = APIClient.shared
    
    /// Получить список элементов корзины
    func getTrash(perPage: Int? = nil) async throws -> TrashResponse {
        var endpoint = "/trash"
        if let perPage = perPage {
            endpoint += "?perPage=\(perPage)"
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .get
        )
    }
    
    /// Восстановить элемент из корзины
    func restore(type: String, id: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/trash/\(type)/\(id)/restore",
            method: .post
        )
    }
    
    /// Удалить элемент навсегда
    func delete(type: String, id: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/trash/\(type)/\(id)",
            method: .delete
        )
    }
}



