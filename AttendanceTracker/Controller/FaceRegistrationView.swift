//
//  FaceRegistrationView.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/23.
//

import SwiftUI
import PhotosUI

struct FaceRegistrationView: View {
    @State private var selectedPhoto: UIImage?
    @State private var studentID: String = ""

    var body: some View {
        VStack {
            TextField("Enter Student ID", text: $studentID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let selectedPhoto = selectedPhoto {
                Image(uiImage: selectedPhoto)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
            }

            PhotosPicker(selection: Binding(get: {
                nil
            }, set: { newItem in
                if let data = try? newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedPhoto = image
                }
            })) {
                Text("Select Face Photo")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            Button("Save Face") {
                if let studentID = studentID, !studentID.isEmpty, let image = selectedPhoto {
                    FaceRecognitionManager.shared.saveFaceImage(studentID: studentID, faceImage: image)
                }
            }
            .disabled(selectedPhoto == nil || studentID.isEmpty)
            .padding()
        }
    }
}
