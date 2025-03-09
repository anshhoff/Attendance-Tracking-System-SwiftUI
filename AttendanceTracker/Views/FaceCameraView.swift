// FaceCameraView.swift
import SwiftUI
import AVFoundation
import Vision

struct FaceCameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: FaceCameraView

        init(parent: FaceCameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.parent.processFrame(imageBuffer)
            }
        }
    }
    
    let session = AVCaptureSession()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = controller.view.bounds
        controller.view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCamera(context)
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func setupCamera(_ context: Context) {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Camera setup failed")
            return
        }
        
        if session.canAddInput(input) { session.addInput(input) }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(output) { session.addOutput(output) }
        
        session.commitConfiguration()
        session.startRunning()
    }

    private func processFrame(_ imageBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        
        FaceRecognitionManager.shared.matchFace(image: uiImage) { studentID, studentName, similarity in
            DispatchQueue.main.async {
                if let studentID = studentID {
                    print("✅ Recognized student: \(studentID) (\(studentName ?? "Unknown")) with similarity \(similarity)")
                } else {
                    print("❌ Face not recognized")
                }
            }
        }
    }
}

// Preview
struct FaceCameraView_Previews: PreviewProvider {
    static var previews: some View {
        FaceCameraView()
    }
}
