//
//  NotaSpaceApp.swift
//  NotaSpace
//
//  Created on 2025-01-24.
//

import SwiftUI

@main
struct NotaSpaceApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}