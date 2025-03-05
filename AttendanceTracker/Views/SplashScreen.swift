//
//  SplashScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var isInitialized = false
    @Published var isAuthenticated = false
    
    init() {
        checkAuthState()
    }
    
    private func checkAuthState() {
        // TODO: When Firebase is added, check authentication state here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isInitialized = true
        }
    }
}

struct SplashScreen: View {
    @StateObject private var appState = AppStateManager()
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var navigateToLogin = false  // 🔹 Control navigation

    var body: some View {
        NavigationStack {
            ZStack {
                if navigateToLogin {
                    LoginScreen()
                } else {
                    VStack {
                        Image(systemName: "person.badge.clock.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text("Attendance Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 16)
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                            scale = 1.0
                            opacity = 1.0
                        }

                        // Navigate after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToLogin = true
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .transition(.opacity)
        }
    }
}

// MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
