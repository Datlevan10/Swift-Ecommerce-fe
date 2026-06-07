//
//  CheckoutView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct CheckoutView: View {
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = "United States"
    @State private var note = ""
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var showingOrderSuccess = false
    @State private var createdOrder: Order?
    
    var body: some View {
        NavigationView {
            Form {
                // Shipping Address Section
                Section("Shipping Address") {
                    TextField("Full Name", text: $fullName)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State/Province", text: $state)
                    TextField("Postal Code", text: $postalCode)
                    TextField("Country", text: $country)
                }
                
                // Payment Method Section
                Section("Payment Method") {
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.displayName)
                                .tag(method)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Order Note Section
                Section("Order Note (Optional)") {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                }
                
                // Order Summary Section
                if let cart = cartViewModel.cart {
                    Section("Order Summary") {
                        ForEach(cart.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.product?.productName ?? "Product")
                                        .font(.subheadline)
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text(item.displaySubtotal)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(cart.displayTotal)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Place Order") {
                        Task {
                            await placeOrder()
                        }
                    }
                    .disabled(!isFormValid || orderViewModel.isLoading)
                }
            }
            .disabled(orderViewModel.isLoading)
            .overlay {
                if orderViewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView("Processing order...")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                }
            }
        }
        .task {
            await cartViewModel.loadCart()
            // Pre-fill with user data if available
            if let customer = KeychainService.shared.getCustomerData() {
                fullName = customer.fullName
                phone = customer.phone ?? ""
            }
        }
        .alert("Order Placed Successfully!", isPresented: $showingOrderSuccess) {
            Button("View Order") {
                if let order = createdOrder {
                    // Navigate to order details
                    dismiss()
                }
            }
            Button("OK") {
                dismiss()
            }
        } message: {
            if let order = createdOrder {
                Text("Your order #\(order.orderCode) has been placed successfully.")
            }
        }
        .alert("Error", isPresented: $orderViewModel.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(orderViewModel.errorMessage ?? "Failed to place order")
        }
    }
    
    var isFormValid: Bool {
        !fullName.isEmpty &&
        !phone.isEmpty &&
        !address.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !postalCode.isEmpty &&
        !country.isEmpty
    }
    
    private func placeOrder() async {
        let shippingAddress = ShippingAddress(
            fullName: fullName,
            phone: phone,
            address: address,
            city: city,
            state: state,
            postalCode: postalCode,
            country: country
        )
        
        if let order = await orderViewModel.createOrder(
            paymentMethod: selectedPaymentMethod,
            shippingAddress: shippingAddress,
            note: note.isEmpty ? nil : note
        ) {
            createdOrder = order
            showingOrderSuccess = true
            
            // Clear cart after successful order
            await cartViewModel.clearCart()
        }
    }
}

#Preview {
    CheckoutView()
}