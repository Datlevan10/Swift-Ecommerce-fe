//
//  WriteReviewView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI
import PhotosUI

struct WriteReviewView: View {
    let productId: String
    
    @StateObject private var viewModel = ReviewViewModel()
    @State private var rating = 5
    @State private var comment = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [Data] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Rating") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: {
                                rating = star
                            }) {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Your Review") {
                    TextEditor(text: $comment)
                        .frame(minHeight: 100)
                }
                
                Section("Photos (Optional)") {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("Add Photos")
                        }
                        .foregroundColor(.blue)
                    }
                    .onChange(of: selectedPhotos) { items in
                        Task {
                            selectedImages.removeAll()
                            for item in items {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    selectedImages.append(data)
                                }
                            }
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, imageData in
                                    if let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)
                                            .overlay(
                                                Button(action: {
                                                    selectedImages.remove(at: index)
                                                    selectedPhotos.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                .offset(x: 30, y: -30)
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        Task {
                            await submitReview()
                        }
                    }
                    .disabled(comment.isEmpty || viewModel.isLoading)
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView("Submitting review...")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                }
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your review has been submitted and will appear after approval.")
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Failed to submit review")
        }
    }
    
    private func submitReview() async {
        await viewModel.submitReview(
            productId: productId,
            rating: rating,
            comment: comment,
            images: selectedImages
        )
    }
}

#Preview {
    WriteReviewView(productId: "sample-id")
}