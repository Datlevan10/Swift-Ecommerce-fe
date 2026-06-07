//
//  AuthAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

class AuthAPI {
    static let shared = AuthAPI()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Register
    func register(request: RegisterRequest) async throws -> AuthData {
        return try await apiClient.request(
            "/auth/register",
            method: .post,
            body: request
        )
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> AuthData {
        let request = LoginRequest(email: email, password: password)
        return try await apiClient.request(
            "/auth/login",
            method: .post,
            body: request
        )
    }
    
    // MARK: - Verify Email
    func verifyEmail(token: String) async throws -> MessageResponse {
        return try await apiClient.request(
            "/auth/verify-email",
            method: .post,
            body: VerifyEmailRequest(token: token)
        )
    }
    
    // MARK: - Forgot Password
    func forgotPassword(email: String) async throws -> MessageResponse {
        return try await apiClient.request(
            "/auth/forgot-password",
            method: .post,
            body: ForgotPasswordRequest(email: email)
        )
    }
    
    // MARK: - Reset Password
    func resetPassword(token: String, password: String) async throws -> MessageResponse {
        return try await apiClient.request(
            "/auth/reset-password",
            method: .post,
            body: ResetPasswordRequest(token: token, password: password)
        )
    }
    
    // MARK: - Logout
    func logout() async throws {
        let _: EmptyResponse = try await apiClient.request(
            "/auth/logout",
            method: .post
        )
        KeychainService.shared.clearTokens()
    }
    
    // MARK: - Get Profile
    func getProfile() async throws -> Customer {
        return try await apiClient.request("/auth/profile")
    }
}

// MARK: - Request Models
struct VerifyEmailRequest: Codable {
    let token: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let token: String
    let password: String
}

struct MessageResponse: Codable {
    let message: String
}
