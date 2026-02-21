import Foundation

enum APIEndpoint {
    // Base URL - Change this to your Railway deployment URL
    static let baseURL = "http://localhost:3000/api"
    
    // Auth
    case register
    case login
    case socialLogin
    case profile
    
    // Courses
    case categories
    case courses
    case recommendedCourses
    case course(id: String)
    case lesson(id: String)
    case levelLessons(levelId: String)
    
    // Progress
    case userStats
    case courseProgress(courseId: String)
    case lessonProgress(lessonId: String)
    case updateProgress
    case consumeEnergy
    
    var path: String {
        switch self {
        case .register: return "/auth/register"
        case .login: return "/auth/login"
        case .socialLogin: return "/auth/social"
        case .profile: return "/auth/profile"
            
        case .categories: return "/courses/categories"
        case .courses: return "/courses"
        case .recommendedCourses: return "/courses/recommended"
        case .course(let id): return "/courses/\(id)"
        case .lesson(let id): return "/courses/lessons/\(id)"
        case .levelLessons(let levelId): return "/courses/levels/\(levelId)/lessons"
            
        case .userStats: return "/progress/stats"
        case .courseProgress(let courseId): return "/progress/course/\(courseId)"
        case .lessonProgress(let lessonId): return "/progress/lesson/\(lessonId)"
        case .updateProgress: return "/progress/update"
        case .consumeEnergy: return "/progress/energy/consume"
        }
    }
    
    var url: URL {
        URL(string: APIEndpoint.baseURL + path)!
    }
    
    var method: String {
        switch self {
        case .register, .login, .socialLogin, .updateProgress, .consumeEnergy:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .register, .login, .socialLogin, .categories, .courses, .recommendedCourses, .course, .lesson, .levelLessons:
            return false
        default:
            return true
        }
    }
}
