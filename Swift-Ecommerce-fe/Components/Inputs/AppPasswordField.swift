//
//  AppPasswordField.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct AppPasswordField: View {

    let title: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                if showPassword {
                    TextField("Enter password", text: $text)
                } else {
                    SecureField("Enter password", text: $text)
                }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error == nil ? Color.gray.opacity(0.4) : Color.red)
            )

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
