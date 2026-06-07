//
//  CartViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

@MainActor
final class CartViewModel: ObservableObject {
    
    @Published var cart: Cart?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    private let cartAPI = CartAPI.shared
    
    var cartItemCount: Int {
        cart?.itemCount ?? 0
    }
    
    var cartTotal: String {
        cart?.displayTotal ?? "$0.00"
    }
    
    var hasItems: Bool {
        (cart?.items.count ?? 0) > 0
    }
    
    // MARK: - Load Cart
    func loadCart() async {
        isLoading = true
        errorMessage = nil
        
        do {
            cart = try await cartAPI.getCart()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Add to Cart
    func addToCart(
        productId: String,
        quantity: Int,
        selectedColor: String? = nil,
        selectedSize: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = AddToCartRequest(
                productId: productId,
                quantity: quantity,
                selectedColor: selectedColor,
                selectedSize: selectedSize
            )
            
            let _ = try await cartAPI.addToCart(request: request)
            
            // Reload cart to get updated totals
            await loadCart()
            
            showSuccessAlert = true
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Cart Item
    func updateCartItem(itemId: String, quantity: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await cartAPI.updateCartItem(id: itemId, quantity: quantity)
            
            // Update local cart
            if let index = cart?.items.firstIndex(where: { $0.cartItemId == itemId }) {
                var updatedCart = cart
                updatedCart?.items[index] = updatedCart!.items[index]
                
                // Recalculate totals
                await loadCart()
            }
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Remove from Cart
    func removeFromCart(itemId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await cartAPI.removeCartItem(id: itemId)
            
            // Remove from local cart
            cart?.items.removeAll { $0.cartItemId == itemId }
            
            // Reload cart to get updated totals
            await loadCart()
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Clear Cart
    func clearCart() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await cartAPI.clearCart()
            
            // Clear local cart
            cart?.items = []
            
            // Reload cart
            await loadCart()
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
}