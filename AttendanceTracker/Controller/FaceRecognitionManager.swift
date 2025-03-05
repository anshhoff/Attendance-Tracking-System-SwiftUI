import Vision
import UIKit

class FaceRecognitionManager {
    static let shared = FaceRecognitionManager()
    private var registeredFaces: [String: UIImage] = [:] // Stores student faces
    
    // Flag for registration mode
    var isRegistrationMode = false
    var pendingStudentID: String? = nil
    
    // User defaults key for persistence
    private let facesStorageKey = "registeredStudentFaces"
    
    // Initialize and load faces from storage
    private init() {
        loadFacesFromStorage()
    }
    
    // Get list of registered face IDs
    func getRegisteredFaces() -> [String] {
        return Array(registeredFaces.keys).sorted()
    }
    
    // Register a student's face
    func registerFace(studentID: String, image: UIImage) {
        // Store the face image
        registeredFaces[studentID] = image
        print("✅ Face registered for \(studentID)")
        
        // Save to persistent storage
        saveFacesToStorage()
    }
    
    // Remove a face registration
    func removeFace(studentID: String) {
        registeredFaces.removeValue(forKey: studentID)
        saveFacesToStorage()
        print("✅ Removed face for \(studentID)")
    }

    // Match face with registered images
    func matchFace(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            print("❌ Could not convert to CIImage")
            completion(nil)
            return
        }

        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
                print("❌ No faces detected in the input image")
                completion(nil)
                return
            }
            
            // Get the face bounding box
            let faceObservation = results[0]
            let faceBounds = faceObservation.boundingBox
            
            // Compare with registered faces
            var bestMatch: (studentID: String, similarity: Float) = ("", 0)
            
            for (studentID, registeredImage) in self.registeredFaces {
                let similarity = self.compareFaces(inputImage: image, registeredImage: registeredImage)
                
                if similarity > bestMatch.similarity {
                    bestMatch = (studentID, similarity)
                }
            }
            
            // Require a minimum similarity threshold
            if bestMatch.similarity > 0.65 {
                print("✅ Match found: \(bestMatch.studentID) with similarity \(bestMatch.similarity)")
                completion(bestMatch.studentID)
            } else {
                print("❌ No match found. Best match was \(bestMatch.studentID) with similarity \(bestMatch.similarity)")
                completion(nil)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ Face detection error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    // Improved face comparison that uses pixel histogram comparison
    // This is still basic but better than exact matching
    private func compareFaces(inputImage: UIImage, registeredImage: UIImage) -> Float {
        // Normalize images to same size for comparison
        let size = CGSize(width: 128, height: 128)
        
        guard let normalizedInput = normalizeImage(inputImage, toSize: size),
              let normalizedRegistered = normalizeImage(registeredImage, toSize: size),
              let inputPixels = normalizedInput.cgImage?.dataProvider?.data,
              let registeredPixels = normalizedRegistered.cgImage?.dataProvider?.data else {
            return 0.0
        }
        
        // Convert image data to array of bytes
        let inputData = NSData(data: Data(referencing: inputPixels)) as Data
        let registeredData = NSData(data: Data(referencing: registeredPixels)) as Data
        
        // Count matching pixels (with tolerance)
        let length = min(inputData.count, registeredData.count)
        var matchingPixels = 0
        
        // Define tolerance for pixel comparison (0-255)
        let tolerance: UInt8 = 30
        
        for i in stride(from: 0, to: length, by: 4) {  // Stride by 4 for RGBA pixel data
            if i + 3 < length {  // Ensure we have at least RGBA components
                let inputR = inputData[i]
                let inputG = inputData[i+1]
                let inputB = inputData[i+2]
                let inputA = inputData[i+3]
                
                let regR = registeredData[i]
                let regG = registeredData[i+1]
                let regB = registeredData[i+2]
                let regA = registeredData[i+3]
                
                // Check if RGBA values are within tolerance
                if abs(Int16(inputR) - Int16(regR)) <= Int16(tolerance) &&
                   abs(Int16(inputG) - Int16(regG)) <= Int16(tolerance) &&
                   abs(Int16(inputB) - Int16(regB)) <= Int16(tolerance) &&
                   abs(Int16(inputA) - Int16(regA)) <= Int16(tolerance) {
                    matchingPixels += 1
                }
            }
        }
        
        // Calculate similarity (0.0 to 1.0)
        let totalPixels = length / 4  // RGBA has 4 components per pixel
        let similarity = Float(matchingPixels) / Float(totalPixels)
        
        return similarity
    }
    
    // Helper function to normalize image size while maintaining aspect ratio
    private func normalizeImage(_ image: UIImage, toSize size: CGSize) -> UIImage? {
        let aspectRatio = image.size.width / image.size.height
        var newSize: CGSize
        
        if size.width / aspectRatio <= size.height {
            newSize = CGSize(width: size.width, height: size.width / aspectRatio)
        } else {
            newSize = CGSize(width: size.height * aspectRatio, height: size.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    // Save faces to UserDefaults (encoded as Data)
    private func saveFacesToStorage() {
        let userDefaults = UserDefaults.standard
        let facesDictionary = Dictionary(uniqueKeysWithValues: registeredFaces.map { key, value in
            (key, value.pngData() ?? Data())
        })
        
        userDefaults.set(facesDictionary, forKey: facesStorageKey)
        userDefaults.synchronize()
    }

    
    private func loadFacesFromStorage() {
        let storedFaces = FaceStorageManager.shared.getRegisteredFaces()
        registeredFaces = storedFaces
    }
}
