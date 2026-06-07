//
//  AuthViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var showSuccessAlert = false
    @Published var isLoggedIn = false
    @Published var currentCustomer: Customer?
    
    private let authAPI = AuthAPI.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isLoggedIn = KeychainService.shared.getAccessToken() != nil
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        showErrorAlert = false
        showSuccessAlert = false
        
        do {
            let authData = try await authAPI.login(
                email: email,
                password: password
            )
            
            // Save tokens
            KeychainService.shared.saveAccessToken(authData.tokens.accessToken)
            KeychainService.shared.saveRefreshToken(authData.tokens.refreshToken)
            
            // Save customer info
            currentCustomer = authData.customer
            
            showSuccessAlert = true
            isLoggedIn = true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showErrorAlert = true
        } catch {
            errorMessage = "Something went wrong. Please try again."
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func register(
        fullName: String,
        email: String,
        phone: String,
        password: String
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(
                fullName: fullName,
                email: email,
                phone: phone,
                password: password
            )
            
            let authData = try await authAPI.register(request: request)
            
            // Save tokens
            KeychainService.shared.saveAccessToken(authData.tokens.accessToken)
            KeychainService.shared.saveRefreshToken(authData.tokens.refreshToken)
            
            // Save customer info
            currentCustomer = authData.customer
            
            isLoggedIn = true
            showSuccessAlert = true
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showErrorAlert = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try await authAPI.logout()
        } catch {
            // Even if API fails, clear local data
        }
        
        KeychainService.shared.clearTokens()
        currentCustomer = nil
        isLoggedIn = false
        
        isLoading = false
    }
    
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authAPI.forgotPassword(email: email)
            showSuccessAlert = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showErrorAlert = true
        } catch {
            errorMessage = "Failed to send reset email."
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func resetPassword(token: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authAPI.resetPassword(token: token, password: password)
            showSuccessAlert = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showErrorAlert = true
        } catch {
            errorMessage = "Failed to reset password."
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func verifyEmail(token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authAPI.verifyEmail(token: token)
            showSuccessAlert = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            showErrorAlert = true
        } catch {
            errorMessage = "Failed to verify email."
            showErrorAlert = true
        }
        
        isLoading = false
    }
}
