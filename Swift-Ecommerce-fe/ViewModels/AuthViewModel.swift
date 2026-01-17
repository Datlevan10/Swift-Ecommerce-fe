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

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        showErrorAlert = false
        showSuccessAlert = false

        do {
            let response = try await AuthAPI.login(
                email: email,
                password: password
            )

            if response.success {
                KeychainService.saveToken(
                    response.data.tokens.accessToken
                )

                showSuccessAlert = true
                isLoggedIn = true

            } else {
                errorMessage = response.message
                showErrorAlert = true
            }

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

            let response = try await AuthAPI.register(request: request)

            KeychainService.saveToken(
                response.data.tokens.accessToken
            )

            isLoggedIn = true

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

}
