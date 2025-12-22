//
//  Notification.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель уведомления
struct Notification: Identifiable, Codable {
    let id: Int
    let type: String
    let title: String
    let message: String?
    let read: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, title, message, read
        case createdAt = "created_at"
    }
}

/// Ответ API со списком уведомлений
struct NotificationsResponse: Codable {
    let data: [Notification]
}

/// Ответ API с количеством непрочитанных уведомлений
struct UnreadCountResponse: Codable {
    let count: Int
}