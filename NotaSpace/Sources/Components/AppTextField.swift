//
//  AppTextField.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Поле ввода в стиле веб-приложения
struct AppTextField: View {
    enum Size {
        case sm
        case md
        case lg
    }
    
    let title: String?
    let placeholder: String
    let text: Binding<String>
    let isSecure: Bool
    let size: Size
    let error: String?
    let keyboardType: UIKeyboardType
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isPasswordVisible = false
    
    init(
        title: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        size: Size = .md,
        error: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.isSecure = isSecure
        self.size = size
        self.error = error
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let title = title {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.mainText)
            }
            
            HStack {
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(placeholder, text: text)
                            .keyboardType(keyboardType)
                            .textContentType(.password)
                            .autocapitalization(.none)
                    } else {
                        TextField(placeholder, text: text)
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                            .textContentType(isSecure ? .password : .none)
                    }
                }
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
                .cornerRadius(12)
                
                if isSecure {
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 8)
                }
            }
            
            if let error = error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.error : AppColors.error)
                    .padding(.leading, 4)
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.card : AppColors.card
    }
    
    private var textColor: Color {
        colorScheme == .dark ? AppColors.Dark.text : AppColors.text
    }
    
    private var borderColor: Color {
        if let _ = error {
            return colorScheme == .dark ? AppColors.Dark.error : AppColors.error
        }
        return colorScheme == .dark ? AppColors.Dark.border : AppColors.border
    }
    
    private var fontSize: CGFloat {
        switch size {
        case .sm:
            return 12
        case .md:
            return 16
        case .lg:
            return 28
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AppTextField(
            title: "Email",
            placeholder: "Введите email",
            text: .constant("")
        )
        
        AppTextField(
            title: "Пароль",
            placeholder: "Введите пароль",
            text: .constant(""),
            isSecure: true
        )
        
        AppTextField(
            placeholder: "С ошибкой",
            text: .constant(""),
            error: "Это поле обязательно"
        )
    }
    .padding()
}

