//
//  NotificationsView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Экран уведомлений
struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    if viewModel.notifications.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bell")
                                .font(.system(size: 48))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            
                            Text("Нет уведомлений")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                // Кнопка "Отметить все как прочитанные"
                                if viewModel.unreadCount > 0 {
                                    AppButton("Отметить все как прочитанные", variant: .secondary) {
                                        let asyncTask = _Concurrency.Task<Void, Never> {
                                            await viewModel.markAllAsRead()
                                        }
                                        _ = asyncTask
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                                }
                                
                                ForEach(viewModel.notifications) { notification in
                                    NotificationRowView(
                                        notification: notification,
                                        onRead: {
                                            let asyncTask = _Concurrency.Task<Void, Never> {
                                                await viewModel.markAsRead(notification)
                                            }
                                            _ = asyncTask
                                        },
                                        onDelete: {
                                            let asyncTask = _Concurrency.Task<Void, Never> {
                                                await viewModel.deleteNotification(notification)
                                            }
                                            _ = asyncTask
                                        }
                                    )
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.unreadCount > 0 {
                        Text("\(viewModel.unreadCount)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.secondaryText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                }
            }
            .task {
                await viewModel.loadNotifications()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

/// Компонент строки уведомления
struct NotificationRowView: View {
    let notification: Notification
    let onRead: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Индикатор непрочитанного
            if !notification.read {
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 8, height: 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 16, weight: notification.read ? .regular : .semibold))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                
                if let message = notification.message {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        .lineLimit(2)
                }
                
                Text(formatDate(notification.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
            }
            
            Spacer()
            
            // Кнопка удаления
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            notification.read
                ? Color.clear
                : (colorScheme == .dark ? AppColors.Dark.card.opacity(0.5) : AppColors.card.opacity(0.5))
        )
        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            if !notification.read {
                onRead()
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "ru_RU")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    NotificationsView()
}