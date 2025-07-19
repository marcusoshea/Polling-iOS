//
//  FeedbackView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @State private var message = ""
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // Get user info from keychain
    private var currentUser: User? {
        guard let userData = KeychainService.shared.getUserData() else { return nil }
        return User(
            id: userData.id,
            email: userData.email,
            firstName: userData.name.components(separatedBy: " ").first ?? "",
            lastName: userData.name.components(separatedBy: " ").dropFirst().joined(separator: " "),
            pollingOrderId: userData.pollingOrderId
        )
    }
    
    private var userName: String {
        currentUser?.fullName ?? "Unknown User"
    }
    
    private var userEmail: String {
        currentUser?.email ?? "unknown@email.com"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Submitting feedback...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            FeedbackHeader()
                            UserInfoCard(userName: userName, userEmail: userEmail)
                            MessageInputCard(message: $message, errorMessage: $errorMessage, isLoading: viewModel.isLoading, submitAction: submitFeedback)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Feedback Submitted", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    // Reset form
                    message = ""
                    errorMessage = ""
                }
            } message: {
                Text("Thank you for your feedback! We'll review it and get back to you soon.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitFeedback() {
        // Clear previous error
        errorMessage = ""
        
        // Validate message
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedMessage.isEmpty {
            errorMessage = "Please enter your feedback message"
            return
        }
        
        Task {
            // Add "IPHONE" to the message body
            let messageWithPlatform = "\(trimmedMessage)\n\nIPHONE"
            
            let success = await viewModel.submitFeedback(
                name: userName,
                email: userEmail,
                message: messageWithPlatform
            )
            
            if success {
                showingSuccessAlert = true
            } else {
                errorMessage = viewModel.errorMessage ?? "Failed to submit feedback. Please try again."
                showingErrorAlert = true
            }
        }
    }
}

private struct FeedbackHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.appGold)
            VStack(spacing: 8) {
                Text("App Feedback")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text("Note: this form is NOT for candidate feedback.")
                    .font(.body)
                    .italic()
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

private struct UserInfoCard: View {
    let userName: String
    let userEmail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feedback from:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.appText)
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.body)
                    .foregroundColor(.appText)
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.appText.opacity(0.8))
            }
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

private struct MessageInputCard: View {
    @Binding var message: String
    @Binding var errorMessage: String
    let isLoading: Bool
    let submitAction: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Message")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.appText)
            TextEditor(text: $message)
                .frame(minHeight: 150)
                .padding(12)
                .background(Color.appCardBackground)
                .cornerRadius(8)
      
                .disabled(isLoading)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.appError)
                    .multilineTextAlignment(.center)
            }
            Button(action: submitAction) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Submit Feedback")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appSecondary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(isLoading || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
        }
        .padding(.vertical, 20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

@MainActor
class FeedbackViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func submitFeedback(name: String, email: String, message: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: EmptyResponse = try await apiService.submitFeedback(name: name, email: email, message: message)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}

#Preview {
    FeedbackView()
        .environmentObject(AuthenticationManager())
} 