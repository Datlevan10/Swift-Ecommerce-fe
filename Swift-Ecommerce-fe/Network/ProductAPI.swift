//
//  ProductAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

class ProductAPI {
    static let shared = ProductAPI()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Get All Products
    func getProducts(
        includeCategory: Bool = true,
        page: Int? = nil,
        limit: Int? = nil
    ) async throws -> ProductsResponse {
        var parameters: [String: Any] = [:]
        
        if includeCategory {
            parameters["includeCategory"] = true
        }
        
        if let page = page {
            parameters["page"] = page
        }
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        return try await apiClient.request(
            "/products",
            parameters: parameters.isEmpty ? nil : parameters
        )
    }
    
    // MARK: - Get Product by ID
    func getProduct(id: String, includeCategory: Bool = true) async throws -> Product {
        var parameters: [String: Any] = [:]
        
        if includeCategory {
            parameters["includeCategory"] = true
        }
        
        return try await apiClient.request(
            "/products/\(id)",
            parameters: parameters.isEmpty ? nil : parameters
        )
    }
    
    // MARK: - Get Products by Category
    func getProductsByCategory(categoryId: String) async throws -> [Product] {
        return try await apiClient.request("/products/category/\(categoryId)")
    }
    
    // MARK: - Create Product (Admin/Staff)
    func createProduct(product: CreateProductRequest) async throws -> Product {
        return try await apiClient.request(
            "/products",
            method: .post,
            body: product
        )
    }
    
    // MARK: - Update Product (Admin/Staff)
    func updateProduct(id: String, updates: UpdateProductRequest) async throws -> Product {
        return try await apiClient.request(
            "/products/\(id)",
            method: .put,
            body: updates
        )
    }
    
    // MARK: - Delete Product (Admin/Staff)
    func deleteProduct(id: String) async throws -> MessageResponse {
        return try await apiClient.request(
            "/products/\(id)",
            method: .delete
        )
    }
    
    // MARK: - Search Products
    func searchProducts(query: String) async throws -> [Product] {
        return try await apiClient.request(
            "/shop/search",
            parameters: ["q": query]
        )
    }
    
    // MARK: - Get Featured Products
    func getFeaturedProducts() async throws -> [Product] {
        return try await apiClient.request("/shop/featured")
    }
    
    // MARK: - Get Top Rated Products
    func getTopRatedProducts(limit: Int = 10) async throws -> [Product] {
        return try await apiClient.request(
            "/top-rated-products",
            parameters: ["limit": limit]
        )
    }
}

// MARK: - Response Models
struct ProductsResponse: Codable {
    let products: [Product]
    let pagination: Pagination?
}

// MARK: - Request Models
struct CreateProductRequest: Codable {
    let categoryId: String
    let productName: String
    let description: String
    let color: [String]
    let size: [String]
    let image: [String]
    let newPrice: Double
    let quantityInStock: Int
}

struct UpdateProductRequest: Codable {
    let categoryId: String?
    let productName: String?
    let description: String?
    let color: [String]?
    let size: [String]?
    let image: [String]?
    let newPrice: Double?
    let quantityInStock: Int?
}