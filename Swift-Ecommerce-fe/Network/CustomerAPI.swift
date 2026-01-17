//
//  CustomerAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

enum CustomerAPI {

    static func fetchProfile() async throws -> CustomerProfile {

        guard let token = KeychainService.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = URL(string: "http://localhost:3000/api/customers/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        struct Response: Codable {
            let success: Bool
            let data: CustomerProfile
        }

        return try JSONDecoder().decode(Response.self, from: data).data
    }
}

