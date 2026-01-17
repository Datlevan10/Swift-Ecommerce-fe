//
//  RegisterRequest.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

struct RegisterRequest: Codable {
    let fullName: String
    let email: String
    let phone: String
    let password: String
}

