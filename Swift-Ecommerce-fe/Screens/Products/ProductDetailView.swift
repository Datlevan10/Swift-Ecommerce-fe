//
//  ProductDetailView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct ProductDetailView: View {
    let productId: String
    
    @StateObject private var productViewModel = ProductViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var reviewViewModel = ReviewViewModel()
    
    @State private var selectedColor: String?
    @State private var selectedSize: String?
    @State private var quantity = 1
    @State private var selectedImageIndex = 0
    @State private var showingReviews = false
    @State private var showingWriteReview = false
    
    var body: some View {
        ScrollView {
            if productViewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxHeight: .infinity)
                    .padding(.top, 100)
            } else if let product = productViewModel.selectedProduct {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Gallery
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(product.image.enumerated()), id: \.offset) { index, imageURL in
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(ProgressView())
                            }
                            .tag(index)
                        }
                    }
                    .frame(height: 400)
                    .tabViewStyle(PageTabViewStyle())
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Product Info
                        Text(product.productName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let category = product.category {
                            Text(category.categoryName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Price
                        HStack(spacing: 12) {
                            Text(product.displayPrice)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            if let oldPrice = product.oldPrice, oldPrice > product.newPrice {
                                Text("$\(String(format: \"%.2f\", oldPrice))")
                                    .font(.title3)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                            }
                            
                            if let discount = product.discountPercentage {
                                Text("\(discount)% OFF")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(4)
                            }
                        }
                        
                        // Rating
                        if let averageRating = product.averageRating, let totalReviews = product.totalReviews {
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(averageRating) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.1f", averageRating))
                                    .fontWeight(.medium)
                                Text("(\(totalReviews) reviews)")
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button("See all reviews") {
                                    showingReviews = true
                                }
                                .font(.caption)
                            }
                        }
                        
                        Divider()
                        
                        // Color Selection
                        if !product.color.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Color")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(product.color, id: \.self) { color in
                                            Button(action: {
                                                selectedColor = color
                                            }) {
                                                Text(color)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(selectedColor == color ? Color.blue : Color.gray.opacity(0.1))
                                                    )
                                                    .foregroundColor(selectedColor == color ? .white : .primary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Size Selection
                        if !product.size.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Size")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(product.size, id: \.self) { size in
                                            Button(action: {
                                                selectedSize = size
                                            }) {
                                                Text(size)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(selectedSize == size ? Color.blue : Color.gray.opacity(0.1))
                                                    )
                                                    .foregroundColor(selectedSize == size ? .white : .primary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Quantity
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity > 1 ? .blue : .gray)
                                }
                                .disabled(quantity <= 1)
                                
                                Text("\(quantity)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(width: 40)
                                
                                Button(action: {
                                    if quantity < product.quantityInStock {
                                        quantity += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity < product.quantityInStock ? .blue : .gray)
                                }
                                .disabled(quantity >= product.quantityInStock)
                            }
                        }
                        
                        Text("\(product.quantityInStock) items in stock")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Add to Cart Button
                        Button(action: {
                            Task {
                                await addToCart()
                            }
                        }) {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text(product.isInStock ? "Add to Cart" : "Out of Stock")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(product.isInStock ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!product.isInStock || cartViewModel.isLoading)
                        
                        // Write Review Button
                        Button(action: {
                            showingWriteReview = true
                        }) {
                            Text("Write a Review")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await productViewModel.loadProductDetails(id: productId)
            await reviewViewModel.loadProductReviews(productId: productId)
        }
        .sheet(isPresented: $showingReviews) {
            ReviewListView(productId: productId)
        }
        .sheet(isPresented: $showingWriteReview) {
            WriteReviewView(productId: productId)
        }
        .alert("Success", isPresented: $cartViewModel.showSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Product added to cart!")
        }
        .alert("Error", isPresented: $cartViewModel.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(cartViewModel.errorMessage ?? "Failed to add to cart")
        }
    }
    
    private func addToCart() async {
        guard let product = productViewModel.selectedProduct else { return }
        
        let needsColor = !product.color.isEmpty
        let needsSize = !product.size.isEmpty
        
        if needsColor && selectedColor == nil {
            cartViewModel.errorMessage = "Please select a color"
            cartViewModel.showErrorAlert = true
            return
        }
        
        if needsSize && selectedSize == nil {
            cartViewModel.errorMessage = "Please select a size"
            cartViewModel.showErrorAlert = true
            return
        }
        
        await cartViewModel.addToCart(
            productId: product.productId,
            quantity: quantity,
            selectedColor: selectedColor,
            selectedSize: selectedSize
        )
    }
}

#Preview {
    NavigationView {
        ProductDetailView(productId: "sample-id")
    }
}