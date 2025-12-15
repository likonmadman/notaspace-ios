//
//  LoginView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

// Вспомогательная функция для создания async задачи (избегаем конфликта с моделью Task)
private func runAsync(_ operation: @escaping () async -> Void) {
    // Используем явное указание типа через скобки для избежания конфликта
    // Используем полное имя типа через модуль _Concurrency
    let asyncTask = _Concurrency.Task<Void, Never> {
        await operation()
    }
    _ = asyncTask
}

/// Экран входа
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showSignUp = false
    
    // Табы
    @State private var activeTab = "email"
    
    // Email форма
    @State private var email = ""
    @State private var emailPassword = ""
    
    // Phone форма
    @State private var countryCode = "+7"
    @State private var phone = ""
    @State private var phonePassword = ""
    
    // Общие состояния
    @State private var withPassword = false
    @State private var verifyCode = false
    @State private var code = ""
    @State private var resendCooldown = 0
    @State private var resendTimer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон - для мобильной версии всегда используем secondary-bg из темной темы (как в веб версии)
                AppColors.Dark.secondaryBg
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Заголовок
                        Text("Авторизация")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.Dark.text)
                            .padding(.top, 0)
                            .padding(.bottom, 24)
                        
                        // Табы - принудительно используем темную тему
                        AppTabs(
                            tabs: [
                                AppTabs.Tab(id: "email", label: "Почта"),
                                AppTabs.Tab(id: "phone", label: "Телефон")
                            ],
                            selectedTab: $activeTab
                        )
                        .environment(\.colorScheme, .dark)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        .onChange(of: activeTab) { _ in
                            resetForm()
                        }
                        
                        // Контент формы - принудительно используем темную тему
                        VStack(spacing: 20) {
                            if activeTab == "email" {
                                emailTabContent
                            } else {
                                phoneTabContent
                            }
                            
                            // Переключение между паролем и кодом
                            AppButton(
                                withPassword ? "Войти с кодом" : "Войти с паролем",
                                variant: .secondary
                            ) {
                                withPassword.toggle()
                                verifyCode = false
                                code = ""
                            }
                            .environment(\.colorScheme, .dark)
                            .padding(.top, 4)
                            
                            // Ссылка на регистрацию
                            Button(action: {
                                showSignUp = true
                            }) {
                                Text("Зарегистрироваться")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.primary)
                            }
                            .padding(.top, 4)
                        }
                        .environment(\.colorScheme, .dark)
                        .padding(.horizontal, 20)
                        
                        // Политика конфиденциальности
                        (Text("Продолжая вы соглашаетесь на обработку персональных данных в соответствии с ")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Dark.muted)
                         + Text("политикой конфиденциальности")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primary))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
    // MARK: - Email Tab Content
    
    private var emailTabContent: some View {
        VStack(spacing: 20) {
            AppTextField(
                placeholder: "Введите e-mail",
                text: $email,
                keyboardType: .emailAddress
            )
            .environment(\.colorScheme, .dark)
            
            if withPassword {
                AppTextField(
                    placeholder: "Введите пароль",
                    text: $emailPassword,
                    isSecure: true
                )
                .environment(\.colorScheme, .dark)
                
                AppButton("Войти", isLoading: authViewModel.isLoading) {
                    runAsync {
                        await authViewModel.login(email: email, password: emailPassword)
                    }
                }
                .environment(\.colorScheme, .dark)
                .disabled(authViewModel.isLoading || email.isEmpty || emailPassword.isEmpty)
            } else {
                if !verifyCode {
                    AppButton("Продолжить", isLoading: authViewModel.isLoading) {
                        runAsync {
                            await authViewModel.sendCode(email: email, phone: nil, countryCode: nil)
                            if authViewModel.errorMessage == nil {
                                verifyCode = true
                                resendCooldown = 60
                                startResendTimer()
                            }
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    .disabled(authViewModel.isLoading || email.isEmpty)
                } else {
                    AppCodeField(
                        placeholder: "Введите код из письма",
                        code: $code,
                        error: authViewModel.errorMessage,
                        seconds: resendCooldown
                    ) {
                        runAsync {
                            await authViewModel.sendCode(email: email, phone: nil, countryCode: nil)
                            resendCooldown = 60
                            startResendTimer()
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    
                    AppButton("Проверить код", isLoading: authViewModel.isLoading) {
                        runAsync {
                            await authViewModel.checkCode(email: email, phone: nil, countryCode: nil, code: code)
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    .disabled(authViewModel.isLoading || code.count != 4)
                }
            }
        }
    }
    
    // MARK: - Phone Tab Content
    
    private var phoneTabContent: some View {
        VStack(spacing: 20) {
            HStack(spacing: 5) {
                // Выбор кода страны
                AppCountryCodePicker(selectedCode: $countryCode)
                    .environment(\.colorScheme, .dark)
                
                AppTextField(
                    placeholder: "Введите телефон",
                    text: $phone,
                    keyboardType: .phonePad
                )
                .environment(\.colorScheme, .dark)
                .onChange(of: phone) { newValue in
                    // Оставляем только цифры
                    phone = newValue.filter { $0.isNumber }
                }
            }
            
            if withPassword {
                AppTextField(
                    placeholder: "Введите пароль",
                    text: $phonePassword,
                    isSecure: true
                )
                .environment(\.colorScheme, .dark)
                
                AppButton("Войти", isLoading: authViewModel.isLoading) {
                    runAsync {
                        await authViewModel.login(phone: phone, countryCode: countryCode, password: phonePassword)
                    }
                }
                .environment(\.colorScheme, .dark)
                .disabled(authViewModel.isLoading || phone.isEmpty || phonePassword.isEmpty)
            } else {
                if !verifyCode {
                    AppButton("Продолжить", isLoading: authViewModel.isLoading) {
                        runAsync {
                            await authViewModel.sendCode(email: nil, phone: phone, countryCode: countryCode)
                            if authViewModel.errorMessage == nil {
                                verifyCode = true
                                resendCooldown = 60
                                startResendTimer()
                            }
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    .disabled(authViewModel.isLoading || phone.isEmpty)
                } else {
                    AppCodeField(
                        placeholder: "Введите код из смс",
                        code: $code,
                        error: authViewModel.errorMessage,
                        seconds: resendCooldown
                    ) {
                        runAsync {
                            await authViewModel.sendCode(email: nil, phone: phone, countryCode: countryCode)
                            resendCooldown = 60
                            startResendTimer()
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    
                    AppButton("Проверить код", isLoading: authViewModel.isLoading) {
                        runAsync {
                            await authViewModel.checkCode(email: nil, phone: phone, countryCode: countryCode, code: code)
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    .disabled(authViewModel.isLoading || code.count != 4)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func resetForm() {
        withPassword = false
        verifyCode = false
        code = ""
        email = ""
        emailPassword = ""
        phone = ""
        phonePassword = ""
        resendCooldown = 0
        stopResendTimer()
    }
    
    private func startResendTimer() {
        stopResendTimer()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if resendCooldown > 0 {
                resendCooldown -= 1
            } else {
                stopResendTimer()
            }
        }
    }
    
    private func stopResendTimer() {
        resendTimer?.invalidate()
        resendTimer = nil
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
