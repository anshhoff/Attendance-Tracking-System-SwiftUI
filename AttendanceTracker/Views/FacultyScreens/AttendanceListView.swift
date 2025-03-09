// AttendanceListView.swift
import SwiftUI

struct StudentAttendance: Identifiable {
    let id: String
    let name: String
    let timestamp: Date
    
    var identifiableId: String { id } // This makes it conform to Identifiable
}

class AttendanceManager: ObservableObject {
    static let shared = AttendanceManager()
    
    @Published var presentStudents: [StudentAttendance] = []
    
    private init() {
        loadAttendanceData()
    }
    
    func loadAttendanceData() {
        presentStudents.removeAll()
    }
    
    func recordAttendance(studentID: String, studentName: String) {
        let newAttendance = StudentAttendance(
            id: studentID,
            name: studentName,
            timestamp: Date()
        )
        presentStudents.append(newAttendance)
    }
    
    func removeStudent(id: String) {
        presentStudents = presentStudents.filter { $0.id != id }
    }
    
    private func saveAttendanceData() {
        // Implementation to save attendance data
    }
}

struct AttendanceListView: View {
    @StateObject private var attendanceManager = AttendanceManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(attendanceManager.presentStudents) { student in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(student.name)
                                .font(.headline)
                            Text("ID: \(student.id)")
                                .font(.subheadline)
                            Text(student.timestamp, style: .date)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            attendanceManager.removeStudent(id: student.id)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .navigationTitle("Attendance List")
        }
    }
}

struct AttendanceListView_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceListView()
    }
}
