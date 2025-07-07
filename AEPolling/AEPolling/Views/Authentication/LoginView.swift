//
//  LoginView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var selectedPollingOrder: PollingOrder?
    @State private var pollingOrders: [PollingOrder] = []
    @State private var isLoadingOrders = false
    @State private var showingRegistration = false
    @State private var showingPasswordReset = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "list.clipboard.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appGold)
                    
                    Text("AEPolling")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Sign in to your account")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Polling Order")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isLoadingOrders {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                                Text("Loading polling orders...")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(8)
                        } else {
                            Menu {
                                ForEach(pollingOrders) { order in
                                    Button(order.name) {
                                        selectedPollingOrder = order
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedPollingOrder?.name ?? "Select a polling order")
                                        .foregroundColor(selectedPollingOrder == nil ? .white.opacity(0.6) : .appText)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.appCardBackground)
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .email)
                            .background(Color.appCardBackground)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .background(Color.appCardBackground)
                            .cornerRadius(8)
                    }
                    
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.appError)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: signIn) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appSecondary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty || selectedPollingOrder == nil)
                    .opacity(authManager.isLoading || email.isEmpty || password.isEmpty || selectedPollingOrder == nil ? 0.6 : 1.0)
                }
                .padding(.horizontal, 30)
                
                // Additional Options
                VStack(spacing: 16) {
                    Button("Forgot Password?") {
                        showingPasswordReset = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.appGold)
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button("Sign Up") {
                            showingRegistration = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.appGold)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
            }
            .sheet(isPresented: $showingPasswordReset) {
                RequestResetPasswordView()
            }
            .task {
                await loadPollingOrders()
            }
        }
    }
    
    private func loadPollingOrders() async {
        isLoadingOrders = true
        do {
            pollingOrders = try await APIService.shared.fetchPollingOrders()
            print("Successfully loaded \(pollingOrders.count) polling orders")
            for order in pollingOrders {
                print("Polling Order: \(order.name) (ID: \(order.id))")
            }
        } catch {
            print("Failed to load polling orders: \(error)")
            print("Error details: \(error.localizedDescription)")
            // Handle error - could show an alert or message
        }
        isLoadingOrders = false
    }
    
    private func signIn() {
        guard let pollingOrder = selectedPollingOrder else { return }
        Task {
            await authManager.login(email: email, password: password, pollingOrderId: pollingOrder.id)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 