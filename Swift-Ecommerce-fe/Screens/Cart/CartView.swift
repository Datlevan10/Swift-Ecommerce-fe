//
//  CartView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.cart == nil {
                    ProgressView("Loading cart...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.hasItems {
                    EmptyCartView()
                } else {
                    VStack {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.cart?.items ?? []) { item in
                                    CartItemRow(item: item, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                        
                        // Cart Summary
                        VStack(spacing: 16) {
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text(viewModel.cartTotal)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                showingCheckout = true
                            }) {
                                Text("Proceed to Checkout")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.bottom)
                        .background(Color.white)
                    }
                }
            }
            .navigationTitle("Shopping Cart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.hasItems {
                        Button("Clear") {
                            Task {
                                await viewModel.clearCart()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .task {
            await viewModel.loadCart()
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView()
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var viewModel: CartViewModel
    @State private var quantity: Int
    
    init(item: CartItem, viewModel: CartViewModel) {
        self.item = item
        self.viewModel = viewModel
        self._quantity = State(initialValue: item.quantity)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            if let product = item.product, let imageURL = product.primaryImageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product?.productName ?? "Product")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let color = item.selectedColor {
                    Text("Color: \(color)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let size = item.selectedSize {
                    Text("Size: \(size)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(item.displaySubtotal)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Quantity Controls
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                            updateQuantity()
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(quantity > 1 ? .blue : .gray)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 30)
                    
                    Button(action: {
                        quantity += 1
                        updateQuantity()
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
                
                Button(action: {
                    Task {
                        await viewModel.removeFromCart(itemId: item.cartItemId)
                    }
                }) {
                    Text("Remove")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func updateQuantity() {
        Task {
            await viewModel.updateCartItem(itemId: item.cartItemId, quantity: quantity)
        }
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add some products to get started")
                .foregroundColor(.gray)
            
            NavigationLink(destination: ProductListView()) {
                Text("Browse Products")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CartView()
}