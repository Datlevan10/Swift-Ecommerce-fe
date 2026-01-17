//
//  HomeView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        Text("Home Screen")
            .font(.title)
            .alert(
                "Login successful",
                isPresented: $authVM.showSuccessAlert
            ) {
                Button("Continue") {
                    authVM.showSuccessAlert = false
                }
            } message: {
                Text("Welcome back! You have logged in successfully.")
            }
    }
}

