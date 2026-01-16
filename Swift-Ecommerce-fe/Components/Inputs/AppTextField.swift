//
//  AppTextField.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct AppTextField: View {

    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var error: String? = nil
    var showClear: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)

                if showClear && !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
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

