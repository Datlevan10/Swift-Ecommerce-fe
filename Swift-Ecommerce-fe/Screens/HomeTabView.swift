//
//  HomeTabView.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import SwiftUI

struct HomeTabView: View {
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {

            HomeView(authVM: authVM)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ExploreView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }

            NotificationView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .navigationBarBackButtonHidden(true)
    }
}

