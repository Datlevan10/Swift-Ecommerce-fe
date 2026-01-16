//
//  CustomerRegisterView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct CustomerRegisterView: View {

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var acceptTerms = false

    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Title
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Register as a customer")
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)

                // MARK: - Full Name
                AppTextField(
                    title: "Full Name",
                    placeholder: "Enter your full name",
                    text: $fullName,
                    showClear: true
                )

                // MARK: - Email
                AppTextField(
                    title: "Email",
                    placeholder: "Enter your email",
                    text: $email,
                    keyboard: .emailAddress,
                    error: emailError,
                    showClear: true
                )
                .onChange(of: email) {
                    emailError = email.isEmpty
                        ? nil
                        : (Validator.isValidEmail(email)
                            ? nil
                            : "Invalid email format")
                }

                // MARK: - Phone
                AppTextField(
                    title: "Phone Number",
                    placeholder: "Enter your phone number",
                    text: $phone,
                    keyboard: .phonePad,
                    showClear: true
                )

                // MARK: - Password
                AppPasswordField(
                    title: "Password",
                    text: $password,
                    showPassword: $showPassword,
                    error: passwordError
                )
                .onChange(of: password) {
                    passwordError = password.isEmpty
                        ? nil
                        : (Validator.isValidPassword(password)
                            ? nil
                            : "Min 8 chars, uppercase, lowercase, number & symbol")
                }

                // MARK: - Confirm Password
                AppPasswordField(
                    title: "Confirm Password",
                    text: $confirmPassword,
                    showPassword: $showPassword,
                    error: confirmPasswordError
                )
                .onChange(of: confirmPassword) {
                    confirmPasswordError = confirmPassword.isEmpty
                        ? nil
                        : (confirmPassword == password
                            ? nil
                            : "Passwords do not match")
                }

                // MARK: - Terms
                Toggle("I agree to the Terms & Conditions", isOn: $acceptTerms)

                // MARK: - Register Button
                Button {
                    print("Customer register success")
                } label: {
                    Text("Create Account")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(canSubmit ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(14)
                .disabled(!canSubmit)

                // MARK: - Login
                HStack {
                    Text("Already have an account?")
                    NavigationLink("Login") {
                        CustomerLoginView()
                    }
                    .fontWeight(.bold)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Submit condition
    private var canSubmit: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        Validator.isValidEmail(email) &&
        !password.isEmpty &&
        Validator.isValidPassword(password) &&
        confirmPassword == password &&
        acceptTerms
    }
}
