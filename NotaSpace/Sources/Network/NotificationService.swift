//
//  NotificationService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы с уведомлениями
final class NotificationService {
    private let apiClient = APIClient.shared
    
    /// Получить список уведомлений
    func getNotifications() async throws -> NotificationsResponse {
        return try await apiClient.request(
            endpoint: "/notifications",
            method: .get
        )
    }
    
    /// Получить количество непрочитанных уведомлений
    func getUnreadCount() async throws -> Int {
        let response: UnreadCountResponse = try await apiClient.request(
            endpoint: "/notifications/unread-count",
            method: .get
        )
        return response.count
    }
    
    /// Отметить уведомление как прочитанное
    func markAsRead(id: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/notifications/\(id)/read",
            method: .post
        )
    }
    
    /// Отметить все уведомления как прочитанные
    func markAllAsRead() async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/notifications/read-all",
            method: .post
        )
    }
    
    /// Удалить уведомление
    func deleteNotification(id: Int) async throws {
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/notifications/\(id)",
            method: .delete
        )
    }
}




