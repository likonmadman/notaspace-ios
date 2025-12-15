//
//  TrashView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Экран корзины
struct TrashView: View {
    @StateObject private var viewModel = TrashViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    VStack(spacing: 0) {
                        // Кнопки действий для выбранных элементов
                        if !viewModel.selectedItems.isEmpty {
                            HStack(spacing: 12) {
                                AppButton(
                                    "Восстановить (\(viewModel.selectedItems.count))",
                                    variant: .secondary
                                ) {
                                    let asyncTask = _Concurrency.Task<Void, Never> {
                                        await viewModel.restoreSelected()
                                    }
                                    _ = asyncTask
                                }
                                
                                AppButton(
                                    "Удалить (\(viewModel.selectedItems.count))",
                                    variant: .danger
                                ) {
                                    showDeleteAlert = true
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                        }
                        
                        if viewModel.items.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "trash")
                                    .font(.system(size: 48))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                
                                Text("Корзина пуста")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.items) { item in
                                        TrashItemRowView(
                                            item: item,
                                            isSelected: viewModel.selectedItems.contains(item.id),
                                            onToggleSelection: {
                                                viewModel.toggleSelection(item)
                                            },
                                            onRestore: {
                                                let asyncTask = _Concurrency.Task<Void, Never> {
                                                    await viewModel.restore(item)
                                                }
                                                _ = asyncTask
                                            },
                                            onDelete: {
                                                let asyncTask = _Concurrency.Task<Void, Never> {
                                                    await viewModel.delete(item)
                                                }
                                                _ = asyncTask
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Корзина")
            .navigationBarTitleDisplayMode(.large)
            .alert("Удалить навсегда?", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                    let asyncTask = _Concurrency.Task<Void, Never> {
                        await viewModel.deleteSelected()
                    }
                    _ = asyncTask
                }
            } message: {
                Text("Выбранные элементы будут удалены навсегда. Это действие нельзя отменить.")
            }
            .task {
                await viewModel.loadTrash()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

/// Компонент строки элемента корзины
struct TrashItemRowView: View {
    let item: TrashItem
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onRestore: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Чекбокс выбора
            Button(action: onToggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? AppColors.primary : (colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted))
            }
            
            // Иконка типа
            Image(systemName: item.type == "workspace" ? "folder.fill" : "doc.text.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background((colorScheme == .dark ? AppColors.Dark.card : AppColors.card))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? "Без названия")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                
                HStack(spacing: 8) {
                    Text(item.type == "workspace" ? "Workspace" : "Страница")
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                    
                    if let workspaceName = item.workspaceName {
                        Text("• \(workspaceName)")
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                    }
                    
                    Text("• \(formatDate(item.deletedAt))")
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                }
            }
            
            Spacer()
            
            // Кнопки действий
            HStack(spacing: 8) {
                Button(action: onRestore) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primary)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.error)
                }
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

#Preview {
    TrashView()
}

