//
//  CategoryViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 21/01/2026.
//

import SwiftUI

@MainActor
final class CategoryViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    
    var activeCategories: [Category] {
        categories
            .filter { $0.isActive }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        showErrorAlert = false
        
        do {
            let response = try await CategoryAPI.fetchCategories()
            
            if response.success {
                categories = response.data
            } else {
                errorMessage = "Failed to fetch categories"
                showErrorAlert = true
            }
        } catch {
            errorMessage = "Something went wrong. Please try again."
            showErrorAlert = true
        }
        
        isLoading = false
    }
}
