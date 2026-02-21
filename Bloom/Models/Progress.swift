import Foundation

struct UserProgress: Codable, Identifiable {
    let id: String
    let userId: String
    let lessonId: String
    let completed: Bool
    let score: Int?
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, completed, score
        case userId = "user_id"
        case lessonId = "lesson_id"
        case completedAt = "completed_at"
    }
}

struct ProgressUpdate: Codable {
    let lessonId: String
    let completed: Bool?
    let score: Int?
}
