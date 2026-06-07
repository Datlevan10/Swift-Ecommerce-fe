//
//  KeychainService.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Security
import Foundation

class KeychainService {
    
    static let shared = KeychainService()
    
    private let service = "SwiftEcommerce"
    private let accessTokenAccount = "accessToken"
    private let refreshTokenAccount = "refreshToken"
    private let customerDataAccount = "customerData"
    
    private init() {}
    
    // MARK: - Access Token
    func saveAccessToken(_ token: String) {
        saveItem(token, account: accessTokenAccount)
    }
    
    func getAccessToken() -> String? {
        return getItem(account: accessTokenAccount)
    }
    
    // MARK: - Refresh Token
    func saveRefreshToken(_ token: String) {
        saveItem(token, account: refreshTokenAccount)
    }
    
    func getRefreshToken() -> String? {
        return getItem(account: refreshTokenAccount)
    }
    
    // MARK: - Customer Data
    func saveCustomerData(_ customer: Customer) {
        guard let data = try? JSONEncoder().encode(customer) else { return }
        let dataString = String(data: data, encoding: .utf8) ?? ""
        saveItem(dataString, account: customerDataAccount)
    }
    
    func getCustomerData() -> Customer? {
        guard let dataString = getItem(account: customerDataAccount),
              let data = dataString.data(using: .utf8),
              let customer = try? JSONDecoder().decode(Customer.self, from: data) else {
            return nil
        }
        return customer
    }
    
    // MARK: - Clear All
    func clearTokens() {
        deleteItem(account: accessTokenAccount)
        deleteItem(account: refreshTokenAccount)
        deleteItem(account: customerDataAccount)
    }
    
    // MARK: - Private Methods
    private func saveItem(_ item: String, account: String) {
        let data = Data(item.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getItem(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard
            status == errSecSuccess,
            let data = result as? Data
        else { return nil }
        
        return String(decoding: data, as: UTF8.self)
    }
    
    private func deleteItem(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

