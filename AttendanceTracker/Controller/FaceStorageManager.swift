import Foundation
import UIKit

class FaceStorageManager {
    static let shared = FaceStorageManager()
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var facesStorageURL: URL {
        documentsDirectory.appendingPathComponent("registered_faces.json")
    }
    
    func saveImageToLocal(_ image: UIImage, studentID: String) -> URL? {
        let fileName = "\(studentID)_\(UUID().uuidString).jpg" // Changed to .jpg
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Compress image using JPEG with 70% quality
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            print("Error converting image to JPEG data")
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            print("Saved face image to: \(fileURL.path)")
            return fileURL
        } catch {
            print("Error saving face image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getRegisteredImages(for studentID: String) -> [UIImage] {
        let directory = documentsDirectory
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            let faceImages = contents.filter { $0.lastPathComponent.hasPrefix("\(studentID)_") }
            
            var images = [UIImage]()
            for imageURL in faceImages {
                if let image = UIImage(contentsOfFile: imageURL.path) {
                    images.append(image)
                }
            }
            return images
        } catch {
            print("Error retrieving face images: \(error.localizedDescription)")
            return []
        }
    }
}
