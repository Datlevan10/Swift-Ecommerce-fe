import SwiftUI

struct CustomerLoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showPassword = false

    @State private var emailError: String?
    @State private var passwordError: String?
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Login to your customer account")
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 40)

            // MARK: - Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack {
                    TextField("Enter your email", text: $email)
                        .textInputAutocapitalization(.none)
                        .keyboardType(.emailAddress)

                    if !email.isEmpty {
                        Button {
                            email = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(emailError == nil ? Color.gray.opacity(0.4) : Color.red)
                )
                .onChange(of: email) {
                    if email.isEmpty {
                        emailError = nil
                    } else {
                        emailError = Validator.isValidEmail(email)
                            ? nil
                            : "Invalid email format"
                    }
                }

                if let emailError {
                    Text(emailError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // MARK: - Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack {
                    Group {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
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
                        .stroke(passwordError == nil ? Color.gray.opacity(0.4) : Color.red)
                )
                .onChange(of: password) {
                    if password.isEmpty {
                        passwordError = nil
                    } else {
                        passwordError = Validator.isValidPassword(password)
                            ? nil
                            : "Min 8 chars, uppercase, lowercase, number & symbol"
                    }
                }

                if let passwordError {
                    Text(passwordError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // MARK: - Remember + Forgot
            HStack {
                Toggle(isOn: $rememberMe) {
                    Text("Remember me")
                        .font(.subheadline)
                }
                .toggleStyle(CheckboxToggleStyle())

                Spacer()

                Button("Forgot password?") {
                    print("Forgot password")
                }
                .font(.subheadline)
            }
            .padding(.top, 12)

            Spacer()

            // MARK: - Login button
            Button {
                emailError = nil
                passwordError = nil

                if !Validator.isValidEmail(email) {
                    emailError = "Invalid email format"
                }

                if !Validator.isValidPassword(password) {
                    passwordError = "Password must be at least 8 characters, include uppercase, lowercase, number and special character"
                }

                if emailError == nil && passwordError == nil {
                    print("Customer login success")
                }
                
                Task {
                       await authVM.login(email: email, password: password)
                   }
            } label: {
                Text("Login")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(
                email.isEmpty || password.isEmpty || emailError != nil || passwordError != nil
                ? Color.gray
                : Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(14)
            .disabled(
                email.isEmpty || password.isEmpty || emailError != nil || passwordError != nil
            )
            
            .alert(
                "Login successful",
                isPresented: $authVM.showSuccessAlert
            ) {
                Button("Continue") {
                    authVM.isLoggedIn = true
                }
            } message: {
                Text("Welcome back! You have logged in successfully.")
            }

            
            .alert(
                "Login failed",
                isPresented: $authVM.showErrorAlert
            ) {
                Button("OK", role: .cancel) {
                    authVM.showErrorAlert = false
                }
            } message: {
                Text(authVM.errorMessage ?? "Invalid email or password")
            }


            // MARK: - Register
            HStack {
                Text("Don’t have an account?")
                NavigationLink("Sign up") {
                    CustomerRegisterView()
                }
                .fontWeight(.bold)
            }
            .padding(.top, 16)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        
        .navigationDestination(isPresented: $authVM.isLoggedIn) {
                        HomeTabView()
                    }
    }
}
