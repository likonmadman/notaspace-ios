//
//  ProfileView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Экран профиля
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Информация о пользователе
                        if let user = authViewModel.currentUser {
                            VStack(spacing: 16) {
                                // Аватар
                                if let avatar = user.avatar, let avatarUrl = avatar.url, let url = URL(string: avatarUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(AppColors.primary.opacity(0.2))
                                            .overlay(
                                                Text(user.name.prefix(1).uppercased())
                                                    .font(.system(size: 32, weight: .bold))
                                                    .foregroundColor(AppColors.primary)
                                            )
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(AppColors.primary.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text(user.name.prefix(1).uppercased())
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(AppColors.primary)
                                        )
                                }
                                
                                VStack(spacing: 4) {
                                    Text(user.name)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                    
                                    if let email = user.email {
                                        Text(email)
                                            .font(.system(size: 16))
                                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                    }
                                }
                            }
                            .padding(.top, 20)
                        }
                        
                        // Настройки
                        VStack(spacing: 0) {
                            NavigationLink(destination: NotificationsView()) {
                                SettingsRowView(
                                    icon: "bell",
                                    title: "Уведомления",
                                    color: AppColors.primary
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(colorScheme == .dark ? AppColors.Dark.border : AppColors.border)
                            
                            NavigationLink(destination: TrashView()) {
                                SettingsRowView(
                                    icon: "trash",
                                    title: "Корзина",
                                    color: AppColors.primary
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(colorScheme == .dark ? AppColors.Dark.border : AppColors.border)
                            
                            SettingsRowView(
                                icon: "lock",
                                title: "Безопасность",
                                color: AppColors.primary
                            )
                        }
                        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Выход
                        AppButton("Выйти", variant: .danger) {
                            showLogoutAlert = true
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .alert("Выход", isPresented: $showLogoutAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Выйти", role: .destructive) {
                    let asyncTask = _Concurrency.Task<Void, Never> {
                        await authViewModel.logout()
                    }
                    _ = asyncTask
                }
            } message: {
                Text("Вы уверены, что хотите выйти?")
            }
        }
    }
}

/// Компонент строки настроек
struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
