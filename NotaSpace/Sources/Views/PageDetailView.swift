//
//  PageDetailView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Детальный экран страницы
struct PageDetailView: View {
    let pageId: String
    @StateObject private var viewModel = PageDetailViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var pageTitle: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? AppColors.Dark.secondaryBg : AppColors.secondaryBg)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.page == nil {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let page = viewModel.page {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Заголовок
                            if page.permissions?.update == true {
                                TextField("Название страницы", text: $pageTitle)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                                    .onChange(of: pageTitle) { newValue in
                                        let asyncTask = _Concurrency.Task<Void, Never> {
                                            await viewModel.updateTitle(newValue)
                                        }
                                        _ = asyncTask
                                    }
                            } else {
                                Text(page.title ?? "Без названия")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                            }
                            
                            // Блоки
                            if let blocks = page.blocks, !blocks.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(blocks.sorted(by: { $0.position < $1.position })) { block in
                                        BlockView(block: block, canEdit: page.permissions?.update == true)
                                    }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 48))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                    
                                    Text("Нет блоков")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                    
                                    if page.permissions?.update == true {
                                        Text("Начните добавлять блоки")
                                            .font(.system(size: 14))
                                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.error)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        AppButton("Повторить") {
                            let asyncTask = _Concurrency.Task<Void, Never> {
                                await viewModel.loadPage(id: pageId)
                            }
                            _ = asyncTask
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                    }
                }
            }
            .task {
                await viewModel.loadPage(id: pageId)
                if let page = viewModel.page {
                    pageTitle = page.title ?? ""
                }
            }
        }
    }
}

/// Компонент отображения блока
struct BlockView: View {
    let block: Block
    let canEdit: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch block.type {
            case "heading1":
                Text(block.content)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
            case "heading2":
                Text(block.content)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
            case "heading3":
                Text(block.content)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
            case "paragraph":
                Text(block.content)
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                    .lineSpacing(4)
            case "bullet":
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                    Text(block.content)
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                }
            case "code":
                Text(block.content)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
                    .cornerRadius(8)
            default:
                Text(block.content)
                    .font(.system(size: 16))
                    .foregroundColor(colorScheme == .dark ? AppColors.Dark.text : AppColors.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

#Preview {
    PageDetailView(pageId: "test-id")
}