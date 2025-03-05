//
//  FacultyHomeScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

struct FacultyHomeScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                FacultyHomeCard(title: "View Attendance", icon: "table") {
                    // Navigate to View Attendance Screen
                }
                
                FacultyHomeCard(title: "Manage Classes", icon: "list.bullet") {
                    // Navigate to Manage Classes Screen
                }
                
                FacultyHomeCard(title: "Profile & Settings", icon: "person") {
                    // Navigate to Profile & Settings Screen
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Faculty Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Navigate to Take Attendance Screen
                    }) {
                        Image(systemName: "camera")
                            .font(.title2)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

struct FacultyHomeCard: View {
    var title: String
    var icon: String
    var onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 16)
                
                Text(title)
                    .font(.title3)
                
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 4))
        }
    }
}

struct FacultyHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        FacultyHomeScreen()
    }
}
