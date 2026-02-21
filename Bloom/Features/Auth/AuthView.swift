import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoginMode = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Title
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.bloomOrange)
                        
                        Text("Bloom")
                            .font(.bloomDisplay)
                            .foregroundColor(.bloomTextPrimary)
                        
                        Text("Learn anything, beautifully.")
                            .font(.bloomBody)
                            .foregroundColor(.bloomTextSecondary)
                    }
                    .padding(.top, 60)
                    
                    // Mode Toggle
                    HStack(spacing: 0) {
                        Button {
                            withAnimation { isLoginMode = true }
                        } label: {
                            Text("Sign In")
                                .font(.bloomBodyMedium)
                                .foregroundColor(isLoginMode ? .white : .bloomTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isLoginMode ? Color.bloomOrange : Color.clear)
                                )
                        }
                        
                        Button {
                            withAnimation { isLoginMode = false }
                        } label: {
                            Text("Sign Up")
                                .font(.bloomBodyMedium)
                                .foregroundColor(!isLoginMode ? .white : .bloomTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(!isLoginMode ? Color.bloomOrange : Color.clear)
                                )
                        }
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        if !isLoginMode {
                            BloomTextField(
                                placeholder: "Full Name",
                                text: $name,
                                icon: "person"
                            )
                        }
                        
                        BloomTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope"
                        )
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                        BloomTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            icon: "lock"
                        )
                        .textContentType(isLoginMode ? .password : .newPassword)
                    }
                    
                    // Submit Button
                    BloomButton(
                        title: isLoginMode ? "Sign In" : "Create Account",
                        color: .bloomOrange,
                        action: handleSubmit,
                        isLoading: appState.isLoading,
                        isDisabled: !isFormValid
                    )
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                        Text("or continue with")
                            .font(.bloomCaption)
                            .foregroundColor(.bloomTextMuted)
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                    }
                    
                    // Social Login Buttons
                    VStack(spacing: 12) {
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 56)
                        .cornerRadius(16)
                        
                        Button {
                            // Google Sign-In would be implemented here
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                Text("Continue with Google")
                                    .font(.bloomButton)
                            }
                            .foregroundColor(.bloomTextPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.bloomBackground)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !name.isEmpty && !email.isEmpty && password.count >= 8
        }
    }
    
    private func handleSubmit() {
        Task {
            do {
                if isLoginMode {
                    try await appState.login(email: email, password: password)
                } else {
                    try await appState.register(name: name, email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        Task {
            do {
                switch result {
                case .success(let authorization):
                    let response = try await AuthManager.shared.signInWithApple(authorization: authorization)
                    appState.currentUser = response.user
                    appState.isAuthenticated = true
                    await appState.loadUserData()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
