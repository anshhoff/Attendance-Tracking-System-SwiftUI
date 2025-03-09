//
//  FaceRegistrationView.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/23.
//
// FaceRegistrationView.swift
import SwiftUI

struct FaceRegistrationView: View {
    @State private var studentID: String = ""
    @State private var studentName: String = "" // Add this line for student name
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            TextField("Enter Student ID", text: $studentID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter Student Name", text: $studentName) // Add this TextField
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Pick Image") {
                isImagePickerPresented.toggle()
            }
            .padding()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            }

            Button("Register Face") {
                if let image = selectedImage {
                    // Register face with FaceRecognitionManager (saves to UserDefaults)
                    FaceRecognitionManager.shared.registerFace(studentID: studentID, name: studentName, image: image) // Add name parameter
                    
                    // Save image to local storage using FaceStorageManager
                    if let url = FaceStorageManager.shared.saveImageToLocal(image, studentID: studentID) {
                        print("Image saved to: \(url)")
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}
