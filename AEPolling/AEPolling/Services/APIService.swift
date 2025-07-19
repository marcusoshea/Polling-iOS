//
//  APIService.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case serverError(Int)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

// Add this struct before the APIService class so it is in scope
struct ExternalNoteRequest: Codable {
    let candidate_id: String
    let external_note: String
    let polling_order_member_id: Int
    let en_created_at: String
    let authToken: String
}

struct ExternalNoteDeleteRequest: Codable {
    let external_notes_id: Int
    let polling_order_member_id: Int
    let authToken: String
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api-polling.aethelmearc.org"
    private let session = URLSession.shared
    private let keychainService = KeychainService.shared
    
    private init() {}
    
    // MARK: - Authentication Endpoints
    
    func login(email: String, password: String, pollingOrderId: Int) async throws -> LoginResponse {
        let loginRequest = LoginRequest(email: email, password: password, pollingOrderId: pollingOrderId)
        return try await post(endpoint: "/member/login", body: loginRequest)
    }
    
    func register(name: String, email: String, password: String, pollingOrderId: Int, pomCreatedAt: String) async throws -> RegistrationResponse {
        let registrationRequest = RegistrationRequest(name: name, email: email, password: password, pollingOrderId: pollingOrderId, pomCreatedAt: pomCreatedAt)
        return try await post(endpoint: "/member/create", body: registrationRequest)
    }
    
    func requestPasswordReset(email: String) async throws -> EmptyResponse {
        let resetRequest = ResetPasswordRequest(email: email)
        return try await post(endpoint: "/member/passwordToken", body: resetRequest)
    }
    
    func resetPassword(token: String, newPassword: String) async throws -> EmptyResponse {
        let resetPassword = ResetPassword(token: token, newPassword: newPassword)
        return try await post(endpoint: "verify/\(token)", body: resetPassword)
    }
    
    // MARK: - Profile Management
    
