import Foundation

struct Lesson: Codable, Identifiable {
    let id: String
    let levelId: String
    let title: String
    let iconUrl: String?
    let type: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, type
        case levelId = "level_id"
        case iconUrl = "icon_url"
        case orderIndex = "order_index"
    }
    
    var isExercise: Bool {
        type == "exercise"
    }
}

struct LessonWithContent: Codable, Identifiable {
    let id: String
    let levelId: String
    let title: String
    let iconUrl: String?
    let type: String
    let orderIndex: Int
    let content: [LessonContent]
    
    enum CodingKeys: String, CodingKey {
        case id, title, type, content
        case levelId = "level_id"
        case iconUrl = "icon_url"
        case orderIndex = "order_index"
    }
}

struct LessonContent: Codable, Identifiable {
    let id: String
    let lessonId: String
    let orderIndex: Int
    let contentType: String
    let contentData: ContentData
    
    enum CodingKeys: String, CodingKey {
        case id
        case lessonId = "lesson_id"
        case orderIndex = "order_index"
        case contentType = "content_type"
        case contentData = "content_data"
    }
}

enum ContentData: Codable {
    case text(TextContent)
    case image(ImageContent)
    case question(QuestionContent)
    case interactive(InteractiveContent)
    
    struct TextContent: Codable {
        let type: String
        let text: String
        let formatting: TextFormatting?
    }
    
    struct TextFormatting: Codable {
        let bold: Bool?
        let superscript: Bool?
    }
    
    struct ImageContent: Codable {
        let type: String
        let url: String
        let caption: String?
    }
    
    struct QuestionContent: Codable {
        let type: String
        let question: String
        let options: [String]
        let correctIndex: Int
        let explanation: String?
    }
    
    struct InteractiveContent: Codable {
        let type: String
        let componentId: String
        let props: [String: String]?
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try to decode as each type
        if let textContent = try? container.decode(TextContent.self), textContent.type == "text" {
            self = .text(textContent)
        } else if let imageContent = try? container.decode(ImageContent.self), imageContent.type == "image" {
            self = .image(imageContent)
        } else if let questionContent = try? container.decode(QuestionContent.self), questionContent.type == "question" {
            self = .question(questionContent)
        } else if let interactiveContent = try? container.decode(InteractiveContent.self), interactiveContent.type == "interactive" {
            self = .interactive(interactiveContent)
        } else {
            // Default to empty text
            self = .text(TextContent(type: "text", text: "", formatting: nil))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let content):
            try container.encode(content)
        case .image(let content):
            try container.encode(content)
        case .question(let content):
            try container.encode(content)
        case .interactive(let content):
            try container.encode(content)
        }
    }
}
