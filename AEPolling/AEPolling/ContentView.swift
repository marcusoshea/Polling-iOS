//
//  ContentView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
    }
}

struct LogoutScreen: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 60))
                .foregroundColor(.appError)
            Text("Are you sure you want to sign out?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
            Button(action: { showingLogoutAlert = true }) {
                Text("Sign Out")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appError)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            Spacer()
        }
        .background(Color.appBackground)
        .navigationTitle("Logout")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MainTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $navigationManager.selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: NavigationManager.Tab.home.icon)
                            Text(NavigationManager.Tab.home.rawValue)
                        }
                        .tag(NavigationManager.Tab.home)
                    
                    PollingView()
                        .tabItem {
                            Image(systemName: NavigationManager.Tab.polling.icon)
                            Text(NavigationManager.Tab.polling.rawValue)
                        }
                        .tag(NavigationManager.Tab.polling)
                    
                    CandidatesView()
                        .tabItem {
                            Image(systemName: NavigationManager.Tab.candidates.icon)
                            Text(NavigationManager.Tab.candidates.rawValue)
                        }
                        .tag(NavigationManager.Tab.candidates)
                    
                    GeometryReader { geometry in
                        ReportView(cardWidth: geometry.size.width * 0.96)
                    }
                        .tabItem {
                            Image(systemName: NavigationManager.Tab.reports.icon)
                            Text(NavigationManager.Tab.reports.rawValue)
                        }
                        .tag(NavigationManager.Tab.reports)
                    ProfileView()
                        .tabItem {
                            Image(systemName: NavigationManager.Tab.profile.icon)
                            Text(NavigationManager.Tab.profile.rawValue)
                        }
                        .tag(NavigationManager.Tab.profile)
                    FeedbackView()
                        .tabItem {
                            Image(systemName: NavigationManager.Tab.feedback.icon)
                            Text(NavigationManager.Tab.feedback.rawValue)
                        }
                        .tag(NavigationManager.Tab.feedback)
                    LogoutScreen()
                        .tabItem {
                            Image(systemName: "ellipsis")
                            Text("Logout")
                        }
                        .tag("more")
                }
                .accentColor(.appPrimary)
                
                // Side Menu
                if navigationManager.showingSideMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                navigationManager.showingSideMenu = false
                            }
                        }
                    
                    HStack {
                        SideMenuView()
                            .frame(width: 280)
                            .background(Color.appCardBackground)
                            .transition(.move(edge: .leading))
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SideMenuView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("AEPolling")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .padding(.top, 50)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        ForEach(NavigationManager.Tab.allCases, id: \.self) { tab in
                            SideMenuButton(
                                title: tab.rawValue,
                                icon: tab.icon,
                                isSelected: navigationManager.selectedTab == tab
                            ) {
                                navigationManager.navigate(to: tab)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // Removed duplicate Sign Out button here
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 0.7)
            .background(Color.appCardBackground)
            .shadow(radius: 10)
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            withAnimation(.easeInOut) {
                navigationManager.showingSideMenu = false
            }
        }
    }
}

struct SideMenuButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(title)
                Spacer()
            }
            .foregroundColor(isSelected ? .appGold : .appText)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.appGold.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(NavigationManager())
}
