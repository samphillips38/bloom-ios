import Foundation
import SwiftUI

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
    let iconUrl: String?
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case iconUrl = "icon_url"
        case orderIndex = "order_index"
    }
}

struct Course: Codable, Identifiable {
    let id: String
    let categoryId: String
    let title: String
    let description: String?
    let iconUrl: String?
    let themeColor: String?
    let lessonCount: Int
    let exerciseCount: Int
    let isRecommended: Bool
    let collaborators: [String]?
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, collaborators
        case categoryId = "category_id"
        case iconUrl = "icon_url"
        case themeColor = "theme_color"
        case lessonCount = "lesson_count"
        case exerciseCount = "exercise_count"
        case isRecommended = "is_recommended"
        case orderIndex = "order_index"
    }
    
    var color: Color {
        Color.courseColor(from: themeColor)
    }
}

struct CourseWithLevels: Codable, Identifiable {
    let id: String
    let categoryId: String
    let title: String
    let description: String?
    let iconUrl: String?
    let themeColor: String?
    let lessonCount: Int
    let exerciseCount: Int
    let isRecommended: Bool
    let collaborators: [String]?
    let orderIndex: Int
    let levels: [Level]
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, collaborators, levels
        case categoryId = "category_id"
        case iconUrl = "icon_url"
        case themeColor = "theme_color"
        case lessonCount = "lesson_count"
        case exerciseCount = "exercise_count"
        case isRecommended = "is_recommended"
        case orderIndex = "order_index"
    }
    
    var color: Color {
        Color.courseColor(from: themeColor)
    }
}

struct Level: Codable, Identifiable {
    let id: String
    let courseId: String
    let title: String
    let orderIndex: Int
    let lessons: [Lesson]
    
    enum CodingKeys: String, CodingKey {
        case id, title, lessons
        case courseId = "course_id"
        case orderIndex = "order_index"
    }
}
