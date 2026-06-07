//
//  OrderViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

@MainActor
final class OrderViewModel: ObservableObject {
    
    @Published var orders: [Order] = []
    @Published var currentOrder: Order?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    private let orderAPI = OrderAPI.shared
    
    // MARK: - Create Order
    func createOrder(
        paymentMethod: PaymentMethod,
        shippingAddress: ShippingAddress,
        note: String? = nil
    ) async -> Order? {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = CreateOrderRequest(
                paymentMethod: paymentMethod,
                shippingAddress: shippingAddress,
                note: note
            )
            
            let order = try await orderAPI.createOrder(request: request)
            currentOrder = order
            showSuccessAlert = true
            
            return order
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            return nil
        }
    }
    
    // MARK: - Load My Orders
    func loadMyOrders(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await orderAPI.getMyOrders(page: page)
            orders = response.orders
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Load Order Details
    func loadOrderDetails(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentOrder = try await orderAPI.getOrder(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Cancel Order
    func cancelOrder(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let order = try await orderAPI.cancelOrder(id: id)
            currentOrder = order
            
            // Update in list if present
            if let index = orders.firstIndex(where: { $0.orderId == id }) {
                orders[index] = order
            }
            
            showSuccessAlert = true
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Track Order
    func trackOrder(code: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentOrder = try await orderAPI.trackOrder(code: code)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
}