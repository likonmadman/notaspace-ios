//
//  AuthViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для аутентификации
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        // Пытаемся восстановить сессию при запуске
        if authService.restoreSession() {
            isAuthenticated = true
            // TODO: Загрузить данные пользователя
        }
    }
    
    /// Вход по email и паролю
    func login(email: String, password: String) async {
        await login(email: email, phone: nil, countryCode: nil, password: password)
    }
    
    /// Вход по телефону и паролю
    func login(phone: String, countryCode: String, password: String) async {
        await login(email: nil, phone: phone, countryCode: countryCode, password: password)
    }
    
    /// Вход (универсальный метод)
    private func login(email: String?, phone: String?, countryCode: String?, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.login(email: email, phone: phone, countryCode: countryCode, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Отправка кода для входа
    func sendCode(email: String?, phone: String?, countryCode: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.sendCode(email: email, phone: phone, countryCode: countryCode)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Проверка кода и вход
    func checkCode(email: String?, phone: String?, countryCode: String?, code: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.checkCode(email: email, phone: phone, countryCode: countryCode, code: code)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Регистрация
    func signUp(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.signUp(name: name, email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Выход
    func logout() async {
        isLoading = true
        
        do {
            try await authService.logout()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}