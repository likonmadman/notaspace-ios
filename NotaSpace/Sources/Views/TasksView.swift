//
//  TasksView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Экран задач
struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    if viewModel.tasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            
                            Text("Нет задач")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                            
                            Text("Создайте первую задачу")
                                .font(.system(size: 14))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.tasks) { task in
                                    TaskRowView(task: task)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadTasks()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

/// Компонент строки задачи
struct TaskRowView: View {
    let task: Task
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background((colorScheme == .dark ? AppColors.Dark.card : AppColors.card))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    if let status = task.status {
                        Text(status)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary.opacity(0.1))
                            .foregroundColor(AppColors.primary)
                            .cornerRadius(6)
                    }
                    
                    if let priority = task.priority {
                        Text(priority)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((colorScheme == .dark ? AppColors.Dark.card : AppColors.card))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
            
            if task.favorite == true {
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
}

#Preview {
    TasksView()
}
