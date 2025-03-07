//
//  AttendanceTrackerApp.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/19.
//

import SwiftUI
import Firebase

@main
struct AttendanceTrackerApp: App {
    // Initialize Firebase in the init() method
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

