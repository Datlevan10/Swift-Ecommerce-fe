//
//  CategoryAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 21/01/2026.
//

import Foundation

enum CategoryAPI {
    
    static let baseURL = "http://localhost:3000/api"
    
    static func fetchCategories() async throws -> CategoryResponse {
        let url = URL(string: "\(baseURL)/categories")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(CategoryResponse.self, from: data)
    }
}
