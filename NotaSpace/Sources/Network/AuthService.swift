//
//  AuthService.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Сервис для работы с аутентификацией
final class AuthService {
    static let shared = AuthService()
    private let apiClient = APIClient.shared
    private let keychain = KeychainService.shared
    
    private init() {}
    
    /// Вход по email/телефону и паролю
    func login(email: String?, phone: String?, countryCode: String?, password: String) async throws -> AuthResponse {
        struct LoginRequest: Codable {
            let email: String?
            let phone: String?
            let countryCode: String?
            let password: String
        }
        
        let request = LoginRequest(email: email, phone: phone, countryCode: countryCode, password: password)
        let response: AuthResponse = try await apiClient.request<AuthResponse>(
            endpoint: "/login",
            method: .post,
            body: request
        )
        
        // Сохраняем токен
        try keychain.save(token: response.token)
        apiClient.setAuthToken(response.token)
        
        return response
    }
    
    /// Отправка кода для входа (email или phone)
    func sendCode(email: String?, phone: String?, countryCode: String?) async throws -> Bool {
        struct SendCodeRequest: Codable {
            let email: String?
            let phone: String?
            let countryCode: String?
        }
        
        let request = SendCodeRequest(email: email, phone: phone, countryCode: countryCode)
        let _: EmptyResponse = try await apiClient.request<EmptyResponse>(
            endpoint: "/login-by-code",
            method: .post,
            body: request
        )
        
        return true
    }
    
    /// Проверка кода и вход
    func checkCode(email: String?, phone: String?, countryCode: String?, code: String) async throws -> AuthResponse {
        struct CheckCodeRequest: Codable {
            let email: String?
            let phone: String?
            let countryCode: String?
            let code: String
        }
        
        let request = CheckCodeRequest(email: email, phone: phone, countryCode: countryCode, code: code)
        let response: AuthResponse = try await apiClient.request<AuthResponse>(
            endpoint: "/check-code",
            method: .post,
            body: request
        )
        
        // Сохраняем токен
        try keychain.save(token: response.token)
        apiClient.setAuthToken(response.token)
        
        return response
    }
    
    /// Регистрация
    func signUp(name: String, email: String, password: String) async throws -> AuthResponse {
        struct SignUpRequest: Codable {
            let name: String
            let email: String
            let password: String
        }
        
        let request = SignUpRequest(name: name, email: email, password: password)
        let response: AuthResponse = try await apiClient.request<AuthResponse>(
            endpoint: "/sign-up",
            method: .post,
            body: request
        )
        
        // Сохраняем токен
        try keychain.save(token: response.token)
        apiClient.setAuthToken(response.token)
        
        return response
    }
    
    /// Выход
    func logout() async throws {
        let _: EmptyResponse = try await apiClient.request<EmptyResponse>(
            endpoint: "/logout",
            method: .post
        )
        
        // Удаляем токен
        keychain.deleteToken()
        apiClient.setAuthToken(nil)
    }
    
    /// Проверить сохраненный токен и восстановить сессию
    func restoreSession() -> Bool {
        if let token = keychain.getToken() {
            apiClient.setAuthToken(token)
            return true
        }
        return false
    }
}

/// Пустой ответ от API
struct EmptyResponse: Codable {}