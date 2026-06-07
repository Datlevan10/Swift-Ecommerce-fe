//
//  ProductViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

@MainActor
final class ProductViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var featuredProducts: [Product] = []
    @Published var topRatedProducts: [Product] = []
    @Published var selectedProduct: Product?
    @Published var searchResults: [Product] = []
    
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    @Published var currentPage = 1
    @Published var hasMorePages = true
    
    private let productAPI = ProductAPI.shared
    
    // MARK: - Load Products
    func loadProducts(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMorePages = true
            products = []
        }
        
        guard !isLoading && hasMorePages else { return }
        
        if currentPage == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        do {
            let response = try await productAPI.getProducts(
                page: currentPage,
                limit: 20
            )
            
            if refresh {
                products = response.products
            } else {
                products.append(contentsOf: response.products)
            }
            
            if let pagination = response.pagination {
                hasMorePages = currentPage < pagination.totalPages
                currentPage += 1
            } else {
                hasMorePages = false
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        isLoadingMore = false
    }
    
    // MARK: - Load Product Details
    func loadProductDetails(id: String) async {
        isLoading = true
        
        do {
            selectedProduct = try await productAPI.getProduct(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Load Products by Category
    func loadProductsByCategory(categoryId: String) async {
        isLoading = true
        products = []
        
        do {
            products = try await productAPI.getProductsByCategory(categoryId: categoryId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Search Products
    func searchProducts(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        do {
            searchResults = try await productAPI.searchProducts(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Load Featured Products
    func loadFeaturedProducts() async {
        do {
            featuredProducts = try await productAPI.getFeaturedProducts()
        } catch {
            print("Failed to load featured products: \(error)")
        }
    }
    
    // MARK: - Load Top Rated Products
    func loadTopRatedProducts() async {
        do {
            topRatedProducts = try await productAPI.getTopRatedProducts()
        } catch {
            print("Failed to load top rated products: \(error)")
        }
    }
}