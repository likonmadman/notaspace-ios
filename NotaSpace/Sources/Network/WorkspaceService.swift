//
//  WorkspaceService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы с workspace
final class WorkspaceService {
    private let apiClient = APIClient.shared
    
    /// Получить список workspace
    func getWorkspaces(withStats: Bool = false, perPage: Int? = nil) async throws -> WorkspacesResponse {
        var params: [String: String] = [:]
        if withStats {
            params["with"] = "stats"
        }
        if let perPage = perPage {
            params["perPage"] = String(perPage)
        }
        
        let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = queryString.isEmpty ? "/workspaces" : "/workspaces?\(queryString)"
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .get
        )
    }
}