//
//  AuthResponse.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthData
}

struct AuthData: Codable {
    let customer: Customer
    let tokens: AuthTokens
}

struct Customer: Codable {
    let customerId: String
    let fullName: String
    let email: String
    let phone: String?
    let emailVerifiedAt: String?
}

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
}

