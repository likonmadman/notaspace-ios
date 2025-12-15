//
//  MainTabView.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Главный экран с табами
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
            
            PagesView()
                .tabItem {
                    Label("Страницы", systemImage: "doc.text.fill")
                }
            
            TasksView()
                .tabItem {
                    Label("Задачи", systemImage: "checkmark.circle.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}

