//
//  ProfileViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var profile: CustomerProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await CustomerAPI.fetchProfile()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        KeychainService.clear()
    }
}

