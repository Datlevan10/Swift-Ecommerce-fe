//
//  CategoryCard.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 03/03/2026.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var imageLoaded = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    if let url = URL(string: category.imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(0.8)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .onAppear {
                                        withAnimation(.easeIn(duration: 0.3)) {
                                            imageLoaded = true
                                        }
                                    }
                            case .failure(_):
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray.opacity(0.5))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 120, height: 100)
                        .clipped()
                        .opacity(imageLoaded ? 1 : 0)
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                .frame(width: 120, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                
                VStack(spacing: 4) {
                    Text(category.categoryName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if category.parentId == nil {
                        Text("Main Category")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
            .frame(width: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: isPressed ? 2 : 8,
                        x: 0,
                        y: isPressed ? 1 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.15), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            ForEach(0..<5) { index in
                CategoryCard(
                    category: Category(
                        categoryId: "id\(index)",
                        categoryName: "Category \(index + 1)",
                        description: "Description for category \(index + 1)",
                        parentId: index % 2 == 0 ? nil : "parent",
                        slug: "category-\(index + 1)",
                        imageUrl: "https://via.placeholder.com/150",
                        isActive: true,
                        sortOrder: index
                    ),
                    action: {
                        print("Tapped category \(index + 1)")
                    }
                )
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}