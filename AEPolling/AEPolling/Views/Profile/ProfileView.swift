//
//  ProfileView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.appGold)
                    
                    VStack(spacing: 8) {
                        Text(authManager.currentUser?.fullName ?? "User")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 20)
                
                // Profile Information Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profile Information")
                        .font(.headline)
                        .foregroundColor(.appText)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ProfileInfoRow(title: "Name", value: authManager.currentUser?.fullName ?? "N/A")
                        ProfileInfoRow(title: "Email", value: authManager.currentUser?.email ?? "N/A")
                      
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Account Actions Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Account Actions")
                        .font(.headline)
                        .foregroundColor(.appText)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            // Change password action
                        }) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.appText)
                                Text("Change Password")
                                    .foregroundColor(.appText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.appText.opacity(0.6))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.appError)
                                Text("Sign Out")
                                    .foregroundColor(.appError)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding(.vertical, 20)
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Sign Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.appText.opacity(0.8))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.appText)
        }
    }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    
    func updateProfile(firstName: String, lastName: String, email: String) async {
        // Implement profile update
    }
    
    func changePassword(currentPassword: String, newPassword: String) async {
        // Implement password change
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
} 
