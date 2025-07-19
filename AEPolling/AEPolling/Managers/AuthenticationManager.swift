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
    @Published var showRegistrationSuccess = false
    @Published var registrationSuccessMessage: String? = nil
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    init() {
        // Check if user is already logged in
        if let token = keychainService.getAuthToken() {
            self.isAuthenticated = true
            // Load user data from keychain
            if let userData = keychainService.getUserData() {
                // Convert UserData to User
                let user = User(
                    id: userData.id,
                    email: userData.email,
                    firstName: userData.name.components(separatedBy: " ").first ?? "",
                    lastName: userData.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                    pollingOrderId: userData.pollingOrderId
                )
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
            let loginResponse = try await apiService.login(email: email, password: password, pollingOrderId: pollingOrderId)
            
            // Save the auth token
            keychainService.saveAuthToken(loginResponse.accessToken)
            
            // Create User object
            let user = User(
                id: loginResponse.memberId,
                email: loginResponse.email,
                firstName: loginResponse.name.components(separatedBy: " ").first ?? "",
                lastName: loginResponse.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
                pollingOrderId: loginResponse.pollingOrder
            )
            
            // Convert User to UserData for storage
            let userData = UserData(
                id: user.id,
                email: user.email,
                name: user.fullName,
                pollingOrderId: user.pollingOrderId,
                authToken: loginResponse.accessToken
            )
            
            self.currentUser = user
            keychainService.saveUserData(userData)
            self.isAuthenticated = true
            self.isLoading = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return false
        }
    }
    
    func register(name: String, email: String, password: String, pollingOrderId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let created = dateFormatter.string(from: Date())
            let _: RegistrationResponse = try await apiService.register(name: name, email: email, password: password, pollingOrderId: pollingOrderId, pomCreatedAt: created)
            self.registrationSuccessMessage = "Registration successful: \(name)\n\nYou must be approved by an admin prior to being granted access."
            self.showRegistrationSuccess = true
            self.isLoading = false
            return true
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
    
    func changePassword(currentPassword: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: EmptyResponse = try await apiService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            
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
