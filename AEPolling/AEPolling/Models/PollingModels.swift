//
//  PollingModels.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import Foundation
import SwiftUI

// MARK: - Polling Order
struct PollingOrder: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let adminId: Int
    let adminAssistantId: Int
    let notesTimeVisible: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "polling_order_id"
        case name = "polling_order_name"
        case adminId = "polling_order_admin"
        case adminAssistantId = "polling_order_admin_assistant"
        case notesTimeVisible = "polling_order_notes_time_visible"
    }
}

// MARK: - Polling Session (Current Polling)
struct Polling: Codable, Identifiable {
    let id: Int
    let name: String
    let startDate: String
    let endDate: String
    let pollingOrderId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "polling_id"
        case name = "polling_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case pollingOrderId = "polling_order_id"
    }
}

// MARK: - Candidate
struct Candidate: Codable, Identifiable {
    let id: Int
    let name: String
    let pollingOrderId: Int
    let authToken: String?
    let watchList: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "candidate_id"
        case name
        case pollingOrderId = "polling_order_id"
        case authToken = "auth_token"
        case watchList = "watch_list"
    }
}

// MARK: - Polling Order Member
struct PollingOrderMember: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let approved: Bool
    let removed: Bool
    let active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "polling_order_member_id"
        case name
        case email
        case approved
        case removed
        case active
    }
}

// MARK: - External Note
struct ExternalNote: Identifiable, Codable {
    let id: Int
    let candidateId: Int
    let pollingOrderMemberId: PollingOrderMember
    let text: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id = "external_notes_id"
        case candidateId = "candidate_id"
        case pollingOrderMemberId = "polling_order_member_id"
        case text = "external_note"
        case timestamp = "en_created_at"
    }
}

// MARK: - Polling Note
struct PollingNote: Codable, Identifiable {
    let id: Int
    let pollingId: Int
    let pollingName: String
    let startDate: String
    let endDate: String
    let pollingOrderId: Int
    let candidateId: Int
    let pollingCandidateId: Int
    let name: String
    let link: String?
    let watchList: Bool
    let note: String?
    let vote: Int?
    let createdAt: String
    let pollingOrderMemberId: Int
    let completed: Bool
    let isPrivate: Bool
    let email: String
    let password: String
    let memberCreatedAt: String
    let newPasswordToken: Int?
    let newPasswordTokenTimestamp: String?
    let approved: Bool
    let removed: Bool
    let active: Bool
    let member_name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "polling_notes_id"
        case pollingId = "polling_id"
        case pollingName = "polling_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case pollingOrderId = "polling_order_id"
        case candidateId = "candidate_id"
        case pollingCandidateId = "polling_candidate_id"
        case name
        case link
        case watchList = "watch_list"
        case note
        case vote
        case createdAt = "pn_created_at"
        case pollingOrderMemberId = "polling_order_member_id"
        case completed
        case isPrivate = "private"
        case email
        case password
        case memberCreatedAt = "pom_created_at"
        case newPasswordToken = "new_password_token"
        case newPasswordTokenTimestamp = "new_password_token_timestamp"
        case approved
        case removed
        case active
        case member_name
    }
}

// MARK: - Polling Note Request
struct PollingNoteRequest: Codable {
    let pollingId: Int
    let pollingName: String
    let startDate: String
    let endDate: String
    let pollingOrderId: Int
    let candidateId: Int
    let pollingCandidateId: Int?
    let name: String
    let link: String
    let watchList: Bool
    let pollingNotesId: Int?
    let note: String?
    let vote: Int?
    let pnCreatedAt: String?
    let pollingOrderMemberId: Int?
    let completed: Bool
    let isPrivate: Bool
    let authToken: String?

    enum CodingKeys: String, CodingKey {
        case pollingId = "polling_id"
        case pollingName = "polling_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case pollingOrderId = "polling_order_id"
        case candidateId = "candidate_id"
        case pollingCandidateId = "polling_candidate_id"
        case name
        case link
        case watchList = "watch_list"
        case pollingNotesId = "polling_notes_id"
        case note
        case vote
        case pnCreatedAt = "pn_created_at"
        case pollingOrderMemberId = "polling_order_member_id"
        case completed
        case isPrivate = "private"
        case authToken
    }
}

// MARK: - Polling Summary
struct PollingSummary: Codable {
    let pollingId: Int
    let pollingName: String? // Made optional
    let startDate: String?   // Made optional
    let endDate: String?     // Made optional
    let pollingOrderId: Int
    let candidateId: Int
    let pollingCandidateId: Int
    let name: String
    let link: String?
    let watchList: Bool?
    let pollingNotesId: Int?
    let note: String?
    let vote: Int?
    let pnCreatedAt: String?
    let pollingOrderMemberId: Int?
    let completed: Bool
    let isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case pollingId = "polling_id"
        case pollingName = "polling_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case pollingOrderId = "polling_order_id"
        case candidateId = "candidate_id"
        case pollingCandidateId = "polling_candidate_id"
        case name
        case link
        case watchList = "watch_list"
        case pollingNotesId = "polling_notes_id"
        case note
        case vote
        case pnCreatedAt = "pn_created_at"
        case pollingOrderMemberId = "polling_order_member_id"
        case completed
        case isPrivate = "private"
    }
}

// MARK: - Polling Report Summary
struct PollingReportSummary: Codable {
    let pollingId: Int
    let totalVotes: Int
    let positiveVotes: Int
    let negativeVotes: Int
    let neutralVotes: Int
    
