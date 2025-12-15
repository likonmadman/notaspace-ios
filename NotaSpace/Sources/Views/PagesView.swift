//
//  PagesView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Экран страниц
struct PagesView: View {
    @StateObject private var viewModel = PagesViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.pages.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    VStack(spacing: 0) {
                        // Поиск
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                            
                            TextField("Поиск страниц...", text: $viewModel.searchText)
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Список страниц
                        if viewModel.filteredPages.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 48))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                
                                Text(viewModel.searchText.isEmpty ? "Нет страниц" : "Ничего не найдено")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                
                                if viewModel.searchText.isEmpty {
                                    Text("Создайте первую страницу")
                                        .font(.system(size: 14))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 60)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredPages) { page in
                                        NavigationLink(destination: PageDetailView(pageId: page.uuid)) {
                                            PageRowView(page: page, onFavoriteToggle: {
                                                let asyncTask = _Concurrency.Task<Void, Never> {
                                                    await viewModel.toggleFavorite(page: page)
                                                }
                                                _ = asyncTask
                                            })
                                        }
                                        .buttonStyle(PlainButtonStyle())
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
            .navigationTitle("Страницы")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadPages()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

#Preview {
    PagesView()
}
