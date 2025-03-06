import Vision
import UIKit

class FaceRecognitionManager {
    static let shared = FaceRecognitionManager()
    private var registeredFaces: [String: (image: UIImage, faceRect: CGRect)] = [:]
    private let facesStorageKey = "registeredStudentFaces"
    private let recognitionThreshold: Float = 0.55 // Configurable threshold
    var isRegistrationMode = false
    var pendingStudentID: String? = nil
    
    private init() {
        loadFacesFromStorage()
    }
    
    // MARK: - Public Interface
    
    func getRegisteredFaces() -> [String] {
        return Array(registeredFaces.keys).sorted()
    }
    
    func registerFace(studentID: String, image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self,
                  let results = request.results as? [VNFaceObservation],
                  let face = results.first else { return }
            
            self.registeredFaces[studentID] = (image: image, faceRect: face.boundingBox)
            DispatchQueue.main.async {
                self.saveFacesToStorage()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    func removeFace(studentID: String) {
        registeredFaces.removeValue(forKey: studentID)
        saveFacesToStorage()
    }
    
    func matchFace(image: UIImage, completion: @escaping (String?, Float) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil, 0.0)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
                print("❌ No faces detected in the input image")
                completion(nil, 0.0)
                return
            }
            
            let inputFaceImage = self.cropFace(from: image, faceRect: results[0].boundingBox)
            var bestMatch: (studentID: String, similarity: Float) = ("", 0)
            
            for (studentID, data) in self.registeredFaces {
                let registeredFaceImage = self.cropFace(from: data.image, faceRect: data.faceRect)
                let similarity = self.compareFaces(inputImage: inputFaceImage, registeredImage: registeredFaceImage)
                
                if similarity > bestMatch.similarity {
                    bestMatch = (studentID, similarity)
                }
            }
            
            if bestMatch.similarity > 0.55 {
                print("✅ Match found: \(bestMatch.studentID) with similarity \(bestMatch.similarity)")
                completion(bestMatch.studentID, bestMatch.similarity)
            } else {
                print("❌ No match found. Best match was \(bestMatch.studentID) with similarity \(bestMatch.similarity)")
                completion(nil, bestMatch.similarity)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(nil, 0.0)
            }
        }
    }
    
    // MARK: - Image Processing
    
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
    
    private func compareFaces(inputImage: UIImage, registeredImage: UIImage) -> Float {
        let size = CGSize(width: 128, height: 128)
        
        guard let normalizedInput = normalizeImage(inputImage, toSize: size),
              let normalizedRegistered = normalizeImage(registeredImage, toSize: size),
              let inputPixels = normalizedInput.cgImage?.dataProvider?.data,
              let registeredPixels = normalizedRegistered.cgImage?.dataProvider?.data else {
            return 0.0
        }
        
        let inputData = Data(referencing: inputPixels)
        let registeredData = Data(referencing: registeredPixels)
        
        let length = min(inputData.count, registeredData.count)
        var matchingPixels = 0
        let tolerance: UInt8 = 30
        
        for i in stride(from: 0, to: length, by: 4) {
            if i + 3 < length {
                let inputR = inputData[i]
                let inputG = inputData[i+1]
                let inputB = inputData[i+2]
                let regR = registeredData[i]
                let regG = registeredData[i+1]
                let regB = registeredData[i+2]
                
                if abs(Int16(inputR) - Int16(regR)) <= Int16(tolerance) &&
                   abs(Int16(inputG) - Int16(regG)) <= Int16(tolerance) &&
                   abs(Int16(inputB) - Int16(regB)) <= Int16(tolerance) {
                    matchingPixels += 1
                }
            }
        }
        
        let totalPixels = (length / 4)
        return Float(matchingPixels) / Float(totalPixels)
    }
    
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
    
    // MARK: - Data Storage
    
    private func saveFacesToStorage() {
        let userDefaults = UserDefaults.standard
        var facesData: [String: Data] = [:]
        
        for (studentID, data) in registeredFaces {
            let faceData = FaceData(image: data.image, faceRect: data.faceRect)
            if let encodedData = try? JSONEncoder().encode(faceData) {
                facesData[studentID] = encodedData
            }
        }
        
        DispatchQueue.main.async {
            userDefaults.set(facesData, forKey: self.facesStorageKey)
        }
    }
    
    private func loadFacesFromStorage() {
        let userDefaults = UserDefaults.standard
        if let storedFaces = userDefaults.dictionary(forKey: facesStorageKey) as? [String: Data] {
            storedFaces.forEach { studentID, data in
                if let faceData = try? JSONDecoder().decode(FaceData.self, from: data),
                   let image = UIImage(data: faceData.image) {
                    registeredFaces[studentID] = (image: image, faceRect: faceData.faceRect)
                }
            }
        }
    }
    
    // MARK: - Helper Structures
    
    private struct FaceData: Codable {
        let image: Data
        let faceRect: CGRect
        
        init(image: UIImage, faceRect: CGRect) {
            self.image = image.pngData()!
            self.faceRect = faceRect
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.image = try container.decode(Data.self, forKey: .image)
            self.faceRect = try container.decode(CGRect.self, forKey: .faceRect)
        }
        
        enum CodingKeys: String, CodingKey {
            case image
            case faceRect
        }
    }
}
