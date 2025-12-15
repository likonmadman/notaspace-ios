//
//  APIClient.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation

/// Базовый клиент для работы с API
final class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    private var authToken: String?
    
    private init() {
        #if DEBUG
        // Для симулятора используем localhost, для реального устройства - IP Mac
        // Если запускаете на реальном устройстве, замените на IP вашего Mac
        // Узнать IP можно командой: ifconfig | grep "inet " | grep -v 127.0.0.1
        // Пример: "http://192.168.1.141:85/api"
        self.baseURL = "http://localhost:85/api"
        // Для реального устройства раскомментируйте и укажите IP вашего Mac:
        // self.baseURL = "http://192.168.1.141:85/api"
        #else
        self.baseURL = "https://notaspace.ru/api"
        #endif
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    /// Установить токен аутентификации
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    /// Выполнить запрос
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        // Поддерживаем query параметры в endpoint
        let fullURL: String
        if endpoint.contains("?") {
            fullURL = "\(baseURL)\(endpoint)"
        } else {
            fullURL = "\(baseURL)\(endpoint)"
        }
        
        guard let url = URL(string: fullURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorData = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverError(errorData.message ?? "Unknown error")
                }
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
}

/// HTTP методы
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Ошибки API
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case networkError(String)
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .httpError(let code):
            return "HTTP ошибка: \(code)"
        case .serverError(let message):
            return message
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .encodingError:
            return "Ошибка кодирования данных"
        case .decodingError:
            return "Ошибка декодирования данных"
        }
    }
}

/// Структура ошибки от сервера
struct APIErrorResponse: Codable {
    let message: String?
    let error: String?
}

