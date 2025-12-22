//
//  AppCodeField.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Поле для ввода кода верификации с таймером
struct AppCodeField: View {
    let placeholder: String
    @Binding var code: String
    let error: String?
    let seconds: Int
    let onRepeat: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var localSeconds: Int
    @State private var timer: Timer?
    
    init(
        placeholder: String = "Введите код",
        code: Binding<String>,
        error: String? = nil,
        seconds: Int = 0,
        onRepeat: @escaping () -> Void = {}
    ) {
        self.placeholder = placeholder
        self._code = code
        self.error = error
        self.seconds = seconds
        self.onRepeat = onRepeat
        self._localSeconds = State(initialValue: seconds)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                TextField(placeholder, text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .onChange(of: code) { newValue in
                        // Оставляем только цифры
                        code = newValue.filter { $0.isNumber }
                        if code.count > 4 {
                            code = String(code.prefix(4))
                        }
                    }
                
                // Таймер или кнопка повтора
                if localSeconds > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "alarm")
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        Text(String(format: "%02d", localSeconds))
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                    }
                    .padding(.trailing, 8)
                } else {
                    Button(action: onRepeat) {
                        Image(systemName: "repeat")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
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
        .onAppear {
            if seconds > 0 {
                localSeconds = seconds
                startTimer()
            }
        }
        .onChange(of: seconds) { newValue in
            stopTimer()
            localSeconds = newValue
            if newValue > 0 {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var borderColor: Color {
        if let _ = error {
            return colorScheme == .dark ? AppColors.Dark.error : AppColors.error
        }
        return colorScheme == .dark ? AppColors.Dark.border : AppColors.border
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            if localSeconds > 0 {
                localSeconds -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    AppCodeField(
        code: .constant(""),
        seconds: 60
    ) {}
    .padding()
}