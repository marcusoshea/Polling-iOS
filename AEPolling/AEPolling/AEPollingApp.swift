//
//  AEPollingApp.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

@main
struct AEPollingApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var navigationManager = NavigationManager()
    
    init() {
        // Configure global navigation appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appSecondary)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.appSecondary)
        // Set tab bar item colors: selected = white, non-selected = appPrimary
        let whiteColor = UIColor.white
        let primaryColor = UIColor(Color.appPrimary)
        // Non-selected
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = primaryColor
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: primaryColor]
        tabBarAppearance.inlineLayoutAppearance.normal.iconColor = primaryColor
        tabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: primaryColor]
        tabBarAppearance.compactInlineLayoutAppearance.normal.iconColor = primaryColor
        tabBarAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: primaryColor]
        // Selected
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = whiteColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: whiteColor]
        tabBarAppearance.inlineLayoutAppearance.selected.iconColor = whiteColor
        tabBarAppearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: whiteColor]
        tabBarAppearance.compactInlineLayoutAppearance.selected.iconColor = whiteColor
        tabBarAppearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: whiteColor]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(navigationManager)
        }
    }
}
