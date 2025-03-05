//
//  SwiftUIView.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/19.
//

import SwiftUI
import AVFoundation
import Vision

struct FaceDetectionScreen: View {
    @State private var image: UIImage? = nil
    @State private var showImagePicker = false
    @State private var faceDetected = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
            }
            
            Text(faceDetected)
                .foregroundColor(.red)
                .bold()
            
            Button("Capture Face") {
                showImagePicker.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image, onImagePicked: detectFaces)
        }
    }
    
    func detectFaces(from image: UIImage?) {
        guard let cgImage = image?.cgImage else { return }
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                faceDetected = "Error detecting face: \(error.localizedDescription)"
            } else if let results = request.results as? [VNFaceObservation], !results.isEmpty {
                faceDetected = "Face Detected!"
            } else {
                faceDetected = "No Face Detected!"
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage?) -> Void
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
                parent.onImagePicked(selectedImage)
            }
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct FaceDetectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        FaceDetectionScreen()
    }
}
