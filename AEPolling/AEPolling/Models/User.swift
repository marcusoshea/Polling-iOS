//
//  User.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let pollingOrderId: Int?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
    let pollingOrderId: Int
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case pollingOrderId = "polling_order_id"
    }
}

struct RegistrationRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}

struct RegistrationResponse: Codable {
    let message: String
    let user: User
}

struct ResetPasswordRequest: Codable {
    let email: String
}

struct ResetPassword: Codable {
    let token: String
    let newPassword: String
}

struct EmptyResponse: Codable {} 
