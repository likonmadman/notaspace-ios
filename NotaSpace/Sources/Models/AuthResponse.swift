//
//  AuthResponse.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Ответ API при аутентификации
struct AuthResponse: Codable {
    let user: User
    let token: String
}

