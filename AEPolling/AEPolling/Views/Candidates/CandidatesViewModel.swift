//
//  CandidatesViewModel.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

@MainActor
class CandidatesViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCandidate: Candidate?
    
    // Properties for CandidateDetailView
    @Published var pollingNotes: [PollingNote] = []
    @Published var externalNotes: [ExternalNote] = []
    @Published var pollingGroups: [PollingGroup] = []
    @Published var candidateImages: [CandidateImage] = []
    @Published var newNoteText: String = ""
    @Published var isPrivateNote: Bool = false
    @Published var showPollingNotes: Bool = false
    @Published var showExternalNotes: Bool = false
    
    private let apiService = APIService.shared
    
    func loadCandidates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get polling order ID from user
            let user = KeychainService.shared.getUserData()
            guard let orderId = user?.pollingOrderId else {
                errorMessage = "Polling order ID not found. Please log in again."
                isLoading = false
                return
            }
            candidates = try await apiService.getAllCandidates(orderId: orderId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Load candidate details when a candidate is selected
    func loadCandidateDetails(for candidate: Candidate) async {
        selectedCandidate = candidate
        isLoading = true
        errorMessage = nil
        
        do {
            async let pollingNotesTask = apiService.getPollingNoteByCandidateId(candidateId: candidate.id)
            async let externalNotesTask = apiService.getExternalNoteByCandidateId(candidateId: candidate.id)
            async let candidateImagesTask = apiService.getCandidateImages(candidateId: String(candidate.id))
            
            let (polling, external, images) = try await (pollingNotesTask, externalNotesTask, candidateImagesTask)
            pollingNotes = polling
            externalNotes = external
            
            // Convert CandidateImages array to CandidateImage array for UI
            candidateImages = images.map { image in
                let imageUrl = "https://s3.us-east-2.amazonaws.com/polling.aethelmearc.org/\(image.awsKey)"
                print("🖼️ Generated image URL: \(imageUrl)")
                return CandidateImage(
                    id: image.imageId,
                    candidateId: image.candidateId,
                    imageUrl: imageUrl,
                    imageDescription: image.imageDescription
                )
            }
            
            // Reset UI state for new candidate
            newNoteText = ""
            isPrivateNote = false
            showPollingNotes = false
            showExternalNotes = false
            
            // Expand the most recent poll by default
            if let mostRecent = polling.first?.pollingName {
                // This will be handled in the view when it loads
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Methods for CandidateDetailView
    func updateNewNoteText(_ text: String) {
        newNoteText = text
    }
    
    func toggleIsPrivateNote() {
        isPrivateNote.toggle()
    }
    
    func addExternalNote(_ noteText: String) async {
        guard !noteText.isEmpty else { return }
        
        guard let selectedCandidate = selectedCandidate else {
            errorMessage = "No candidate selected"
            return
        }
        
        // Gather required fields
        guard let user = KeychainService.shared.getUserData() else {
            errorMessage = "User not found. Please log in again."
            return
        }
        guard let authToken = KeychainService.shared.getAuthToken() else {
            errorMessage = "Auth token not found. Please log in again."
            return
        }
        let pollingOrderMemberId = user.id
        let enCreatedAt: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        }()
        
        do {
            try await apiService.createExternalNote(
                candidateId: selectedCandidate.id,
                note: noteText,
                pollingOrderMemberId: pollingOrderMemberId,
                enCreatedAt: enCreatedAt,
                authToken: authToken
            )
            
            // Reload external notes to get the updated list
            let updatedNotes = try await apiService.getExternalNoteByCandidateId(candidateId: selectedCandidate.id)
            externalNotes = updatedNotes
            
            // No need to clear newNoteText here; handled in the view
            isPrivateNote = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteExternalNote(_ note: ExternalNote) async {
        do {
            guard let user = KeychainService.shared.getUserData() else {
                errorMessage = "User not found. Please log in again."
                return
            }
            guard let authToken = KeychainService.shared.getAuthToken() else {
                errorMessage = "Auth token not found. Please log in again."
                return
            }
            try await apiService.removeExternalNote(
                externalNoteId: note.id,
                pollingOrderMemberId: user.id,
                authToken: authToken
            )
            // Reload external notes to get the updated list
            if let selectedCandidate = selectedCandidate {
                let updatedNotes = try await apiService.getExternalNoteByCandidateId(candidateId: selectedCandidate.id)
                externalNotes = updatedNotes
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func togglePollingNotesExpanded() {
        showPollingNotes.toggle()
    }
    
    func toggleExternalNotesExpanded() {
        showExternalNotes.toggle()
    }
    
    func toggleCandidateWatchlist(_ candidate: Candidate) {
        // This would typically call an API to toggle watchlist status
        // For now, we'll just print a message
        print("Toggle watchlist for candidate: \(candidate.name)")
    }
} 