    enum CodingKeys: String, CodingKey {
        case pollingId = "polling_id"
        case totalVotes = "total_votes"
        case positiveVotes = "positive_votes"
        case negativeVotes = "negative_votes"
        case neutralVotes = "neutral_votes"
    }
}

// MARK: - Polling Report (API /polling/pollingreport/:id)
struct PollingReport: Codable {
    let polling_id: Int
    let polling_name: String
    let start_date: String
    let end_date: String
    let polling_order_id: Int
    let polling_order_name: String
    let polling_order_admin: Int
    let polling_order_admin_assistant: Int
    let polling_order_polling_participation: Int
    let polling_order_polling_score: Int
    let polling_order_polling_type: Int
    let polling_order_notes_time_visible: Int
}

struct PollingReportResponse {
    let report: PollingReport
    let activeMembers: String
    let memberParticipation: String

    // Custom initializer for mixed array response
    init(from array: [Any]) throws {
        guard !array.isEmpty else {
            throw NSError(domain: "Decoding", code: 0, userInfo: [NSLocalizedDescriptionKey: "No report data available for this polling order."])
        }
        guard let reportDict = array.first as? [String: Any],
              let reportData = try? JSONSerialization.data(withJSONObject: reportDict),
              let report = try? JSONDecoder().decode(PollingReport.self, from: reportData) else {
            throw NSError(domain: "Decoding", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing report object for this polling order."])
        }
        let activeMembers = (array.count > 1 ? (array[1] as? [String: String])?["active_members"] : nil) ?? ""
        let memberParticipation = (array.count > 2 ? (array[2] as? [String: String])?["member_participation"] : nil) ?? ""
        self.report = report
        self.activeMembers = activeMembers
        self.memberParticipation = memberParticipation
    }
}

// MARK: - Candidate Images
struct CandidateImages: Codable {
    let candidateId: Int
    let name: String
    let pollingOrderId: Int
    let link: String
    let watchList: Bool
    let imageId: Int
    let imageDescription: String
    let awsKey: String
    
    enum CodingKeys: String, CodingKey {
        case candidateId = "candidate_id"
        case name
        case pollingOrderId = "polling_order_id"
        case link
        case watchList = "watch_list"
        case imageId = "image_id"
        case imageDescription = "image_description"
        case awsKey = "aws_key"
    }
}

// MARK: - Feedback Request
struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let message: String
}

// MARK: - Activity Models

struct PollingActivity: Codable, Identifiable {
    let id: Int
    let type: String
    let description: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case description
        case timestamp
    }
}

struct VoteData: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
}

struct PollingSession: Identifiable, Codable {
    let id: Int
    let title: String
    let orderId: Int
    let status: Status
    let candidateCount: Int
    let createdAt: Date
    
    enum Status: String, Codable, CaseIterable {
        case active = "Active"
        case completed = "Completed"
        case paused = "Paused"
        
        var color: Color {
            switch self {
            case .active: return .green
            case .completed: return .blue
            case .paused: return .orange
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
}

// MARK: - Polling Group
struct PollingGroup: Identifiable, Codable {
    let id: Int
    let name: String
}

// MARK: - Candidate Image
struct CandidateImage: Identifiable, Codable {
    let id: Int
    let candidateId: Int
    let imageUrl: String
    let imageDescription: String
    let plainDescription: String

    enum CodingKeys: String, CodingKey {
        case id
        case candidateId = "candidate_id"
        case imageUrl = "image_url"
        case imageDescription = "image_description"
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        candidateId = try container.decode(Int.self, forKey: .candidateId)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        imageDescription = try container.decode(String.self, forKey: .imageDescription)
        plainDescription = cleanHtmlText(imageDescription)
    }

    // For manual creation (if needed)
    init(id: Int, candidateId: Int, imageUrl: String, imageDescription: String) {
        self.id = id
        self.candidateId = candidateId
        self.imageUrl = imageUrl
        self.imageDescription = imageDescription
        self.plainDescription = cleanHtmlText(imageDescription)
    }
}

// MARK: - Polling Member (for proxy voting)
struct PollingMember: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let approved: Bool
    let removed: Bool
    let active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "polling_order_member_id"
        case name
        case email
        case approved
        case removed
        case active
    }
}

// MARK: - Candidate Vote (for voting interface)
struct CandidateVote: Codable, Identifiable, Equatable {
    let id = UUID()
    let candidateId: Int
    let candidateName: String
    var note: String
    var vote: Int?
    var isPrivate: Bool
    let pollingNotesId: Int?
    let completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case candidateId
        case candidateName
        case note
        case vote
        case isPrivate
        case pollingNotesId
        case completed
    }
}

// MARK: - Shared NoteItem for UI
struct NoteItem: Identifiable {
    let id = UUID()
    let text: String
    let author: String
    let timestamp: String
    let pollTitle: String?
    let isPrivate: Bool
} 

// Move cleanHtmlText here for use in CandidateImage
fileprivate func cleanHtmlText(_ htmlString: String) -> String {
    let data = Data(htmlString.utf8)
    if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
        return attributedString.string
    }
    return htmlString
} 

struct LoginResponse: Codable {
    let accessToken: String
    let isOrderAdmin: Bool
    let pollingOrder: Int
    let memberId: Int
    let name: String
    let email: String
    let active: Bool

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case isOrderAdmin
        case pollingOrder
        case memberId
        case name
        case email
        case active
    }
} 