import SwiftUI
import AVFoundation
import Vision

struct CameraView: View {
    @ObservedObject var cameraManager = CameraManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var recognizedStudent: String? = nil
    @State private var detectionConfidence: Float = 0.0
    @State private var showCaptureButton = true
    @State private var flashMode: Bool = false
    
    var onImageCaptured: (UIImage) -> Void  // Closure to send image back
    var isRegistrationMode: Bool = false  // Flag to check if in registration mode

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .onAppear {
                    cameraManager.startSession()
                }
                .onDisappear {
                    cameraManager.stopSession()
                }
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.yellow, lineWidth: 3)
                        .frame(width: 250, height: 300)
                        .background(Color.clear)
                )

            VStack {
                HStack {
                    Button(action: {
                        flashMode.toggle()
                        cameraManager.toggleTorch(on: flashMode)
                    }) {
                        Image(systemName: flashMode ? "bolt.fill" : "bolt.slash")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cameraManager.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                if let student = recognizedStudent {
                    Text("Recognized: \(student)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.green)
                } else {
                    Text("Position your face in the frame")
                        .font(.title)
                        .foregroundColor(.white)
                }

                HStack(spacing: 30) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    if showCaptureButton {
                        Button(action: {
                            cameraManager.captureImage { image in
                                onImageCaptured(image)
                                if isRegistrationMode {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                )
                        }
                    }
                    
                    Button(action: {
                        cameraManager.toggleAutoCapture()
                        showCaptureButton.toggle()
                    }) {
                        Image(systemName: showCaptureButton ? "timer" : "hand.raised")
                            .font(.system(size: 24))
                            .padding()
                            .background(showCaptureButton ? Color.blue : Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(cameraManager.$lastCapturedImage) { image in
            if let image = image {
                recognizeFace(image: image)
            }
        }
    }
    
    private func recognizeFace(image: UIImage) {
        guard !isRegistrationMode else { return }
        
        guard let ciImage = CIImage(image: image) else {
            print("❌ Could not convert to CIImage")
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
                print("❌ No faces detected in the input image")
                return
            }
            
            let recognitionTask = DispatchWorkItem {
                FaceRecognitionManager.shared.matchFace(image: image) { studentID in
                    DispatchQueue.main.async {
                        if let studentID = studentID {
                            self.recognizedStudent = studentID
                            print("✅ Match found: \(studentID)")
                        } else {
                            self.recognizedStudent = nil
                            print("❌ No match found")
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                recognitionTask.perform()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ Face detection error: \(error.localizedDescription)")
            }
        }
    }
}

// Camera Preview Layer
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.frame
        view.layer.addSublayer(layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
