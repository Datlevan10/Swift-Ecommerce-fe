//
//  ProfileView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var vm = ProfileViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var showingImagePicker = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            
                            Button {
                                showingImagePicker = true
                            } label: {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .offset(x: -5, y: -5)
                        }
                        
                        // User Info
                        if let profile = vm.profile {
                            VStack(spacing: 6) {
                                Text(profile.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(profile.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let phone = profile.phone {
                                    Text(phone)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else if vm.isLoading {
                            ProgressView()
                                .padding()
                        }
                        
                        // Stats Cards
                        HStack(spacing: 16) {
                            StatsCard(
                                icon: "bag.fill",
                                value: "24",
                                label: "Orders",
                                color: .blue
                            )
                            
                            StatsCard(
                                icon: "cart.fill",
                                value: "3",
                                label: "In Cart",
                                color: .orange
                            )
                            
                            StatsCard(
                                icon: "dollarsign.circle.fill",
                                value: "$2,450",
                                label: "Total Spent",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 24)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // MARK: - Menu Items
                    VStack(spacing: 0) {
                        
                        // Orders Section
                        SectionHeader(title: "Orders & Shopping")
                        
                        MenuRow(
                            icon: "bag.fill",
                            title: "My Orders",
                            subtitle: "Track and manage your orders",
                            color: .blue
                        ) {
                            print("Navigate to Orders")
                        }
                        
                        MenuRow(
                            icon: "cart.fill",
                            title: "Shopping Cart",
                            subtitle: "3 items pending",
                            color: .orange,
                            badge: "3"
                        ) {
                            print("Navigate to Cart")
                        }
                        
                        MenuRow(
                            icon: "heart.fill",
                            title: "Wishlist",
                            subtitle: "Your favorite items",
                            color: .pink
                        ) {
                            print("Navigate to Wishlist")
                        }
                        
                        // Payment Section
                        SectionHeader(title: "Payment & Billing")
                        
                        MenuRow(
                            icon: "creditcard.fill",
                            title: "Payment Methods",
                            subtitle: "Manage your payment options",
                            color: .indigo
                        ) {
                            print("Navigate to Payment Methods")
                        }
                        
                        MenuRow(
                            icon: "doc.text.fill",
                            title: "Billing History",
                            subtitle: "View past transactions",
                            color: .purple
                        ) {
                            print("Navigate to Billing History")
                        }
                        
                        // Settings Section
                        SectionHeader(title: "Settings & Support")
                        
                        MenuRow(
                            icon: "location.fill",
                            title: "Shipping Addresses",
                            subtitle: "Manage delivery locations",
                            color: .teal
                        ) {
                            print("Navigate to Addresses")
                        }
                        
                        MenuRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            subtitle: "Customize your alerts",
                            color: .yellow
                        ) {
                            print("Navigate to Notifications")
                        }
                        
                        MenuRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            subtitle: "Get assistance",
                            color: .gray
                        ) {
                            print("Navigate to Support")
                        }
                        
                        MenuRow(
                            icon: "shield.fill",
                            title: "Privacy & Security",
                            subtitle: "Manage your account security",
                            color: .green
                        ) {
                            print("Navigate to Privacy")
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Logout Button
                    Button {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.square.fill")
                                .font(.system(size: 20))
                            Text("Log Out")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red,
                                    Color.red.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await vm.loadProfile()
        }
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: $selectedPhoto,
            matching: .images
        )
        .onChange(of: selectedPhoto) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                }
            }
        }
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                vm.logout()
            }
        } message: {
            Text("Are you sure you want to log out of your account?")
        }
    }
}

// MARK: - Stats Card Component
struct StatsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Section Header Component
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
}

// MARK: - Menu Row Component
struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}