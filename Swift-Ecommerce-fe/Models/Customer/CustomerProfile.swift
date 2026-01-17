//
//  CustomerProfile.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

struct CustomerProfile: Codable {
    let customerId: String
    let fullName: String
    let email: String
    let phone: String?
    let avatarUrl: String?
    let status: String
}

