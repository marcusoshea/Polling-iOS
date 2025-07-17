//
//  ChangePasswordView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case currentPassword, newPassword, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.appGold)
                    
                    Text("Change Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Enter your current password and choose a new one")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Form
                VStack(spacing: 20) {
                    // Current Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("Enter current password", text: $currentPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .currentPassword)
                            .textContentType(.password)
                    }
                    
                    // New Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("Enter new password", text: $newPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .newPassword)
                            .textContentType(.newPassword)
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm New Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .confirmPassword)
                            .textContentType(.newPassword)
                    }
                    
                    // Password Requirements
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password Requirements:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            RequirementRow(
                                text: "At least 6 characters",
                                isMet: newPassword.count >= 6
                            )
                            RequirementRow(
                                text: "Passwords match",
                                isMet: newPassword == confirmPassword && !newPassword.isEmpty
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.appError)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Change Password Button
                    Button(action: changePassword) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Change Password")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.appGold : Color.appGold.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid || authManager.isLoading)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.appGold)
                }
            }
            .alert("Password Changed", isPresented: $showingSuccess) {
                Button("OK") {
                    // Sign out and dismiss
                    authManager.signOut()
                    dismiss()
                }
            } message: {
                Text("Your password has been changed successfully. You will be signed out and need to log in again.")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword &&
        !authManager.isLoading
    }
    
    private func changePassword() {
        guard isFormValid else { return }
        
        Task {
            let success = await authManager.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            
            if success {
                showingSuccess = true
            } else {
                errorMessage = authManager.errorMessage ?? "Failed to change password. Please try again."
                showingError = true
            }
        }
    }
}

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .appSuccess : .white.opacity(0.6))
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthenticationManager())
} 