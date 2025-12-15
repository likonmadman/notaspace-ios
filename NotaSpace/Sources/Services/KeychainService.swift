//
//  KeychainService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import Security

/// Сервис для работы с Keychain
final class KeychainService {
    static let shared = KeychainService()
    private let service = "ru.notaspace.app"
    private let tokenKey = "auth_token"
    
    private init() {}
    
    /// Сохранить токен
    func save(token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.dataConversionError
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        // Удаляем старый токен если есть
        SecItemDelete(query as CFDictionary)
        
        // Сохраняем новый токен
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveError
        }
    }
    
    /// Получить токен
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// Удалить токен
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

/// Ошибки Keychain
enum KeychainError: LocalizedError {
    case dataConversionError
    case saveError
    
    var errorDescription: String? {
        switch self {
        case .dataConversionError:
            return "Ошибка преобразования данных"
        case .saveError:
            return "Ошибка сохранения в Keychain"
        }
    }
}

