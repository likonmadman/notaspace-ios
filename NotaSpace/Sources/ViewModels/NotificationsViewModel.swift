//
//  NotificationsViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для экрана уведомлений
@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let notificationService = NotificationService()
    
    /// Загрузить уведомления
    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let notificationsTask = notificationService.getNotifications()
            async let unreadCountTask = notificationService.getUnreadCount()
            
            let (notificationsResponse, unreadCountValue) = try await (
                notificationsTask,
                unreadCountTask
            )
            
            notifications = notificationsResponse.data
            unreadCount = unreadCountValue
        } catch {
            errorMessage = "Не удалось загрузить уведомления: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Обновить уведомления
    func refresh() async {
        await loadNotifications()
    }
    
    /// Отметить уведомление как прочитанное
    func markAsRead(_ notification: Notification) async {
        do {
            try await notificationService.markAsRead(id: notification.id)
            // Обновляем локально
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                var updated = notifications[index]
                // Создаем новое уведомление с read = true
                // Для упрощения перезагружаем список
                await loadNotifications()
            }
        } catch {
            errorMessage = "Не удалось отметить уведомление: \(error.localizedDescription)"
        }
    }
    
    /// Отметить все как прочитанные
    func markAllAsRead() async {
        do {
            try await notificationService.markAllAsRead()
            await loadNotifications()
        } catch {
            errorMessage = "Не удалось отметить все уведомления: \(error.localizedDescription)"
        }
    }
    
    /// Удалить уведомление
    func deleteNotification(_ notification: Notification) async {
        do {
            try await notificationService.deleteNotification(id: notification.id)
            notifications.removeAll { $0.id == notification.id }
            if unreadCount > 0 {
                unreadCount -= 1
            }
        } catch {
            errorMessage = "Не удалось удалить уведомление: \(error.localizedDescription)"
        }
    }
}



