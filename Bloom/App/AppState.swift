import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userStats: UserStats?
    @Published var isLoading = false
    @Published var error: String?
    
    private let authManager = AuthManager.shared
    private let apiClient = APIClient.shared
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        if authManager.isAuthenticated {
            isAuthenticated = true
            Task {
                await loadUserData()
            }
        }
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await authManager.login(email: email, password: password)
        currentUser = response.user
        isAuthenticated = true
        await loadUserData()
    }
    
    func register(name: String, email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await authManager.register(name: name, email: email, password: password)
        currentUser = response.user
        isAuthenticated = true
        await loadUserData()
    }
    
    func logout() {
        authManager.logout()
        currentUser = nil
        userStats = nil
        isAuthenticated = false
    }
    
    func loadUserData() async {
        do {
            userStats = try await apiClient.getUserStats()
        } catch {
            print("Failed to load user stats: \(error)")
        }
    }
    
    func refreshStats() async {
        await loadUserData()
    }
}

struct UserStats: Codable {
    let streak: Streak?
    let energy: Int
    let completedLessons: Int
    let totalScore: Int
}

struct Streak: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let lastActivityDate: String?
}
