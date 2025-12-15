//
//  PageDetailViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для детального экрана страницы
@MainActor
final class PageDetailViewModel: ObservableObject {
    @Published var page: PageDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let pageService = PageService()
    // Используем DispatchWorkItem для избежания конфликта с моделью Task
    private var saveWorkItem: DispatchWorkItem?
    
    /// Загрузить страницу
    func loadPage(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            page = try await pageService.getPageDetail(id: id)
        } catch {
            errorMessage = "Не удалось загрузить страницу: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Обновить блоки страницы (с автосохранением)
    func updateBlocks(_ blocks: [Block]) {
        guard let pageId = page?.id else { return }
        
        // Отменяем предыдущую задачу сохранения
        saveWorkItem?.cancel()
        
        // Создаем новую задачу с задержкой
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Используем отдельную async функцию для избежания конфликта с моделью Task
            self.performDelayedSave(pageId: pageId, blocks: blocks)
        }
        saveWorkItem = workItem
        
        // Запускаем задачу с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
    
    /// Выполнить отложенное сохранение блоков
    private func performDelayedSave(pageId: String, blocks: [Block]) {
        // Используем async функцию напрямую через Task для избежания конфликта с моделью Task
        // Используем полное имя типа через модуль _Concurrency
        typealias AsyncTask = _Concurrency.Task
        let asyncTask = AsyncTask<Void, Never> { @MainActor in
            do {
                try await AsyncTask.sleep(nanoseconds: 1_000_000_000) // 1 секунда
                self.page = try await self.pageService.updatePageBlocks(pageId: pageId, blocks: blocks)
            } catch {
                self.errorMessage = "Не удалось сохранить изменения: \(error.localizedDescription)"
            }
        }
        _ = asyncTask // Сохраняем ссылку на задачу
    }
    
    /// Обновить заголовок страницы
    func updateTitle(_ title: String) async {
        guard let pageId = page?.id else { return }
        
        do {
            let updatedPage = try await pageService.updatePage(id: pageId, title: title)
            // Обновляем только заголовок локально
            if var currentPage = page {
                // Создаем новую страницу с обновленным заголовком
                // Так как PageDetail - struct, нужно создать новый экземпляр
                // Для упрощения перезагрузим страницу
                await loadPage(id: pageId)
            }
        } catch {
            errorMessage = "Не удалось обновить заголовок: \(error.localizedDescription)"
        }
    }
}

