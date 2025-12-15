//
//  AppColors.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Цветовая схема приложения, соответствующая веб-версии из App.vue
struct AppColors {
    // MARK: - Основные цвета (Light Theme)
    
    // Фоны
    static let mainBg = Color(hex: "EAEEF9")
    static let secondaryBg = Color(hex: "FFFFFF")
    static let card = Color(hex: "FFFFFF")
    static let sectionBg = Color(hex: "F9FAFB")
    
    // Текст
    static let mainText = Color(hex: "3F4756")
    static let text = Color(hex: "1F2937")
    static let muted = Color(hex: "6B7280")
    static let secondaryText = Color(hex: "FFFFFF")
    
    // Основные цвета
    static let primary = Color(hex: "0275DE")
    static let primaryHover = Color(hex: "0266C5")
    static let linkColor = Color(hex: "0275DE")
    static let white = Color(hex: "FFFFFF")
    
    // Границы
    static let border = Color(hex: "E5E7EB")
    
    // Ошибки
    static let error = Color(hex: "BD5555")
    static let errorBg = Color(hex: "BD5555").opacity(0.1)
    
    // Дополнительные цвета (Light Theme)
    static let buttonTextDark = Color(hex: "0B1220")
    static let avatarBg = Color(hex: "F3F4F6")
    static let mockupBg = Color(hex: "F9FAFB")
    static let mockupBgDark = Color(hex: "F3F4F6")
    static let mockupDot = Color(hex: "D1D5DB")
    static let mockupCardBg = Color(hex: "FFFFFF")
    static let logoBoxText = Color(hex: "4B5563")
    static let testimonialText = Color(hex: "1F2937")
    static let testimonialAvatarText = Color(hex: "0275DE")
    static let navBg = Color.white.opacity(0.8)
    static let featuredBorder = Color(hex: "0275DE").opacity(0.3)
    static let featuredShadow = Color(hex: "0275DE").opacity(0.15)
    
    // MARK: - Темная тема (Dark Theme)
    
    struct Dark {
        // Фоны
        static let mainBg = Color(hex: "252732")
        static let secondaryBg = Color(hex: "313748")
        static let card = Color(hex: "313748")
        static let sectionBg = Color(hex: "1F2937")
        
        // Текст
        static let mainText = Color(hex: "F8FAFF")
        static let text = Color(hex: "F8FAFF")
        static let muted = Color(hex: "9AA4B2")
        static let secondaryText = Color(hex: "FFFFFF")
        
        // Основные цвета
        static let primary = Color(hex: "0275DE")
        static let primaryHover = Color(hex: "0388F0")
        static let linkColor = Color(hex: "0275DE")
        static let white = Color(hex: "FFFFFF")
        
        // Границы
        static let border = Color.white.opacity(0.12)
        
        // Ошибки
        static let error = Color(hex: "EA7271")
        static let errorBg = Color(hex: "EA7271").opacity(0.15)
        
        // Дополнительные цвета (Dark Theme)
        static let buttonTextDark = Color(hex: "0B1220")
        static let avatarBg = Color(hex: "1B2336")
        static let mockupBg = Color(hex: "0F1629")
        static let mockupBgDark = Color(hex: "0B1220")
        static let mockupDot = Color(hex: "2A334A")
        static let mockupCardBg = Color(hex: "121A2E")
        static let logoBoxText = Color(hex: "D4DBE7")
        static let testimonialText = Color(hex: "E8EEF8")
        static let testimonialAvatarText = Color(hex: "A9F0E5")
        static let navBg = Color(hex: "252732").opacity(0.8)
        static let featuredBorder = Color(hex: "0275DE").opacity(0.6)
        static let featuredShadow = Color(hex: "0275DE").opacity(0.3)
    }
    
    // MARK: - Вспомогательные методы для получения цвета в зависимости от темы
    
    /// Получить цвет фона в зависимости от темы
    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.mainBg : mainBg
    }
    
    /// Получить цвет карточки в зависимости от темы
    static func cardColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.card : card
    }
    
    /// Получить цвет текста в зависимости от темы
    static func textColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.text : text
    }
    
    /// Получить цвет приглушенного текста в зависимости от темы
    static func mutedColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.muted : muted
    }
    
    /// Получить цвет границы в зависимости от темы
    static func borderColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.border : border
    }
    
    /// Получить цвет ошибки в зависимости от темы
    static func errorColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.error : error
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

