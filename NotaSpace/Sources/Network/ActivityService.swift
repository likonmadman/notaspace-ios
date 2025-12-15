//
//  ActivityService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы с активностью
final class ActivityService {
    private let apiClient = APIClient.shared
    
    /// Получить список активности
    func getActivities(limit: Int? = nil) async throws -> ActivitiesResponse {
        var endpoint = "/activity"
        if let limit = limit {
            endpoint += "?limit=\(limit)"
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .get
        )
    }
}


