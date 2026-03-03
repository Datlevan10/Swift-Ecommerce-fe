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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Categories")
                        .font(.title2)
                        .fontWeight(.semibold)
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
                        Text("No categories available")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
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
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
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

