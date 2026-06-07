//
//  ReviewAPI.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation

class ReviewAPI {
    static let shared = ReviewAPI()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Get Product Reviews
    func getProductReviews(
        productId: String,
        page: Int = 1,
        limit: Int = 10
    ) async throws -> ReviewsResponse {
        return try await apiClient.request(
            "/products/\(productId)/reviews",
            parameters: ["page": page, "limit": limit]
        )
    }
    
    // MARK: - Get Product Review Stats
    func getProductStats(productId: String) async throws -> ReviewStats {
        return try await apiClient.request("/products/\(productId)/stats")
    }
    
    // MARK: - Submit Review
    func submitReview(review: CreateReviewRequest) async throws -> Review {
        return try await apiClient.request(
            "/reviews",
            method: .post,
            body: review
        )
    }
    
    // MARK: - Update Review
    func updateReview(id: String, updates: UpdateReviewRequest) async throws -> Review {
        return try await apiClient.request(
            "/reviews/\(id)",
            method: .put,
            body: updates
        )
    }
    
    // MARK: - Delete Review
    func deleteReview(id: String) async throws -> MessageResponse {
        return try await apiClient.request(
            "/reviews/\(id)",
            method: .delete
        )
    }
    
    // MARK: - Get My Reviews
    func getMyReviews(page: Int = 1, limit: Int = 10) async throws -> ReviewsResponse {
        return try await apiClient.request(
            "/my-reviews",
            parameters: ["page": page, "limit": limit]
        )
    }
    
    // MARK: - Upload Review Images
    func uploadReviewImages(images: [Data]) async throws -> UploadedImagesResponse {
        let files = images.enumerated().map { index, data in
            return (name: "images", fileName: "image\(index).jpg", data: data)
        }
        
        return try await apiClient.uploadMultipart(
            "/reviews/upload-images",
            files: files
        )
    }
    
    // MARK: - Admin: Approve Review
    func approveReview(id: String) async throws -> Review {
        return try await apiClient.request(
            "/admin/reviews/\(id)/approve",
            method: .post
        )
    }
    
    // MARK: - Admin: Reject Review
    func rejectReview(id: String) async throws -> Review {
        return try await apiClient.request(
            "/admin/reviews/\(id)/reject",
            method: .post
        )
    }
    
    // MARK: - Admin: Get Pending Reviews
    func getPendingReviews(page: Int = 1, limit: Int = 10) async throws -> ReviewsResponse {
        return try await apiClient.request(
            "/admin/reviews/pending",
            parameters: ["page": page, "limit": limit]
        )
    }
}

// MARK: - Review Models
struct ReviewsResponse: Codable {
    let reviews: [Review]
    let pagination: Pagination?
}

struct Review: Codable, Identifiable {
    let reviewId: String
    let customerId: String
    let productId: String
    let rating: Int
    let comment: String?
    let images: [String]?
    let isApproved: Bool
    let customer: Customer?
    let product: Product?
    let createdAt: String
    let updatedAt: String
    
    var id: String { reviewId }
    
    var displayRating: String {
        String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
}

struct ReviewStats: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [String: Int]
    
    var displayAverage: String {
        String(format: "%.1f", averageRating)
    }
    
    func getRatingCount(for rating: Int) -> Int {
        ratingDistribution[String(rating)] ?? 0
    }
    
    func getRatingPercentage(for rating: Int) -> Double {
        guard totalReviews > 0 else { return 0 }
        let count = getRatingCount(for: rating)
        return Double(count) / Double(totalReviews) * 100
    }
}

struct UploadedImagesResponse: Codable {
    let images: [String]
}

// MARK: - Request Models
struct CreateReviewRequest: Codable {
    let productId: String
    let rating: Int
    let comment: String
    let images: [String]?
}

struct UpdateReviewRequest: Codable {
    let rating: Int?
    let comment: String?
    let images: [String]?
}