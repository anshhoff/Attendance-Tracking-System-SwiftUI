// AttendanceListView.swift
import SwiftUI

struct StudentAttendance: Identifiable {
    let id: String
    let name: String
    let timestamp: Date
    let entryID: UUID // Unique identifier for each attendance entry
    
    var identifiableId: UUID { entryID } // Use UUID for identification
    
    init(id: String, name: String, timestamp: Date) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.entryID = UUID() // Generate a unique ID on initialization
    }
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
    
    func removeStudent(entryID: UUID) {
        presentStudents = presentStudents.filter { $0.entryID != entryID }
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
                            Text(student.timestamp.formatted(date: .abbreviated, time: .standard))
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            attendanceManager.removeStudent(entryID: student.entryID)
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
