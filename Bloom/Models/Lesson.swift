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

// ── Rich Text Segment ──

struct TextSegment: Codable {
    let text: String
    let bold: Bool?
    let italic: Bool?
    let color: String?       // "accent", "secondary", "success", "warning", "blue", "purple"
    let underline: Bool?
    let definition: String?  // tappable definition popover
    let latex: Bool?         // render as inline LaTeX
}

// ── Content Blocks (composing a rich page) ──

enum ContentBlock: Codable {
    case heading(HeadingBlock)
    case paragraph(ParagraphBlock)
    case image(ImageBlock)
    case math(MathBlock)
    case callout(CalloutBlock)
    case bulletList(BulletListBlock)
    case animation(AnimationBlock)
    case interactive(InteractiveBlock)
    case spacer(SpacerBlock)
    case divider
    
    struct HeadingBlock: Codable {
        let type: String
        let segments: [TextSegment]
        let level: Int?
    }
    
    struct ParagraphBlock: Codable {
        let type: String
        let segments: [TextSegment]
    }
    
    struct ImageBlock: Codable {
        let type: String
        let src: String
        let alt: String?
        let caption: String?
        let style: String?  // "full", "inline", "icon"
    }
    
    struct MathBlock: Codable {
        let type: String
        let latex: String
        let caption: String?
    }
    
    struct CalloutBlock: Codable {
        let type: String
        let style: String   // "info", "tip", "warning", "example"
        let title: String?
        let segments: [TextSegment]
    }
    
    struct BulletListBlock: Codable {
        let type: String
        let items: [[TextSegment]]
    }
    
    struct AnimationBlock: Codable {
        let type: String
        let src: String
        let autoplay: Bool?
        let loop: Bool?
        let caption: String?
    }
    
    struct InteractiveBlock: Codable {
        let type: String
        let componentId: String
        let props: [String: AnyCodable]?
    }
    
    struct SpacerBlock: Codable {
        let type: String
        let size: String?   // "sm", "md", "lg"
    }
    
    private enum TypeKey: String, CodingKey { case type }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypeKey.self)
        let type = try container.decode(String.self, forKey: .type)
        let singleContainer = try decoder.singleValueContainer()
        
        switch type {
        case "heading":
            self = .heading(try singleContainer.decode(HeadingBlock.self))
        case "paragraph":
            self = .paragraph(try singleContainer.decode(ParagraphBlock.self))
        case "image":
            self = .image(try singleContainer.decode(ImageBlock.self))
        case "math":
            self = .math(try singleContainer.decode(MathBlock.self))
        case "callout":
            self = .callout(try singleContainer.decode(CalloutBlock.self))
        case "bulletList":
            self = .bulletList(try singleContainer.decode(BulletListBlock.self))
        case "animation":
            self = .animation(try singleContainer.decode(AnimationBlock.self))
        case "interactive":
            self = .interactive(try singleContainer.decode(InteractiveBlock.self))
        case "spacer":
            self = .spacer(try singleContainer.decode(SpacerBlock.self))
        case "divider":
            self = .divider
        default:
            self = .divider
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .heading(let b): try container.encode(b)
        case .paragraph(let b): try container.encode(b)
        case .image(let b): try container.encode(b)
        case .math(let b): try container.encode(b)
        case .callout(let b): try container.encode(b)
        case .bulletList(let b): try container.encode(b)
        case .animation(let b): try container.encode(b)
        case .interactive(let b): try container.encode(b)
        case .spacer(let b): try container.encode(b)
        case .divider: try container.encode(["type": "divider"])
        }
    }
}

// ── Top-level Content Data ──

enum ContentData: Codable {
    // New rich page format
    case page(PageContent)
    // Question (with optional rich text segments)
    case question(QuestionContent)
    // Legacy types
    case text(TextContent)
    case image(LegacyImageContent)
    case interactive(LegacyInteractiveContent)
    
    struct PageContent: Codable {
        let type: String
        let blocks: [ContentBlock]
    }
    
    struct TextContent: Codable {
        let type: String
        let text: String
        let formatting: TextFormatting?
    }
    
    struct TextFormatting: Codable {
        let bold: Bool?
        let superscript: Bool?
    }
    
    struct LegacyImageContent: Codable {
        let type: String
        let url: String
        let caption: String?
    }
    
    struct QuestionContent: Codable {
        let type: String
        let question: String
        let questionSegments: [TextSegment]?
        let options: [String]
        let optionSegments: [[TextSegment]]?
        let correctIndex: Int
        let explanation: String?
        let explanationSegments: [TextSegment]?
    }
    
    struct LegacyInteractiveContent: Codable {
        let type: String
        let componentId: String
        let props: [String: String]?
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let pageContent = try? container.decode(PageContent.self), pageContent.type == "page" {
            self = .page(pageContent)
        } else if let questionContent = try? container.decode(QuestionContent.self), questionContent.type == "question" {
            self = .question(questionContent)
        } else if let textContent = try? container.decode(TextContent.self), textContent.type == "text" {
            self = .text(textContent)
        } else if let imageContent = try? container.decode(LegacyImageContent.self), imageContent.type == "image" {
            self = .image(imageContent)
        } else if let interactiveContent = try? container.decode(LegacyInteractiveContent.self), interactiveContent.type == "interactive" {
            self = .interactive(interactiveContent)
        } else {
            self = .text(TextContent(type: "text", text: "", formatting: nil))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .page(let content): try container.encode(content)
        case .question(let content): try container.encode(content)
        case .text(let content): try container.encode(content)
        case .image(let content): try container.encode(content)
        case .interactive(let content): try container.encode(content)
        }
    }
}

// ── AnyCodable helper for flexible props ──

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) { self.value = value }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) { value = s }
        else if let i = try? container.decode(Int.self) { value = i }
        else if let d = try? container.decode(Double.self) { value = d }
        else if let b = try? container.decode(Bool.self) { value = b }
        else if let a = try? container.decode([AnyCodable].self) { value = a.map { $0.value } }
        else if let d = try? container.decode([String: AnyCodable].self) { value = d.mapValues { $0.value } }
        else { value = "" }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let s = value as? String { try container.encode(s) }
        else if let i = value as? Int { try container.encode(i) }
        else if let d = value as? Double { try container.encode(d) }
        else if let b = value as? Bool { try container.encode(b) }
        else { try container.encode("\(value)") }
    }
}
