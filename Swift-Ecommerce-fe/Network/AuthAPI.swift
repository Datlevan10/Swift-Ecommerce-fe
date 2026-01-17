//
//  AuthAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

enum AuthAPI {

    static let baseURL = "http://localhost:3000/api/auth"

    // MARK: - Login
    static func login(
        email: String,
        password: String
    ) async throws -> AuthResponse {

        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

    // MARK: - Register
    static func register(
        request: RegisterRequest
    ) async throws -> AuthResponse {

        let url = URL(string: "\(baseURL)/register")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

}
