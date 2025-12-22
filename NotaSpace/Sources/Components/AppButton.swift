//
//  AppButton.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Кнопка в стиле веб-приложения
struct AppButton: View {
    enum Variant {
        case primary
        case secondary
        case danger
        case ghost
    }
    
    enum Size {
        case sm
        case md
        case lg
    }
    
    let text: String
    let variant: Variant
    let size: Size
    let isLoading: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    init(
        _ text: String,
        variant: Variant = .primary,
        size: Size = .lg,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                }
                Text(text)
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return AppColors.primary
        case .secondary:
            return colorScheme == .dark ? AppColors.Dark.card : AppColors.card
        case .danger:
            return Color.white
        case .ghost:
            return Color.clear
        }
    }
    
    private var textColor: Color {
        switch variant {
        case .primary:
            return AppColors.secondaryText
        case .secondary:
            return colorScheme == .dark ? AppColors.Dark.text : AppColors.text
        case .ghost:
            return colorScheme == .dark ? AppColors.Dark.text : AppColors.text
        case .danger:
            return AppColors.error
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .primary:
            return Color.clear
        case .secondary:
            return colorScheme == .dark ? AppColors.Dark.border : AppColors.border
        case .ghost:
            return colorScheme == .dark ? AppColors.Dark.border : AppColors.border
        case .danger:
            return AppColors.error
        }
    }
    
    private var borderWidth: CGFloat {
        switch variant {
        case .primary, .danger:
            return 1
        case .secondary, .ghost:
            return 1
        }
    }
    
    private var fontSize: CGFloat {
        switch size {
        case .sm:
            return 12
        case .md:
            return 16
        case .lg:
            return 16
        }
    }
    
    private var height: CGFloat {
        switch size {
        case .sm:
            return 32
        case .md:
            return 40
        case .lg:
            return 48
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppButton("Primary Button", variant: .primary) {}
        AppButton("Secondary Button", variant: .secondary) {}
        AppButton("Danger Button", variant: .danger) {}
        AppButton("Ghost Button", variant: .ghost) {}
        AppButton("Loading...", isLoading: true) {}
    }
    .padding()
}