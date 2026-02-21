import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(_, let message):
            return message
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "You are not authorized. Please log in again."
        }
    }
}

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: APIErrorResponse?
}

struct APIErrorResponse: Codable {
    let message: String
}

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
        
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    // MARK: - Generic Request Method
    
    func request<T: Codable>(
        endpoint: APIEndpoint,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if required
        if endpoint.requiresAuth {
            guard let token = KeychainHelper.shared.getToken() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            
            if httpResponse.statusCode >= 400 {
                // Try to decode error message
                if let errorResponse = try? decoder.decode(APIResponse<EmptyResponse>.self, from: data),
                   let error = errorResponse.error {
                    throw APIError.httpError(statusCode: httpResponse.statusCode, message: error.message)
                }
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: "Request failed")
            }
            
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            
            guard apiResponse.success, let responseData = apiResponse.data else {
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: apiResponse.error?.message ?? "Unknown error")
            }
            
            return responseData
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Courses
    
    func getCategories() async throws -> [Category] {
        struct Response: Codable { let categories: [Category] }
        let response: Response = try await request(endpoint: .categories)
        return response.categories
    }
    
    func getCourses(categoryId: String? = nil) async throws -> [Course] {
        struct Response: Codable { let courses: [Course] }
        let response: Response = try await request(endpoint: .courses)
        return response.courses
    }
    
    func getRecommendedCourses() async throws -> [Course] {
        struct Response: Codable { let courses: [Course] }
        let response: Response = try await request(endpoint: .recommendedCourses)
        return response.courses
    }
    
    func getCourse(id: String) async throws -> CourseWithLevels {
        struct Response: Codable { let course: CourseWithLevels }
        let response: Response = try await request(endpoint: .course(id: id))
        return response.course
    }
    
    func getLesson(id: String) async throws -> LessonWithContent {
        struct Response: Codable { let lesson: LessonWithContent }
        let response: Response = try await request(endpoint: .lesson(id: id))
        return response.lesson
    }
    
    // MARK: - Progress
    
    func getUserStats() async throws -> UserStats {
        struct Response: Codable { let stats: UserStats }
        let response: Response = try await request(endpoint: .userStats)
        return response.stats
    }
    
    func getCourseProgress(courseId: String) async throws -> [UserProgress] {
        struct Response: Codable { let progress: [UserProgress] }
        let response: Response = try await request(endpoint: .courseProgress(courseId: courseId))
        return response.progress
    }
    
    func updateProgress(lessonId: String, completed: Bool, score: Int? = nil) async throws -> UserProgress {
        struct Body: Codable { let lessonId: String; let completed: Bool; let score: Int? }
        struct Response: Codable { let progress: UserProgress }
        let body = Body(lessonId: lessonId, completed: completed, score: score)
        let response: Response = try await request(endpoint: .updateProgress, body: body)
        return response.progress
    }
    
    func consumeEnergy(amount: Int = 1) async throws -> Int {
        struct Body: Codable { let amount: Int }
        struct Response: Codable { let energy: Int }
        let response: Response = try await request(endpoint: .consumeEnergy, body: Body(amount: amount))
        return response.energy
    }
}

struct EmptyResponse: Codable {}
