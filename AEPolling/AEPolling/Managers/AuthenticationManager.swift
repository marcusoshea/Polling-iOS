//
//  AuthenticationManager.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import Foundation
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    init() {
        // Check if user is already logged in
        if let token = keychainService.getAuthToken() {
            self.isAuthenticated = true
            // Load user data from keychain
            if let user = keychainService.getUserData() {
                self.currentUser = user
            }
            // Validate token with server
            Task {
                await validateToken(token)
            }
        }
    }
    
    func login(email: String, password: String, pollingOrderId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let pollingOrderMember: PollingOrderMember = try await apiService.login(email: email, password: password, pollingOrderId: pollingOrderId)
            
            // Note: The login API response doesn't include accessToken, so we'll need to handle this differently
            // For now, we'll assume the token is stored separately or the login process handles token storage
            
            // Create a User object from PollingOrderMember for compatibility
            let user = User(
                id: pollingOrderMember.id,
                email: pollingOrderMember.email,
                firstName: pollingOrderMember.name.components(separatedBy: " ").first ?? "",
                lastName: pollingOrderMember.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                pollingOrderId: pollingOrderId // Use the passed pollingOrderId since it's not in the response
            )
            keychainService.saveUserData(user)
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            return true
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return false
        }
    }
    
    func register(email: String, password: String, firstName: String, lastName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: RegistrationResponse = try await apiService.register(email: email, password: password, firstName: firstName, lastName: lastName)
            
            // Auto-login after successful registration
            return await login(email: email, password: password, pollingOrderId: 0)
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return false
        }
    }
    
    func requestPasswordReset(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: EmptyResponse = try await apiService.requestPasswordReset(email: email)
            
            self.isLoading = false
            return true
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return false
        }
    }
    
    func resetPassword(token: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: EmptyResponse = try await apiService.resetPassword(token: token, newPassword: newPassword)
            
            self.isLoading = false
            return true
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return false
        }
    }
    
    func signOut() {
        keychainService.clearAuthToken()
        keychainService.clearUserData()
        self.isAuthenticated = false
        self.currentUser = nil
    }
    
    private func validateToken(_ token: String) async {
        // Implement token validation logic
        // For now, we'll assume the token is valid if it exists
    }
} 
