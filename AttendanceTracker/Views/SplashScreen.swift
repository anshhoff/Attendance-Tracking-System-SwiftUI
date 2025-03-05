//
//  SplashScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            LoginScreen() // Navigate to LoginScreen after delay
        } else {
            VStack {
                Text("Attendance Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isActive = true
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