    func updateProfile(memberId: Int, updates: [String: String]) async throws -> EmptyResponse {
        return try await put(endpoint: "/member/edit/\(memberId)", body: updates)
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws -> EmptyResponse {
        // Get current user data from keychain
        guard let userData = keychainService.getUserData(),
              let pollingOrderId = userData.pollingOrderId else {
            throw APIError.unauthorized
        }
        let body: [String: String] = [
            "email": userData.email,
            "password": currentPassword,
            "newPassword": newPassword,
            "pollingOrderId": String(pollingOrderId)
        ]
        return try await put(endpoint: "/member/changePassword", body: body)
    }
    
    // MARK: - Polling Orders
    
    func fetchPollingOrders() async throws -> [PollingOrder] {
        return try await get(endpoint: "/pollingorder", requiresAuth: false)
    }
    
    // MARK: - Current Polling
    
    func getCurrentPolling(orderId: Int) async throws -> Polling? {
        return try await getOptional(endpoint: "/polling/currentpolling/\(orderId)")
    }
    
    func fetchPollingData() async throws -> [Polling] {
        return try await get(endpoint: "/polling/all")
    }
    
    // MARK: - Polling Reports
    
    func getPollingReport(orderId: Int) async throws -> [PollingReport] {
        return try await get(endpoint: "/polling/pollingreport/\(orderId)")
    }
    
    func getInProcessPollingReport(orderId: Int) async throws -> PollingReport {
        return try await get(endpoint: "/polling/inprocesspollingreport/\(orderId)")
    }
    
    func getPollingReportSummary(orderId: Int) async throws -> PollingReportSummary {
        return try await get(endpoint: "/polling/pollingreport/\(orderId)/summary")
    }
    
    func getPollingReportDetails(orderId: Int) async throws -> [PollingSummary] {
        return try await get(endpoint: "/polling/pollingreport/\(orderId)/details")
    }
    
    func getPollingReportNotes(orderId: Int) async throws -> [PollingNote] {
        return try await get(endpoint: "/polling/pollingreport/\(orderId)/notes")
    }
    
    func getPollingReportCandidates(orderId: Int) async throws -> [Candidate] {
        return try await get(endpoint: "/polling/pollingreport/\(orderId)/candidates")
    }
    
    func getPollingReportTotals(pollingId: Int) async throws -> [VoteTotal] {
        return try await get(endpoint: "/pollingnote/totals/\(pollingId)")
    }
    
    // MARK: - Candidates
    
    func getAllCandidates(orderId: Int) async throws -> [Candidate] {
        return try await get(endpoint: "/candidate/all/\(orderId)")
    }
    
    func getCandidate(candidateId: Int) async throws -> Candidate {
        return try await get(endpoint: "/candidate/\(candidateId)")
    }
    
    func getCandidateImages(candidateId: String) async throws -> [CandidateImages] {
        return try await get(endpoint: "/candidate/candidateImages/\(candidateId)")
    }
    
    func fetchCandidates() async throws -> [Candidate] {
        return try await get(endpoint: "/candidates/all")
    }
    
    // MARK: - Members
    
    func getAllMembers(orderId: Int) async throws -> [PollingMember] {
        return try await get(endpoint: "/member/all/\(orderId)")
    }
    
    // MARK: - Polling Notes
    
    func createPollingNotes(notes: [PollingNoteRequest]) async throws -> Bool {
        return try await post(endpoint: "/pollingnote/create", body: notes)
    }
    
    func getAllPollingNotesById(pollingNotesId: String) async throws -> [PollingNote] {
        let body = ["polling_notes_id": pollingNotesId]
        return try await post(endpoint: "/pollingnote/all", body: body)
    }
    
    func getAllPollingNotesForReport() async throws -> [PollingNote] {
        // The /pollingnote/all endpoint expects a POST with an empty body or as required
        let body: [String: String] = [:]
        return try await post(endpoint: "/pollingnote/all", body: body)
    }
    
    func getPollingNoteByCandidateId(candidateId: Int) async throws -> [PollingNote] {
        return try await get(endpoint: "/polling/allpn/\(candidateId)")
    }
    
    // MARK: - External Notes
    
    func getExternalNoteByCandidateId(candidateId: Int) async throws -> [ExternalNote] {
        return try await get(endpoint: "/externalnote/candidate/\(candidateId)")
    }
    
    func createExternalNote(candidateId: Int, note: String, pollingOrderMemberId: Int, enCreatedAt: String, authToken: String) async throws -> EmptyResponse {
        let body = ExternalNoteRequest(
            candidate_id: "\(candidateId)",
            external_note: note,
            polling_order_member_id: pollingOrderMemberId,
            en_created_at: enCreatedAt,
            authToken: authToken
        )
        return try await post(endpoint: "/externalnote/create", body: body)
    }
    
    func removeExternalNote(externalNoteId: Int, pollingOrderMemberId: Int, authToken: String) async throws -> EmptyResponse {
        let body = ExternalNoteDeleteRequest(
            external_notes_id: externalNoteId,
            polling_order_member_id: pollingOrderMemberId,
            authToken: authToken
        )
        return try await post(endpoint: "/externalnote/delete", body: body)
    }
    
    // MARK: - Polling Summary
    
    func getPollingSummary(pollingId: Int, memberId: String) async throws -> [PollingSummary] {
        return try await get(endpoint: "/polling/pollingsummary/\(pollingId)/\(memberId)")
    }
    
    // MARK: - Feedback
    
    func submitFeedback(name: String, email: String, message: String) async throws -> EmptyResponse {
        let feedbackRequest = FeedbackRequest(name: name, email: email, message: message)
        return try await post(endpoint: "/feedback", body: feedbackRequest)
    }
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        do {
            print("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
            if let headers = request.allHTTPHeaderFields {
                print("📋 Headers: \(headers)")
            }
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "API", code: -1, userInfo: nil))
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            print("📄 Response Headers: \(httpResponse.allHeaderFields)")
            
            // Print response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Response Data: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(T.self, from: data)
                    print("✅ Successfully decoded response as \(T.self)")
                    return result
                } catch {
                    print("❌ Decoding error for \(T.self): \(error)")
                    print("❌ Decoding error details: \(error.localizedDescription)")
                    
                    // Try to decode as a different type to see what we're actually getting
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ Raw JSON: \(jsonString)")
                    }
                    
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                print("❌ Network error: \(error)")
                throw APIError.networkError(error)
            }
        }
    }
    
    private func performOptionalRequest<T: Codable>(_ request: URLRequest) async throws -> T? {
        do {
            print("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
            if let headers = request.allHTTPHeaderFields {
                print("📋 Headers: \(headers)")
            }
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "API", code: -1, userInfo: nil))
            }
            
            print("📡 Response Status: \(httpResponse.statusCode)")
            print("📄 Response Headers: \(httpResponse.allHeaderFields)")
            
            // Print response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Response Data: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Check if response is empty
                if data.isEmpty {
                    print("✅ Empty response received - no active polling")
                    return nil
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(T.self, from: data)
                    print("✅ Successfully decoded response as \(T.self)")
                    return result
                } catch {
                    print("❌ Decoding error for \(T.self): \(error)")
                    print("❌ Decoding error details: \(error.localizedDescription)")
                    
                    // Try to decode as a different type to see what we're actually getting
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("❌ Raw JSON: \(jsonString)")
                    }
                    
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response: \(errorString)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                print("❌ Network error: \(error)")
                throw APIError.networkError(error)
            }
        }
    }
    
    private func get<T: Codable>(endpoint: String, requiresAuth: Bool = true) async throws -> T {
        var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = keychainService.getAuthToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        return try await performRequest(request)
    }
    
    private func getOptional<T: Codable>(endpoint: String, requiresAuth: Bool = true) async throws -> T? {
        var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = keychainService.getAuthToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        return try await performOptionalRequest(request)
    }
    
    private func post<T: Codable, U: Codable>(endpoint: String, body: T) async throws -> U {
        var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = keychainService.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        return try await performRequest(request)
    }
    
    private func put<T: Codable, U: Codable>(endpoint: String, body: T) async throws -> U {
        var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = keychainService.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        return try await performRequest(request)
    }
}

extension APIService {
    // New method to fetch and decode the mixed array response for polling report
    func getPollingReportResponse(orderId: Int, inProcess: Bool = false) async throws -> PollingReportResponse {
        let endpoint = inProcess ? "/polling/inprocesspollingreport/\(orderId)" : "/polling/pollingreport/\(orderId)"
        var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = keychainService.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: request)
        let array = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
        return try PollingReportResponse(from: array)
    }
} 