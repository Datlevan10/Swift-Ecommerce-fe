//
//  ProfileView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        VStack(spacing: 16) {

            if vm.isLoading {
                ProgressView()
            }

            if let profile = vm.profile {
                VStack(spacing: 8) {
                    Text(profile.fullName)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(profile.email)
                        .foregroundColor(.gray)

                    if let phone = profile.phone {
                        Text(phone)
                    }
                }
            }

            Spacer()

            Button("Logout") {
                vm.logout()
            }
            .foregroundColor(.red)
        }
        .padding()
        .task {
            await vm.loadProfile()
        }
    }
}

