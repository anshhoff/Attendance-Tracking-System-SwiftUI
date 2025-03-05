//
//  CameraView.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/23.
//


import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var cameraManager = CameraManager()
    
    var onCapture: (UIImage) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .onAppear { cameraManager.startSession() }
                .onDisappear { cameraManager.stopSession() }
            
            VStack {
                Spacer()
                Button(action: {
                    cameraManager.capturePhoto { image in
                        if let image = image {
                            onCapture(image)
                        }
                    }
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                }
                .padding(.bottom, 30)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Camera Manager
class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private var output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupSession()
    }
    
    func setupSession() {
        session.beginConfiguration()
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let input = try? AVCaptureDeviceInput(device: device) {
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
        self.completionHandler = completion
    }
    
    private var completionHandler: ((UIImage?) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            completionHandler?(nil)
            return
        }
        completionHandler?(image)
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
