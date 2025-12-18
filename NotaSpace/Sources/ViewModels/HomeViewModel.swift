//
//  HomeViewModel.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import Foundation
import SwiftUI

/// ViewModel для главного экрана
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentPages: [Page] = []
    @Published var workspaces: [Workspace] = []
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let pageService = PageService()
    private let workspaceService = WorkspaceService()
    private let activityService = ActivityService()
    
    /// Загрузить все данные для главного экрана
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let recentPagesTask = pageService.getPages(sort: "-updated_at", perPage: 6)
            async let workspacesTask = workspaceService.getWorkspaces(withStats: true, perPage: 12)
            async let activitiesTask = activityService.getActivities(limit: 6)
            
            let (recentPagesResponse, workspacesResponse, activitiesResponse) = try await (
                recentPagesTask,
                workspacesTask,
                activitiesTask
            )
            
            recentPages = recentPagesResponse.data
            workspaces = workspacesResponse.data.public
            activities = activitiesResponse.data
        } catch {
            errorMessage = "Не удалось загрузить данные: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Обновить данные
    func refresh() async {
        await loadData()
    }
}




