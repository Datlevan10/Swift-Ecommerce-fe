//
//  CartAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

class CartAPI {
    static let shared = CartAPI()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Get Cart
    func getCart() async throws -> Cart {
        return try await apiClient.request("/cart")
    }
    
    // MARK: - Add Item to Cart
    func addToCart(request: AddToCartRequest) async throws -> CartItem {
        return try await apiClient.request(
            "/cart/items",
            method: .post,
            body: request
        )
    }
    
    // MARK: - Update Cart Item
    func updateCartItem(id: String, quantity: Int) async throws -> CartItem {
        return try await apiClient.request(
            "/cart/items/\(id)",
            method: .put,
            body: UpdateCartItemRequest(quantity: quantity)
        )
    }
    
    // MARK: - Remove Cart Item
    func removeCartItem(id: String) async throws -> MessageResponse {
        return try await apiClient.request(
            "/cart/items/\(id)",
            method: .delete
        )
    }
    
    // MARK: - Clear Cart
    func clearCart() async throws -> MessageResponse {
        return try await apiClient.request(
            "/cart/clear",
            method: .delete
        )
    }
}

// MARK: - Cart Models
struct Cart: Codable {
    let cartId: String?
    let customerId: String
    let items: [CartItem]
    let totalAmount: Double
    let itemCount: Int
    
    var displayTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "$0.00"
    }
}

struct CartItem: Codable, Identifiable {
    let cartItemId: String
    let cartId: String
    let productId: String
    let quantity: Int
    let selectedColor: String?
    let selectedSize: String?
    let price: Double
    let product: Product?
    
    var id: String { cartItemId }
    
    var subtotal: Double {
        Double(quantity) * price
    }
    
    var displaySubtotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: subtotal)) ?? "$0.00"
    }
}

// MARK: - Request Models
struct AddToCartRequest: Codable {
    let productId: String
    let quantity: Int
    let selectedColor: String?
    let selectedSize: String?
}

struct UpdateCartItemRequest: Codable {
    let quantity: Int
}