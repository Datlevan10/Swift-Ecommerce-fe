//
//  OrderHistoryView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderViewModel()
    @State private var selectedOrder: Order?
    @State private var showingOrderDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView("Loading orders...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.orders.isEmpty {
                    EmptyOrdersView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.orders) { order in
                                OrderCard(order: order)
                                    .onTapGesture {
                                        selectedOrder = order
                                        showingOrderDetail = true
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadMyOrders()
                    }
                }
            }
            .navigationTitle("My Orders")
            .sheet(isPresented: $showingOrderDetail) {
                if let order = selectedOrder {
                    OrderDetailView(order: order)
                }
            }
        }
        .task {
            await viewModel.loadMyOrders()
        }
    }
}

struct OrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Order Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.orderCode)")
                        .font(.headline)
                    
                    Text(formatDate(order.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                OrderStatusBadge(status: order.orderStatus)
            }
            
            Divider()
            
            // Order Items Preview
            if !order.orderDetails.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(order.orderDetails.prefix(2)) { item in
                        HStack {
                            if let product = item.product, let imageURL = product.primaryImageURL {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(4)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.product?.productName ?? "Product")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    if order.orderDetails.count > 2 {
                        Text("+\(order.orderDetails.count - 2) more items")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Divider()
            
            // Order Footer
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(order.displayTotal)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                PaymentStatusBadge(status: order.paymentStatus)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

struct OrderStatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(4)
    }
    
    var backgroundColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .shipped: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

struct PaymentStatusBadge: View {
    let status: PaymentStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(foregroundColor)
    }
    
    var iconName: String {
        switch status {
        case .pending: return "clock"
        case .paid: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .refunded: return "arrow.uturn.backward.circle.fill"
        }
    }
    
    var foregroundColor: Color {
        switch status {
        case .pending: return .orange
        case .paid: return .green
        case .failed: return .red
        case .refunded: return .blue
        }
    }
}

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No orders yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start shopping to see your orders here")
                .foregroundColor(.gray)
            
            NavigationLink(destination: ProductListView()) {
                Text("Browse Products")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OrderHistoryView()
}