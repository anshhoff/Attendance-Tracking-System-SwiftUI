import SwiftUI

class FaceStorageManager {
    static let shared = FaceStorageManager() // Singleton instance
    
    private init() {} // Private initializer to prevent multiple instances
    
    // Function to save image to local storage
    func saveImageToLocal(_ image: UIImage, studentID: String) -> URL? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(studentID).jpg")
            try? data.write(to: filename)
            return filename
        }
        return nil
    }

    // Function to load image from local storage
    func loadImageFromLocal(studentID: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(studentID).jpg")
        return UIImage(contentsOfFile: fileURL.path)
    }

    // Get documents directory path
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
