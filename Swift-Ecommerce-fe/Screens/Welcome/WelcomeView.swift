//
//  WelcomeView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct WelcomeView: View {
    @State private var navigateToRole = false
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            Image("welcome_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(opacity)
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Swift Ecommerce")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("The best shopping experience")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.leading, 0)
                .padding(.bottom, 150)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                opacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                navigateToRole = true
            }
        }

        .navigationDestination(isPresented: $navigateToRole) {
            SelectRoleView()
        }
        .navigationBarBackButtonHidden(true)
    }
}
