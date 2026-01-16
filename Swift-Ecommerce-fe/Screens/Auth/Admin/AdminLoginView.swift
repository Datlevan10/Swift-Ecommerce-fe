//
//  AdminLoginView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct AdminLoginView: View {
    var body: some View {
        VStack(spacing: 24) {

            Text("Admin Login")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: .constant(""))
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: .constant(""))
                .textFieldStyle(.roundedBorder)

            Button("Login") {
                print("Admin login")
            }
            .buttonStyle(.borderedProminent)

//            NavigationLink("Create Admin Account") {
//                AdminRegisterView()
//            }

            Spacer()
        }
        .padding()
        .navigationTitle("Admin")
    }
}

