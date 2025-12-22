//
//  HomeView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Главная страница
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.recentPages.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.error)
                        
                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        AppButton("Повторить") {
                            let asyncTask = _Concurrency.Task<Void, Never> {
                                await viewModel.loadData()
                            }
                            _ = asyncTask
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Приветствие
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Добро пожаловать в NotaSpace!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                
                                Text("Создавай заметки, доски и страницы")
                                    .font(.system(size: 16))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            // Недавние страницы
                            if !viewModel.recentPages.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Недавние страницы")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(viewModel.recentPages) { page in
                                        PageRowView(page: page)
                                    }
                                }
                            }
                            
                            // Workspaces
                            if !viewModel.workspaces.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Workspaces")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(viewModel.workspaces) { workspace in
                                        WorkspaceRowView(workspace: workspace)
                                    }
                                }
                            }
                            
                            // Активность
                            if !viewModel.activities.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Последняя активность")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(viewModel.activities) { activity in
                                        ActivityRowView(activity: activity)
                                    }
                                }
                            }
                            
                            if viewModel.recentPages.isEmpty && viewModel.workspaces.isEmpty && viewModel.activities.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 48))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                    
                                    Text("Нет данных")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                    
                                    Text("Создайте первую страницу или workspace")
                                        .font(.system(size: 14))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("NotaSpace")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadData()
            }
        }
    }
}

/// Компонент строки страницы
struct PageRowView: View {
    let page: Page
    var onFavoriteToggle: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: page.type == "task" ? "checkmark.circle.fill" : "doc.text.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background((colorScheme == .dark ? AppColors.Dark.card : AppColors.card))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(page.title ?? "Без названия")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                
                Text(formatDate(page.updatedAt))
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
            }
            
            Spacer()
            
            if let onFavoriteToggle = onFavoriteToggle {
                Button(action: {
                    onFavoriteToggle()
                }) {
                    Image(systemName: page.favorite == true ? "star.fill" : "star")
                        .font(.system(size: 16))
                        .foregroundColor(page.favorite == true ? .yellow : (colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted))
                }
            } else if page.favorite == true {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
        .cornerRadius(12)
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

/// Компонент строки workspace
struct WorkspaceRowView: View {
    let workspace: Workspace
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background((colorScheme == .dark ? AppColors.Dark.card : AppColors.card))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workspace.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                
                if let description = workspace.description {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
    }
}

/// Компонент строки активности
struct ActivityRowView: View {
    let activity: Activity
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
            
            Text(activity.description)
                .font(.system(size: 14))
                .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
            
            Spacer()
            
            Text(formatDate(activity.createdAt))
                .font(.system(size: 12))
                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    HomeView()
}