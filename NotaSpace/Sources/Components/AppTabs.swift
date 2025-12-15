//
//  AppTabs.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

/// Компонент табов в стиле веб-приложения
struct AppTabs: View {
    struct Tab: Identifiable {
        let id: String
        let label: String
    }
    
    let tabs: [Tab]
    @Binding var selectedTab: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs) { tab in
                Button(action: {
                    selectedTab = tab.id
                }) {
                    Text(tab.label)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            selectedTab == tab.id 
                                ? AppColors.secondaryText 
                                : (colorScheme == .dark ? AppColors.Dark.muted : AppColors.muted)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(selectedTab == tab.id ? AppColors.primary : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(colorScheme == .dark ? AppColors.Dark.card : AppColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? AppColors.Dark.border : AppColors.border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    AppTabs(
        tabs: [
            AppTabs.Tab(id: "email", label: "Почта"),
            AppTabs.Tab(id: "phone", label: "Телефон")
        ],
        selectedTab: .constant("email")
    )
    .padding()
}

