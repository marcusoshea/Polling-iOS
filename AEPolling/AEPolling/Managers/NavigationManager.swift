//
//  NavigationManager.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import Foundation
import SwiftUI

@MainActor
class NavigationManager: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var showingSideMenu = false
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case reports = "Report"
        case polling = "Polling"
        case candidates = "Candidates"
        case profile = "Profile"
        case feedback = "Feedback"
        
        var icon: String {
            switch self {
            case .home: return "house"
            case .profile: return "person"
            case .polling: return "list.clipboard"
            case .candidates: return "person.2"
            case .reports: return "chart.bar"
            case .feedback: return "message"
            }
        }
    }
    
    func navigate(to tab: Tab) {
        selectedTab = tab
        showingSideMenu = false
    }
    
    func toggleSideMenu() {
        showingSideMenu.toggle()
    }
} 
