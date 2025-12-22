//
//  User.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Модель пользователя
struct User: Codable, Identifiable {
    let id: String // UUID
    let name: String
    let email: String?
    let phone: String?
    let phoneFormatted: String?
    let phoneCode: String?
    let avatar: FileResource?
    let telegramUsername: String?
    let isNotifyEmail: Bool?
    let isNotifyTelegram: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case phoneFormatted = "phone_formatted"
        case phoneCode = "phone_code"
        case avatar
        case telegramUsername = "telegram_username"
        case isNotifyEmail = "is_notify_email"
        case isNotifyTelegram = "is_notify_telegram"
    }
}

/// Модель файла
struct FileResource: Codable {
    let id: String // UUID
    let path: String?
    let fileName: String?
    let collection: String?
    let originalUrl: String?
    let url: String?
    let previewUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case path
        case fileName = "file_name"
        case collection
        case originalUrl = "original_url"
        case url
        case previewUrl = "preview_url"
    }
}