//
//  HomeView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Welcome message card
                VStack {
                    Text(viewModel.welcomeMessage)
                        .font(.body)
                        .italic()
                        .foregroundColor(.appText)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Version info
                Text("Version \(viewModel.appVersion)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Polling \(viewModel.pollingOrderName)")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadData(authManager: authManager)
        }
    }
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var pollingOrderName: String = ""
    @Published var welcomeMessage: String = ""
    @Published var appVersion: String = ""
    
    func loadData(authManager: AuthenticationManager) async {
        // Get polling order name from user's polling order ID
        if let user = authManager.currentUser,
           let pollingOrderId = user.pollingOrderId {
            do {
                let pollingOrders = try await APIService.shared.fetchPollingOrders()
                if let order = pollingOrders.first(where: { $0.id == pollingOrderId }) {
                    pollingOrderName = order.name
                }
            } catch {
                // Handle error silently
            }
        }
        
        // Set welcome message after polling order name is loaded
        if !pollingOrderName.isEmpty {
            welcomeMessage = "Welcome to the order of the \(pollingOrderName) polling application!\n\nPlease select what you would like to view from the menu above"
        } else {
            welcomeMessage = "Welcome to the polling application!\n\nPlease select what you would like to view from the navigation menu below"
        }
        
        // Get app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
} 
