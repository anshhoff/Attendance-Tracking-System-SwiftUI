//
//  ContentView.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        NavigationStack {
            if !appState.isInitialized {
                SplashScreen()
            } else {
                if appState.isAuthenticated {
                    FacultyHomeScreen()
                } else {
                    LoginScreen()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
