import SwiftUI
import Vision
import UIKit

struct FaceDetectionScreen: View {
    @State private var detectedStudentID: String? = nil
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var registeredFaces: [String] = []
    @State private var showRegistrationSheet = false
    @State private var newStudentID = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Face Detection")
                .font(.title)
                .fontWeight(.bold)
            
            if isProcessing {
                ProgressView("Processing...")
                    .padding()
            } else {
                if let studentID = detectedStudentID {
                    Text(studentID)
                        .font(.title2)
                        .foregroundColor(studentID.contains("Not") ? .red : .green)
                        .padding()
                        .background(studentID.contains("Not") ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text("Ready for face detection")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.vertical, 10)
                }
            }
            
            Button("Capture & Recognize") {
                isCameraPresented = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isProcessing)
            
            Button("Register New Face") {
                showRegistrationSheet = true
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isProcessing)
            
            // List of registered faces
            if !registeredFaces.isEmpty {
                VStack(alignment: .leading) {
                    Text("Registered Faces:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ScrollView {
                        ForEach(registeredFaces, id: \.self) { face in
                            HStack {
                                Text(face)
                                Spacer()
                                Button(action: {
                                    FaceRecognitionManager.shared.removeFace(studentID: face)
                                    loadRegisteredFaces()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(maxHeight: 150)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            loadRegisteredFaces()
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraView { image in
                capturedImage = image
                recognizeFace()
            }
        }
        .sheet(isPresented: $showRegistrationSheet) {
            registerFaceView
        }
    }
    
    private var registerFaceView: some View {
        VStack(spacing: 20) {
            Text("Register New Face")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Student ID", text: $newStudentID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Capture Face") {
                showRegistrationSheet = false
                isCameraPresented = true
                FaceRecognitionManager.shared.isRegistrationMode = true
                FaceRecognitionManager.shared.pendingStudentID = newStudentID
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(newStudentID.isEmpty)
            
            Button("Cancel") {
                showRegistrationSheet = false
            }
            .padding()
        }
        .padding()
    }
    
    private func loadRegisteredFaces() {
        registeredFaces = FaceRecognitionManager.shared.getRegisteredFaces()
    }
    
    private func recognizeFace() {
        guard let image = capturedImage else { return }
        
        // Check if we're in registration mode
        if FaceRecognitionManager.shared.isRegistrationMode,
           let studentID = FaceRecognitionManager.shared.pendingStudentID {
            isProcessing = true
            
            // Register the face
            FaceRecognitionManager.shared.registerFace(studentID: studentID, image: image)
            
            // Save the image to local storage
            if let url = FaceStorageManager.shared.saveImageToLocal(image, studentID: studentID) {
                print("Image saved to: \(url)")
            }
            
            // Reset registration mode
            FaceRecognitionManager.shared.isRegistrationMode = false
            FaceRecognitionManager.shared.pendingStudentID = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                detectedStudentID = "Face Registered: \(studentID)"
                isProcessing = false
                loadRegisteredFaces()
            }
            return
        }
        
        // Normal recognition flow
        isProcessing = true
        
        FaceRecognitionManager.shared.matchFace(image: image) { studentID, similarity in
            DispatchQueue.main.async {
                if let studentID = studentID {
                    self.detectedStudentID = "Recognized: \(studentID)"
                } else {
                    self.detectedStudentID = "Face Not Recognized"
                }
                self.isProcessing = false
            }
        }
    }
}

struct FaceDetectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        FaceDetectionScreen()
    }
}
