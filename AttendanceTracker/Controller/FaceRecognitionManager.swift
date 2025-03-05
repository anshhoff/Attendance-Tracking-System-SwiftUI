import Foundation

class FaceRecognitionManager {
    static let shared = FaceRecognitionManager()
    
    private let storageKey = "face_embeddings"

    // Function to store a face embedding
    func storeFaceEmbedding(for studentID: String, embedding: [Float]) {
        var faceData = getStoredEmbeddings()
        faceData[studentID] = embedding
        saveToLocalStorage(faceData)
    }
    
    // Function to retrieve stored embeddings
    func getStoredEmbeddings() -> [String: [Float]] {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let storedEmbeddings = try? JSONDecoder().decode([String: [Float]].self, from: data) {
            return storedEmbeddings
        }
        return [:]
    }
    
    // Function to compare face embeddings
    func matchFace(embedding: [Float]) -> String? {
        let storedEmbeddings = getStoredEmbeddings()
        
        for (studentID, storedEmbedding) in storedEmbeddings {
            if cosineSimilarity(embedding, storedEmbedding) > 0.85 {
                return studentID // Match found
            }
        }
        return nil // No match
    }
    
    // Save data locally
    private func saveToLocalStorage(_ data: [String: [Float]]) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
        }
    }
    
    // Function to calculate similarity
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let dotProduct = zip(a, b).map(*).reduce(0, +)
        let magnitudeA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (magnitudeA * magnitudeB)
    }
}
