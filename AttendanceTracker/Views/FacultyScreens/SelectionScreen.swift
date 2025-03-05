//
//  SelectionScreen.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/22.
//
import SwiftUI

struct SelectionScreen: View {
    @State private var selectedBranch: String = ""
    @State private var selectedBatch: String = ""
    @State private var selectedCourse: String = ""
    
    @State private var isBranchExpanded = false
    @State private var isBatchExpanded = false
    @State private var isCourseExpanded = false
    
    let branchList: [String]
    let batchList: [String]
    let courseList: [String]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Branch Dropdown
                Text("Choose Branch:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Menu {
                    ForEach(branchList, id: \.self) { branch in
                        Button(branch) {
                            selectedBranch = branch
                        }
                    }
                } label: {
                    DropdownLabel(title: selectedBranch.isEmpty ? "Select Branch" : selectedBranch)
                }
                
                // Batch Dropdown
                Text("Choose Batch:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Menu {
                    ForEach(batchList, id: \.self) { batch in
                        Button(batch) {
                            selectedBatch = batch
                        }
                    }
                } label: {
                    DropdownLabel(title: selectedBatch.isEmpty ? "Select Batch" : selectedBatch)
                }
                
                // Course Dropdown
                Text("Choose Course:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Menu {
                    ForEach(courseList, id: \.self) { course in
                        Button(course) {
                            selectedCourse = course
                        }
                    }
                } label: {
                    DropdownLabel(title: selectedCourse.isEmpty ? "Select Course" : selectedCourse)
                }
                
                // Selected Items
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Branch: \(selectedBranch)").font(.subheadline)
                    Text("Selected Batch: \(selectedBatch)").font(.subheadline)
                    Text("Selected Course: \(selectedCourse)").font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Capture Button
                Button(action: {
                    // Navigate to Face Detection Screen
                }) {
                    Text("Capture")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Selection Screen")
        }
    }
}

struct DropdownLabel: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
    }
}

// Preview
struct SelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        SelectionScreen(
            branchList: ["CSE", "ECE", "DSAI"],
            batchList: ["2021", "2022", "2023"],
            courseList: ["DSA", "OS", "DBMS"]
        )
    }
}
