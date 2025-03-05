//
//  FaceStorageManager.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/23.
//

import SwiftUI

class FaceStorageManager {
    static let shared = FaceStorageManager() // Singleton instance
    
    private init() {} // Private constructor to prevent multiple instances
    
    // Function to save image as PNG
    func saveImageToLocal(_ image: UIImage, studentID: String) -> URL? {
        if let data = image.pngData() { // Save as PNG
            let filename = getDocumentsDirectory().appendingPathComponent("\(studentID).png")
            try? data.write(to: filename)
            return filename
        }
        return nil
    }

    // Function to load image from local storage
    func loadImageFromLocal(studentID: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(studentID).png")
        return UIImage(contentsOfFile: fileURL.path)
    }

    // Get documents directory path
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    // Load all registered faces from local storage
    func getRegisteredFaces() -> [String: UIImage] {
        var faces: [String: UIImage] = [:]
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs where fileURL.pathExtension == "png" {
                let studentID = fileURL.deletingPathExtension().lastPathComponent
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    faces[studentID] = image
                }
            }
        } catch {
            print("Error loading faces: \(error)")
        }
        
        return faces
    }
}
