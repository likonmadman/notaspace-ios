//
//  PagesViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для экрана страниц
@MainActor
final class PagesViewModel: ObservableObject {
    @Published var pages: [Page] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let pageService = PageService()
    
    /// Загрузить список страниц
    func loadPages() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await pageService.getPages(sort: "-updated_at")
            pages = response.data
        } catch {
            errorMessage = "Не удалось загрузить страницы: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Обновить список страниц
    func refresh() async {
        await loadPages()
    }
    
    /// Отфильтрованные страницы по поисковому запросу
    var filteredPages: [Page] {
        if searchText.isEmpty {
            return pages
        }
        return pages.filter { page in
            (page.title?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    /// Переключить избранное
    func toggleFavorite(page: Page) async {
        do {
            _ = try await pageService.toggleFavorite(pageId: page.uuid)
            // Обновляем локально
            if let index = pages.firstIndex(where: { $0.id == page.id }) {
                var updatedPage = pages[index]
                // Создаем новую страницу с обновленным favorite
                // Так как Page - struct, нужно создать новый экземпляр
                // Для упрощения просто перезагрузим список
                await loadPages()
            }
        } catch {
            errorMessage = "Не удалось обновить избранное: \(error.localizedDescription)"
        }
    }
}



