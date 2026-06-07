//
//  OrderAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

class OrderAPI {
    static let shared = OrderAPI()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Create Order
    func createOrder(request: CreateOrderRequest) async throws -> Order {
        return try await apiClient.request(
            "/orders",
            method: .post,
            body: request
        )
    }
    
    // MARK: - Get My Orders
    func getMyOrders(page: Int? = nil, limit: Int? = nil) async throws -> OrdersResponse {
        var parameters: [String: Any] = [:]
        
        if let page = page {
            parameters["page"] = page
        }
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        return try await apiClient.request(
            "/orders",
            parameters: parameters.isEmpty ? nil : parameters
        )
    }
    
    // MARK: - Get Order by ID
    func getOrder(id: String) async throws -> Order {
        return try await apiClient.request("/orders/\(id)")
    }
    
    // MARK: - Cancel Order
    func cancelOrder(id: String) async throws -> Order {
        return try await apiClient.request(
            "/orders/\(id)/cancel",
            method: .post
        )
    }
    
    // MARK: - Track Order by Code
    func trackOrder(code: String) async throws -> Order {
        return try await apiClient.request("/orders/track/\(code)")
    }
    
    // MARK: - Admin: Get All Orders
    func getAllOrders(
        status: OrderStatus? = nil,
        paymentStatus: PaymentStatus? = nil,
        page: Int? = nil,
        limit: Int? = nil
    ) async throws -> OrdersResponse {
        var parameters: [String: Any] = [:]
        
        if let status = status {
            parameters["status"] = status.rawValue
        }
        
        if let paymentStatus = paymentStatus {
            parameters["paymentStatus"] = paymentStatus.rawValue
        }
        
        if let page = page {
            parameters["page"] = page
        }
        
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        return try await apiClient.request(
            "/orders/admin/all",
            parameters: parameters.isEmpty ? nil : parameters
        )
    }
    
    // MARK: - Admin: Update Order Status
    func updateOrderStatus(id: String, status: OrderStatus) async throws -> Order {
        return try await apiClient.request(
            "/orders/admin/\(id)/status",
            method: .put,
            body: UpdateOrderStatusRequest(status: status)
        )
    }
    
    // MARK: - Admin: Update Payment Status
    func updatePaymentStatus(id: String, status: PaymentStatus) async throws -> Order {
        return try await apiClient.request(
            "/orders/admin/\(id)/payment-status",
            method: .put,
            body: UpdatePaymentStatusRequest(status: status)
        )
    }
}

// MARK: - Order Models
struct OrdersResponse: Codable {
    let orders: [Order]
    let pagination: Pagination?
}

struct Order: Codable, Identifiable {
    let orderId: String
    let customerId: String
    let orderCode: String
    let orderStatus: OrderStatus
    let paymentMethod: PaymentMethod
    let paymentStatus: PaymentStatus
    let totalAmount: Double
    let shippingAddress: ShippingAddress
    let note: String?
    let orderDetails: [OrderDetail]
    let customer: Customer?
    let createdAt: String
    let updatedAt: String
    
    var id: String { orderId }
    
    var displayTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "$0.00"
    }
    
    var statusColor: String {
        switch orderStatus {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .shipped: return "purple"
        case .completed: return "green"
        case .cancelled: return "red"
        }
    }
}

struct OrderDetail: Codable, Identifiable {
    let orderDetailId: String
    let orderId: String
    let productId: String
    let quantity: Int
    let price: Double
    let selectedColor: String?
    let selectedSize: String?
    let product: Product?
    
    var id: String { orderDetailId }
    
    var subtotal: Double {
        Double(quantity) * price
    }
}

struct ShippingAddress: Codable {
    let fullName: String
    let phone: String
    let address: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(postalCode), \(country)"
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case shipped = "shipped"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .shipped: return "Shipped"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

enum PaymentMethod: String, Codable, CaseIterable {
    case card = "card"
    case cash = "cash"
    case paypal = "paypal"
    case bankTransfer = "bank_transfer"
    
    var displayName: String {
        switch self {
        case .card: return "Credit/Debit Card"
        case .cash: return "Cash on Delivery"
        case .paypal: return "PayPal"
        case .bankTransfer: return "Bank Transfer"
        }
    }
}

enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case paid = "paid"
    case failed = "failed"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .paid: return "Paid"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        }
    }
}

// MARK: - Request Models
struct CreateOrderRequest: Codable {
    let paymentMethod: PaymentMethod
    let shippingAddress: ShippingAddress
    let note: String?
}

struct UpdateOrderStatusRequest: Codable {
    let status: OrderStatus
}

struct UpdatePaymentStatusRequest: Codable {
    let status: PaymentStatus
}