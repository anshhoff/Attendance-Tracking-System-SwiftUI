//
//  StudentHomeScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//

import SwiftUI

struct StudentHomeScreen: View {
    let studentName: String = "Harshit"
    
    let subjects = [
        SubjectAttendance(name: "Mathematics", attendance: 85),
        SubjectAttendance(name: "Physics", attendance: 78),
        SubjectAttendance(name: "Computer Science", attendance: 92),
        SubjectAttendance(name: "English", attendance: 88)
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Today's Attendance")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                List(subjects) { subject in
                    NavigationLink(destination: AttendanceDetailsScreen(subject: subject)) {
                        SubjectAttendanceCard(subject: subject)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Welcome, \(studentName)!")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(getCurrentDate())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Attendance Details Screen
struct AttendanceDetailsScreen: View {
    let subject: SubjectAttendance
    
    var body: some View {
        VStack {
            Text(subject.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            Text("Your Attendance: \(subject.attendance)%")
                .font(.title2)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Details")
    }
}

// MARK: - Subject Attendance Card
struct SubjectAttendanceCard: View {
    let subject: SubjectAttendance
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(subject.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Attendance: \(subject.attendance)%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// MARK: - SubjectAttendance Model
struct SubjectAttendance: Identifiable {
    let id = UUID()
    let name: String
    let attendance: Int
}

// MARK: - Date Helper
func getCurrentDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy"
    return formatter.string(from: Date())
}

// MARK: - Preview
struct StudentHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        StudentHomeScreen()
    }
}
