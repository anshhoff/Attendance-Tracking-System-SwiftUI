//
//  FacultyHomeScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

struct FacultyHomeScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                FacultyHomeCard(title: "View Attendance", icon: "table") {}
                FacultyHomeCard(title: "Manage Classes", icon: "list.bullet") {}
                FacultyHomeCard(title: "Profile & Settings", icon: "person") {}

                NavigationLink(destination: SelectionScreen(
                    branchList: ["CSE", "ECE", "DSAI"],
                    batchList: ["2021", "2022", "2023"],
                    courseList: ["DSA", "OS", "DBMS"]
                )) {
                    FacultyHomeCard(title: "Take Attendance", icon: "camera") {}
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Faculty Dashboard")
        }
    }
}

// MARK: - Faculty Home Card
struct FacultyHomeCard: View {
    var title: String
    var icon: String
    var onClick: () -> Void // Kept for other actions, but not needed for NavigationLink
    
    var body: some View {
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

// MARK: - Preview
struct FacultyHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        FacultyHomeScreen()
    }
}
