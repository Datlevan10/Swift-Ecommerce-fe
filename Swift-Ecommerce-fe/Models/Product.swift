//
//  Product.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

struct Product: Codable, Identifiable {
    let productId: String
    let categoryId: String
    let productName: String
    let slug: String
    let description: String
    let color: [String]
    let size: [String]
    let image: [String]
    let newPrice: Double
    let oldPrice: Double?
    let quantityInStock: Int
    let status: ProductStatus
    let category: Category?
    let averageRating: Double?
    let totalReviews: Int?
    let createdAt: String
    let updatedAt: String
    
    var id: String { productId }
    
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: newPrice)) ?? "$0.00"
    }
    
    var discountPercentage: Int? {
        guard let oldPrice = oldPrice, oldPrice > newPrice else { return nil }
        return Int(((oldPrice - newPrice) / oldPrice) * 100)
    }
    
    var isInStock: Bool {
        quantityInStock > 0
    }
    
    var primaryImageURL: String? {
        image.first
    }
}

enum ProductStatus: String, Codable {
    case active = "active"
    case inactive = "inactive"
    case outOfStock = "out_of_stock"
}