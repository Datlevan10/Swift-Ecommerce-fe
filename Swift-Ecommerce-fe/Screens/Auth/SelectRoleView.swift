//
//  SelectRoleView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct SelectRoleView: View {
    @State private var selectedRole: UserRole?

    var body: some View {
        VStack(spacing: 40) {

            VStack(spacing: 8) {
                Text("Select Your Role")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose how you want to use the app")
                    .foregroundColor(.gray)
            }

            VStack(spacing: 20) {

                RoleCard(
                    title: "Admin",
                    subtitle: "Manage products & orders",
                    icon: "shield.lefthalf.filled",
                    color: .blue
                ) {
                    selectedRole = .admin
                }

                RoleCard(
                    title: "Customer",
                    subtitle: "Shop and explore products",
                    icon: "cart.fill",
                    color: .green
                ) {
                    selectedRole = .customer
                }
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedRole) { role in
            switch role {
            case .admin:
                AdminLoginView()
            case .customer:
                CustomerLoginView()
            }
        }
    }
}
