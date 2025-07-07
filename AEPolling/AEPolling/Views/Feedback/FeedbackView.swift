//
//  FeedbackView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var showingSuccessAlert = false
    
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
                            // Header Card
                            VStack(spacing: 16) {
                                Image(systemName: "message.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.appGold)
                                
                                VStack(spacing: 8) {
                                    Text("Send Feedback")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("We'd love to hear from you! Share your thoughts, suggestions, or report any issues.")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(24)
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            
                            // Feedback Form Card
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Feedback Form")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 16) {
                                    // Name Field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Name")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.appText)
                                        
                                        TextField("Enter your name", text: $name)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .background(Color.appBackground)
                                            .cornerRadius(8)
                                    }
                                    
                                    // Email Field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Email")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.appText)
                                        
                                        TextField("Enter your email", text: $email)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.emailAddress)
                                            .autocapitalization(.none)
                                            .background(Color.appBackground)
                                            .cornerRadius(8)
                                    }
                                    
                                    // Message Field
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Message")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.appText)
                                        
                                        TextEditor(text: $message)
                                            .frame(minHeight: 120)
                                            .padding(8)
                                            .background(Color.appBackground)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.appText.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                    
                                    // Error Message
                                    if let errorMessage = viewModel.errorMessage {
                                        Text(errorMessage)
                                            .font(.caption)
                                            .foregroundColor(.appError)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    // Submit Button
                                    Button(action: submitFeedback) {
                                        HStack {
                                            if viewModel.isLoading {
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
                                    .disabled(viewModel.isLoading || name.isEmpty || email.isEmpty || message.isEmpty)
                                    .opacity(viewModel.isLoading || name.isEmpty || email.isEmpty || message.isEmpty ? 0.6 : 1.0)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 20)
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            
                            // Contact Information Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Other Ways to Contact")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    ContactRow(
                                        icon: "envelope",
                                        title: "Email Support",
                                        subtitle: "support@aepolling.com",
                                        action: {
                                            // Open email app
                                        }
                                    )
                                    
                                    Divider()
                                        .padding(.horizontal, 20)
                                    
                                    ContactRow(
                                        icon: "phone",
                                        title: "Phone Support",
                                        subtitle: "+1 (555) 123-4567",
                                        action: {
                                            // Open phone app
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 20)
                            .background(Color.appCardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
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
                    name = ""
                    email = ""
                    message = ""
                }
            } message: {
                Text("Thank you for your feedback! We'll review it and get back to you soon.")
            }
        }
    }
    
    private func submitFeedback() {
        Task {
            let success = await viewModel.submitFeedback(name: name, email: email, message: message)
            if success {
                showingSuccessAlert = true
            }
        }
    }
}

struct ContactRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.appGold)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.appText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.appText.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appText.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
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