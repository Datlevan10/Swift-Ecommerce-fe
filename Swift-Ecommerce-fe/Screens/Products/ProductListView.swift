//
//  ProductListView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var searchText = ""
    @State private var showingFilters = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(searchText.isEmpty ? viewModel.products : viewModel.searchResults) { product in
                                NavigationLink(destination: ProductDetailView(productId: product.productId)) {
                                    ProductCard(product: product)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .padding()
                        
                        if viewModel.hasMorePages && !viewModel.isLoadingMore && searchText.isEmpty {
                            Button("Load More") {
                                Task {
                                    await viewModel.loadProducts()
                                }
                            }
                            .padding()
                        }
                    }
                    .refreshable {
                        await viewModel.loadProducts(refresh: true)
                    }
                }
            }
            .navigationTitle("Products")
            .searchable(text: $searchText, prompt: "Search products...")
            .onChange(of: searchText) { newValue in
                Task {
                    await viewModel.searchProducts(query: newValue)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = product.primaryImageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                        )
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if let category = product.category {
                    Text(category.categoryName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if let oldPrice = product.oldPrice, oldPrice > product.newPrice {
                        Text("$\(String(format: \"%.2f\", oldPrice))")
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                }
                
                if let averageRating = product.averageRating, let totalReviews = product.totalReviews {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(averageRating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        Text("(\(totalReviews))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                if !product.isInStock {
                    Text("Out of Stock")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProductListView()
}