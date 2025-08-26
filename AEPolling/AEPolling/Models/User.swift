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
    let name: String
    let email: String
    let password: String
    let pollingOrderId: Int
    let pomCreatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
        case pollingOrderId = "polling_order_id"
        case pomCreatedAt = "pom_created_at"
    }
}

struct RegistrationResponse: Codable {
    let name: String
    let email: String
    let password: String
    let polling_order_id: Int
    let pom_created_at: String
    let polling_order_member_id: Int
}

struct ResetPasswordRequest: Codable {
    let email: String
}

struct ResetPassword: Codable {
    let token: String
    let newPassword: String
}

struct EmptyResponse: Codable {} 

struct UserData: Codable {
    let id: Int
    let email: String
    let name: String
    let pollingOrderId: Int?
    let authToken: String?
} 
