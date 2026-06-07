//
//  ReviewViewModel.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

@MainActor
final class ReviewViewModel: ObservableObject {
    
    @Published var reviews: [Review] = []
    @Published var myReviews: [Review] = []
    @Published var reviewStats: ReviewStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    private let reviewAPI = ReviewAPI.shared
    
    // MARK: - Load Product Reviews
    func loadProductReviews(productId: String, page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await reviewAPI.getProductReviews(productId: productId, page: page)
            reviews = response.reviews
            
            // Also load stats
            reviewStats = try await reviewAPI.getProductStats(productId: productId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Submit Review
    func submitReview(
        productId: String,
        rating: Int,
        comment: String,
        images: [Data] = []
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            var imageURLs: [String] = []
            
            // Upload images if any
            if !images.isEmpty {
                let uploadResponse = try await reviewAPI.uploadReviewImages(images: images)
                imageURLs = uploadResponse.images
            }
            
            // Submit review
            let request = CreateReviewRequest(
                productId: productId,
                rating: rating,
                comment: comment,
                images: imageURLs.isEmpty ? nil : imageURLs
            )
            
            let _ = try await reviewAPI.submitReview(review: request)
            
            showSuccessAlert = true
            
            // Reload reviews
            await loadProductReviews(productId: productId)
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Review
    func updateReview(
        reviewId: String,
        rating: Int? = nil,
        comment: String? = nil,
        images: [String]? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = UpdateReviewRequest(
                rating: rating,
                comment: comment,
                images: images
            )
            
            let _ = try await reviewAPI.updateReview(id: reviewId, updates: request)
            
            showSuccessAlert = true
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Review
    func deleteReview(reviewId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await reviewAPI.deleteReview(id: reviewId)
            
            // Remove from local list
            reviews.removeAll { $0.reviewId == reviewId }
            myReviews.removeAll { $0.reviewId == reviewId }
            
            showSuccessAlert = true
            
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    // MARK: - Load My Reviews
    func loadMyReviews(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await reviewAPI.getMyReviews(page: page)
            myReviews = response.reviews
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}