//
//  OrderDetailView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @StateObject private var viewModel = OrderViewModel()
    @State private var showingCancelConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Order Status Card
                    OrderStatusCard(order: order)
                    
                    // Order Info
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Order Information")
                        
                        InfoRow(label: "Order Code", value: order.orderCode)
                        InfoRow(label: "Order Date", value: formatDate(order.createdAt))
                        InfoRow(label: "Payment Method", value: order.paymentMethod.displayName)
                        InfoRow(label: "Payment Status", value: order.paymentStatus.displayName)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Shipping Address
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Shipping Address")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(order.shippingAddress.fullName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(order.shippingAddress.phone)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(order.shippingAddress.fullAddress)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Order Items
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Order Items")
                        
                        ForEach(order.orderDetails) { item in
                            OrderItemRow(item: item)
                            if item.id != order.orderDetails.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Order Note
                    if let note = order.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Order Note")
                            
                            Text(note)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Order Summary
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Order Summary")
                        
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text(order.displayTotal)
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Text("Shipping")
                            Spacer()
                            Text("Free")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(order.displayTotal)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Cancel Order Button
                    if order.orderStatus == .pending || order.orderStatus == .confirmed {
                        Button(action: {
                            showingCancelConfirmation = true
                        }) {
                            Text("Cancel Order")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Cancel Order", isPresented: $showingCancelConfirmation) {
            Button("Cancel Order", role: .destructive) {
                Task {
                    await viewModel.cancelOrder(id: order.orderId)
                }
            }
            Button("Keep Order", role: .cancel) { }
        } message: {
            Text("Are you sure you want to cancel this order?")
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your order has been cancelled successfully.")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

struct OrderStatusCard: View {
    let order: Order
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Icon
            Image(systemName: statusIcon)
                .font(.system(size: 50))
                .foregroundColor(statusColor)
            
            // Status Text
            Text(order.orderStatus.displayName)
                .font(.title2)
                .fontWeight(.bold)
            
            // Status Description
            Text(statusDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Progress Indicator
            OrderProgressView(status: order.orderStatus)
                .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    var statusIcon: String {
        switch order.orderStatus {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .shipped: return "shippingbox"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var statusColor: Color {
        switch order.orderStatus {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipped: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    var statusDescription: String {
        switch order.orderStatus {
        case .pending: return "Your order is being processed"
        case .confirmed: return "Your order has been confirmed"
        case .shipped: return "Your order is on the way"
        case .completed: return "Your order has been delivered"
        case .cancelled: return "This order has been cancelled"
        }
    }
}

struct OrderProgressView: View {
    let status: OrderStatus
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(OrderStatus.allCases.filter { $0 != .cancelled }, id: \.self) { orderStatus in
                VStack(spacing: 4) {
                    Circle()
                        .fill(isCompleted(orderStatus) ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    Text(orderStatus.displayName)
                        .font(.caption2)
                        .foregroundColor(isCompleted(orderStatus) ? .primary : .gray)
                }
                
                if orderStatus != OrderStatus.completed {
                    Rectangle()
                        .fill(isCompleted(orderStatus) ? Color.green : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func isCompleted(_ orderStatus: OrderStatus) -> Bool {
        let statusOrder = [OrderStatus.pending, .confirmed, .shipped, .completed]
        guard let currentIndex = statusOrder.firstIndex(of: status),
              let checkIndex = statusOrder.firstIndex(of: orderStatus) else {
            return false
        }
        return checkIndex <= currentIndex
    }
}

struct OrderItemRow: View {
    let item: OrderDetail
    
    var body: some View {
        HStack(spacing: 12) {
            if let product = item.product, let imageURL = product.primaryImageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 60, height: 60)
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
                
                HStack {
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("×")
                        .foregroundColor(.gray)
                    
                    Text("$\(String(format: \"%.2f\", item.price))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text("$\(String(format: \"%.2f\", item.subtotal))")
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    OrderDetailView(order: Order(
        orderId: "123",
        customerId: "456",
        orderCode: "ORD-2024-001",
        orderStatus: .confirmed,
        paymentMethod: .card,
        paymentStatus: .paid,
        totalAmount: 299.99,
        shippingAddress: ShippingAddress(
            fullName: "John Doe",
            phone: "+1234567890",
            address: "123 Main St",
            city: "New York",
            state: "NY",
            postalCode: "10001",
            country: "USA"
        ),
        note: "Please leave at door",
        orderDetails: [],
        customer: nil,
        createdAt: "2024-01-01T10:00:00Z",
        updatedAt: "2024-01-01T10:00:00Z"
    ))
}