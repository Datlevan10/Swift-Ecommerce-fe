//
//  ReviewListView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct ReviewListView: View {
    let productId: String
    @StateObject private var viewModel = ReviewViewModel()
    @State private var filterRating: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Review Stats Header
                if let stats = viewModel.reviewStats {
                    ReviewStatsHeader(stats: stats, filterRating: $filterRating)
                        .padding()
                        .background(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Reviews List
                if viewModel.isLoading {
                    ProgressView("Loading reviews...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.reviews.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No reviews yet")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Be the first to review this product")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredReviews) { review in
                                ReviewCard(review: review)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss sheet
                    }
                }
            }
        }
        .task {
            await viewModel.loadProductReviews(productId: productId)
        }
    }
    
    var filteredReviews: [Review] {
        if let filterRating = filterRating {
            return viewModel.reviews.filter { $0.rating == filterRating }
        }
        return viewModel.reviews
    }
}

struct ReviewStatsHeader: View {
    let stats: ReviewStats
    @Binding var filterRating: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            // Average Rating
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(stats.displayAverage)
                        .font(.system(size: 48, weight: .bold))
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(stats.averageRating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text("\(stats.totalReviews) reviews")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .frame(height: 80)
                
                // Rating Distribution
                VStack(alignment: .leading, spacing: 8) {
                    ForEach((1...5).reversed(), id: \.self) { rating in
                        HStack(spacing: 8) {
                            Button(action: {
                                filterRating = filterRating == rating ? nil : rating
                            }) {
                                HStack(spacing: 4) {
                                    Text("\(rating)")
                                        .font(.caption)
                                        .frame(width: 15)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    
                                    // Progress bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 4)
                                            
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(filterRating == rating ? Color.blue : Color.yellow)
                                                .frame(
                                                    width: geometry.size.width * (stats.getRatingPercentage(for: rating) / 100),
                                                    height: 4
                                                )
                                        }
                                    }
                                    .frame(width: 100, height: 4)
                                    
                                    Text("\(stats.getRatingCount(for: rating))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            if filterRating != nil {
                HStack {
                    Text("Showing \(filterRating!) star reviews")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("Clear filter") {
                        filterRating = nil
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Customer Name
                Text(review.customer?.fullName ?? "Anonymous")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Date
                Text(formatDate(review.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Rating
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < review.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                
                if !review.isApproved {
                    Text("Pending approval")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            // Comment
            if let comment = review.comment {
                Text(comment)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Images
            if let images = review.images, !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(images, id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                            }
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                        }
                    }
                }
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
        return displayFormatter.string(from: date)
    }
}