//
//  TrashViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для экрана корзины
@MainActor
final class TrashViewModel: ObservableObject {
    @Published var items: [TrashItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedItems: Set<Int> = []
    
    private let trashService = TrashService()
    
    /// Загрузить элементы корзины
    func loadTrash() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await trashService.getTrash()
            items = response.data
        } catch {
            errorMessage = "Не удалось загрузить корзину: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Обновить корзину
    func refresh() async {
        await loadTrash()
    }
    
    /// Восстановить элемент
    func restore(_ item: TrashItem) async {
        do {
            try await trashService.restore(type: item.type, id: item.id)
            items.removeAll { $0.id == item.id }
            selectedItems.remove(item.id)
        } catch {
            errorMessage = "Не удалось восстановить элемент: \(error.localizedDescription)"
        }
    }
    
    /// Удалить элемент навсегда
    func delete(_ item: TrashItem) async {
        do {
            try await trashService.delete(type: item.type, id: item.id)
            items.removeAll { $0.id == item.id }
            selectedItems.remove(item.id)
        } catch {
            errorMessage = "Не удалось удалить элемент: \(error.localizedDescription)"
        }
    }
    
    /// Восстановить выбранные элементы
    func restoreSelected() async {
        let itemsToRestore = items.filter { selectedItems.contains($0.id) }
        for item in itemsToRestore {
            await restore(item)
        }
    }
    
    /// Удалить выбранные элементы навсегда
    func deleteSelected() async {
        let itemsToDelete = items.filter { selectedItems.contains($0.id) }
        for item in itemsToDelete {
            await delete(item)
        }
    }
    
    /// Переключить выбор элемента
    func toggleSelection(_ item: TrashItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
}