import Foundation
import AuthenticationServices

class AuthManager: NSObject {
    static let shared = AuthManager()
    
    private let apiClient = APIClient.shared
    private let keychain = KeychainHelper.shared
    
    var isAuthenticated: Bool {
        keychain.hasToken
    }
    
    // MARK: - Email Authentication
    
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        struct RegisterBody: Codable {
            let name: String
            let email: String
            let password: String
        }
        
        let body = RegisterBody(name: name, email: email, password: password)
        let response: AuthResponse = try await apiClient.request(endpoint: .register, body: body)
        
        keychain.saveToken(response.token)
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        struct LoginBody: Codable {
            let email: String
            let password: String
        }
        
        let body = LoginBody(email: email, password: password)
        let response: AuthResponse = try await apiClient.request(endpoint: .login, body: body)
        
        keychain.saveToken(response.token)
        return response
    }
    
    func logout() {
        keychain.deleteToken()
    }
    
    // MARK: - Social Authentication
    
    func signInWithApple(authorization: ASAuthorization) async throws -> AuthResponse {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }
        
        let email = credential.email ?? ""
        let name = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return try await socialLogin(
            provider: "apple",
            providerId: credential.user,
            email: email.isEmpty ? "\(credential.user)@privaterelay.appleid.com" : email,
            name: name.isEmpty ? "Bloom User" : name
        )
    }
    
    func signInWithGoogle(idToken: String, email: String, name: String, userId: String) async throws -> AuthResponse {
        return try await socialLogin(
            provider: "google",
            providerId: userId,
            email: email,
            name: name
        )
    }
    
    private func socialLogin(provider: String, providerId: String, email: String, name: String) async throws -> AuthResponse {
        struct SocialBody: Codable {
            let provider: String
            let providerId: String
            let email: String
            let name: String
        }
        
        let body = SocialBody(provider: provider, providerId: providerId, email: email, name: name)
        let response: AuthResponse = try await apiClient.request(endpoint: .socialLogin, body: body)
        
        keychain.saveToken(response.token)
        return response
    }
}

enum AuthError: Error, LocalizedError {
    case invalidCredential
    case userNotFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credentials"
        case .userNotFound:
            return "User not found"
        case .networkError:
            return "Network error occurred"
        }
    }
}
