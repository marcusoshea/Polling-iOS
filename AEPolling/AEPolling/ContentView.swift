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
                    
                    ReportView()
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
                        
                        SideMenuButton(
                            title: "Sign Out",
                            icon: "rectangle.portrait.and.arrow.right",
                            isSelected: false
                        ) {
                            authManager.signOut()
                        }
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
