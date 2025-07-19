//
//  RegistrationView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showingPassword = false
    @State private var pollingOrders: [PollingOrder] = []
    @State private var selectedPollingOrder: PollingOrder? = nil
    @State private var isLoadingOrders = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name, email, password
    }

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password.count >= 8 &&
        email.contains("@") &&
        selectedPollingOrder != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Success Dialog
                    if authManager.showRegistrationSuccess, let message = authManager.registrationSuccessMessage {
                        VStack {
                            Text(message)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button("OK") {
                                authManager.showRegistrationSuccess = false
                                dismiss()
                            }
                            .padding(.top, 8)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding()
                    }
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                        
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Join AEPolling to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Registration Form
                    VStack(spacing: 20) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.name)
                                .focused($focusedField, equals: .name)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .email)
                        }
                        
                        // Password Fields
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if showingPassword {
                                    TextField("Enter your password", text: $password)
                                        .textContentType(.newPassword)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(.newPassword)
                                }
                                
                                Button(action: { showingPassword.toggle() }) {
                                    Image(systemName: showingPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .password)
                            
                            if !password.isEmpty && password.count < 8 {
                                Text("Password must be at least 8 characters")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                    // Polling Order Dropdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Polling Order")
                            .font(.headline)
                            .foregroundColor(.primary)
                        if isLoadingOrders {
                            ProgressView()
                        } else {
                            Menu {
                                ForEach(pollingOrders, id: \ .id) { order in
                                    Button(order.name) {
                                        selectedPollingOrder = order
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedPollingOrder?.name ?? "Select Polling Order")
                                        .foregroundColor(selectedPollingOrder == nil ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                        
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: register) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Register")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        .opacity(authManager.isLoading || !isFormValid ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadPollingOrders()
            }
        }
    }
    
    private func register() {
        guard let selectedOrder = selectedPollingOrder else { return }
        Task {
            await authManager.register(
                name: name,
                email: email,
                password: password,
                pollingOrderId: selectedOrder.id
            )
        }
    }

    private func loadPollingOrders() async {
        isLoadingOrders = true
        do {
            pollingOrders = try await APIService.shared.fetchPollingOrders()
        } catch {
            // handle error if needed
        }
        isLoadingOrders = false
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthenticationManager())
} 