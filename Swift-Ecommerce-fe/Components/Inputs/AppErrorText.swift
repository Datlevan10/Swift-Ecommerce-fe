//
//  AppErrorText.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct AppErrorText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.red)
    }
}

