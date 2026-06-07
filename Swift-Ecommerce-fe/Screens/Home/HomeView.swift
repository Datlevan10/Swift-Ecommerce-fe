//
//  HomeView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 14/01/2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var categoryVM = CategoryViewModel()
    @State private var selectedCategory: Category?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Welcome back! 👋")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search products...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Button(action: {}) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 16) {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Special Offer")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("50% Off Today")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Button(action: {}) {
                                        Text("Shop Now")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                    }
                                    .padding(.top, 4)
                                }
                                .padding()
                                Spacer()
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding()
                            }
                        }
                        .frame(height: 140)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["Flash Sale", "New Arrivals", "Best Sellers", "Free Shipping"], id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(tag == "Flash Sale" ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            tag == "Flash Sale" 
                                            ? AnyView(Color.red)
                                            : AnyView(Color(.systemGray6))
                                        )
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Shop by Category")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {}) {
                                Text("See All")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if categoryVM.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                                Spacer()
                            }
                        } else if categoryVM.activeCategories.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No categories available")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(categoryVM.activeCategories) { category in
                                        CategoryCard(category: category) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Featured Products")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {}) {
                                Text("See All")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(0..<4) { index in
                                VStack(alignment: .leading, spacing: 8) {
                                    ZStack(alignment: .topTrailing) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                            .frame(height: 180)
                                        
                                        if index == 0 {
                                            Text("NEW")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.green)
                                                .cornerRadius(6)
                                                .padding(8)
                                        }
                                        
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                    
                                    Text("Product Name")
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 4) {
                                        Text("$99.99")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("$149.99")
                                            .font(.system(size: 12))
                                            .strikethrough()
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<5) { star in
                                            Image(systemName: star < 4 ? "star.fill" : "star")
                                                .font(.system(size: 10))
                                                .foregroundColor(.yellow)
                                        }
                                        Text("(128)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .padding(.leading, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Swift Store")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "heart")
                                    .font(.system(size: 20))
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                        }
                        Button(action: {}) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart")
                                    .font(.system(size: 20))
                                Text("3")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .alert(
                "Login successful",
                isPresented: $authVM.showSuccessAlert
            ) {
                Button("Continue") {
                    authVM.showSuccessAlert = false
                }
            } message: {
                Text("Welcome back! You have logged in successfully.")
            }
            .alert(
                "Error",
                isPresented: $categoryVM.showErrorAlert
            ) {
                Button("OK") {
                    categoryVM.showErrorAlert = false
                }
            } message: {
                Text(categoryVM.errorMessage ?? "An error occurred")
            }
            .sheet(item: $selectedCategory) { category in
                NavigationView {
                    VStack {
                        Text("Category: \(category.categoryName)")
                            .font(.title)
                        Text("Slug: /category/\(category.slug)")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .navigationTitle(category.categoryName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                selectedCategory = nil
                            }
                        }
                    }
                }
            }
        }
        .task {
            await categoryVM.fetchCategories()
        }
    }
}