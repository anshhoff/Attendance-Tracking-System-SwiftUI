import AVFoundation
import UIKit
import Vision
import Combine

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var currentDevice: AVCaptureDevice?
    
    @Published var lastCapturedImage: UIImage?
    private var faceDetectionRequest: VNDetectFaceRectanglesRequest?
    var onFaceDetected: ((UIImage, Float, String?) -> Void)?
    private var autoCapture = false
    
    override init() {
        super.init()
        setupSession()
        setupFaceDetection()
    }
    
    func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Setup front and back cameras
        if let back = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = back
        }
        
        if let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = front
            currentDevice = front
        }
        
        // Start with front camera
        if let current = currentDevice,
           let input = try? AVCaptureDeviceInput(device: current) {
            if session.canAddInput(input) { session.addInput(input) }
        }

        if session.canAddOutput(output) {
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(output)
            
            // Enable auto orientation for proper face detection
            if let connection = output.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }
        }

        session.commitConfiguration()
    }
    
    func setupFaceDetection() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            if let error = error {
                print("Face detection error: \(error)")
                return
            }
            
            if let results = request.results as? [VNFaceObservation], !results.isEmpty {
                // Face detected - would implement recognition here
                // This is where you'd match against student database
                let confidence: Float = results[0].confidence
                
                // Get the face bounding box
                let faceObservation = results[0]
                let faceBounds = faceObservation.boundingBox
                
                // Convert to UIImage for display
                guard let uiImage = self.lastCapturedImage else { return }
                
                // Crop face from image
                let faceImage = self.cropFace(from: uiImage, faceRect: faceBounds)
                
                // Perform recognition
                FaceRecognitionManager.shared.matchFace(image: faceImage) { studentID, similarity in
                    DispatchQueue.main.async {
                        self.onFaceDetected?(uiImage, confidence, studentID)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if let lastImage = self.lastCapturedImage {
                        self.onFaceDetected?(lastImage, 0.0, nil)
                    }
                }
            }
        }
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async { self.session.startRunning() }
        }
    }

    func stopSession() {
        if session.isRunning { session.stopRunning() }
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // Remove existing input
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Switch cameras
        if currentDevice?.position == .front {
            currentDevice = backCamera
        } else {
            currentDevice = frontCamera
        }
        
        // Add new input
        if let newInput = try? AVCaptureDeviceInput(device: currentDevice!) {
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            }
        }
        
        // Update connection for orientation
        if let connection = output.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            // Only mirror if front camera
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = currentDevice?.position == .front
            }
        }
        
        session.commitConfiguration()
    }
    
    func toggleTorch(on: Bool) {
        guard let device = currentDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch couldn't be used: \(error)")
        }
    }
    
    func toggleAutoCapture() {
        autoCapture = !autoCapture
    }
    
    func captureImage(completion: @escaping (UIImage) -> Void) {
        guard let image = lastCapturedImage else { return }
        completion(image)
    }

    // Process frame for face detection
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Convert to UIImage for display
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        
        // Update lastCapturedImage on the main thread
        DispatchQueue.main.async {
            self.lastCapturedImage = uiImage
        }
        
        // Run face detection
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .right)
        do {
            try requestHandler.perform([faceDetectionRequest!])
        } catch {
            print("Error performing face detection: \(error)")
        }
    }
    
    private func cropFace(from image: UIImage, faceRect: CGRect) -> UIImage {
        let imageSize = image.size
        let x = faceRect.origin.x * imageSize.width
        let y = faceRect.origin.y * imageSize.height
        let width = faceRect.width * imageSize.width
        let height = faceRect.height * imageSize.height
        let faceRectInImage = CGRect(x: x, y: y, width: width, height: height)
        
        guard let cgImage = image.cgImage?.cropping(to: faceRectInImage) else {
            return image
        }
        return UIImage(cgImage: cgImage)
    }
}
