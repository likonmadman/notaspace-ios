//
//  SignUpView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Экран регистрации
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.mainBg : AppColors.mainBg)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Регистрация")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            AppTextField(
                                placeholder: "Имя",
                                text: $name
                            )
                            
                            AppTextField(
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            AppTextField(
                                placeholder: "Пароль",
                                text: $password,
                                isSecure: true
                            )
                            
                            AppTextField(
                                placeholder: "Подтвердите пароль",
                                text: $confirmPassword,
                                isSecure: true
                            )
                            
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 12))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.error : AppColors.error)
                                    .padding(.horizontal, 4)
                            }
                            
                            AppButton("Зарегистрироваться", isLoading: authViewModel.isLoading) {
                                let asyncTask = _Concurrency.Task<Void, Never> {
                                    await authViewModel.signUp(name: name, email: email, password: password)
                                    if authViewModel.isAuthenticated {
                                        dismiss()
                                    }
                                }
                                _ = asyncTask
                            }
                            .disabled(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty || password != confirmPassword)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}

