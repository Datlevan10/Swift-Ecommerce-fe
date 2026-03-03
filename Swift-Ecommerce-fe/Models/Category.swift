//
//  Category.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 21/01/2026.
//

import Foundation

struct CategoryResponse: Codable {
    let success: Bool
    let data: [Category]
    let count: Int
}

struct Category: Codable, Identifiable {
    let categoryId: String
    let categoryName: String
    let description: String
    let parentId: String?
    let slug: String
    let imageUrl: String
    let isActive: Bool
    let sortOrder: Int
    
    var id: String { categoryId }
}
