//
//  CandidatesView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct CandidatesView: View {
    @StateObject private var viewModel = CandidatesViewModel()
    @State private var selectedCandidate: Candidate?
    @State private var showingCandidateDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Loading candidates...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.appError)
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await viewModel.loadCandidates()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.appSecondary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else if viewModel.candidates.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 50))
                            .foregroundColor(.appGold)
                        
                        Text("No Candidates")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("There are no candidates available at this time.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.candidates) { candidate in
                                CandidateCard(candidate: candidate) {
                                    selectedCandidate = candidate
                                    showingCandidateDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Candidates")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCandidateDetail) {
                if let candidate = selectedCandidate {
                    CandidateDetailView(
                        candidate: candidate,
                        pollingNotes: viewModel.pollingNotes,
                        externalNotes: viewModel.externalNotes,
                        pollingGroups: viewModel.pollingGroups,
                        candidateImages: viewModel.candidateImages,
                        newNoteText: viewModel.newNoteText,
                        isPrivateNote: viewModel.isPrivateNote,
                        showPollingNotes: viewModel.showPollingNotes,
                        showExternalNotes: viewModel.showExternalNotes,
                        onNewNoteTextChange: { viewModel.updateNewNoteText($0) },
                        onPrivateNoteToggle: { viewModel.toggleIsPrivateNote() },
                        onAddNote: { viewModel.addExternalNote() },
                        onDeleteNote: { viewModel.deleteExternalNote($0) },
                        onTogglePollingNotes: { viewModel.togglePollingNotesExpanded() },
                        onToggleExternalNotes: { viewModel.toggleExternalNotesExpanded() },
                        onToggleWatchlist: { viewModel.toggleCandidateWatchlist($0) }
                    )
                }
            }
            .task {
                await viewModel.loadCandidates()
            }
        }
    }
}

struct CandidateCard: View {
    let candidate: Candidate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(candidate.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appText)
                        
                        Text("Status: \(candidate.watchList != nil ? "On Watchlist" : "Not on Watchlist")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(6)
                        
                        Text("ID: \(candidate.id)")
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Status: \(candidate.watchList != nil ? "On Watchlist" : "Not on Watchlist")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.2))
                            .foregroundColor(statusColor)
                            .cornerRadius(6)
                        
                        Text("ID: \(candidate.id)")
                            .font(.caption)
                            .foregroundColor(.appText.opacity(0.6))
                    }
                }
                
                HStack {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.appText.opacity(0.6))
                }
            }
            .padding(16)
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch candidate.watchList != nil ? "On Watchlist" : "Not on Watchlist" {
        case "On Watchlist":
            return .appSuccess
        case "Not on Watchlist":
            return .appGold
        default:
            return .appText
        }
    }
}

struct CandidateDetailView: View {
    let candidate: Candidate
    let pollingNotes: [PollingNote]
    let externalNotes: [ExternalNote]
    let pollingGroups: [PollingGroup]
    let candidateImages: [CandidateImage]
    let newNoteText: String
    let isPrivateNote: Bool
    let showPollingNotes: Bool
    let showExternalNotes: Bool
    let onNewNoteTextChange: (String) -> Void
    let onPrivateNoteToggle: () -> Void
    let onAddNote: () -> Void
    let onDeleteNote: (ExternalNote) -> Void
    let onTogglePollingNotes: () -> Void
    let onToggleExternalNotes: () -> Void
    let onToggleWatchlist: (Candidate) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Candidate Header
                candidateHeaderSection
                
                // Notes Section
                notesSection
                
                // Images Section
                if !candidateImages.isEmpty {
                    imagesSection
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var candidateHeaderSection: some View {
        VStack(spacing: 16) {
            // Profile Image Placeholder
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.appGold)
            
            VStack(spacing: 8) {
                Text(candidate.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Polling Order ID: \(candidate.pollingOrderId)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                if let watchList = candidate.watchList {
                    Text("Watch List: \(watchList)")
                        .font(.caption)
                        .foregroundColor(.appGold)
                }
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private var notesSection: some View {
        VStack(spacing: 16) {
            // Polling Notes
            if !pollingNotes.isEmpty {
                pollingNotesSection
            }
            
            // External Notes
            if !externalNotes.isEmpty {
                externalNotesSection
            }
            
            // Add Note Section
            addNoteSection
        }
    }
    
    private var pollingNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTogglePollingNotes) {
                HStack {
                    Text("Polling Notes (\(pollingNotes.count))")
                        .font(.headline)
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: showPollingNotes ? "chevron.up" : "chevron.down")
                        .foregroundColor(.appText)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showPollingNotes {
                VStack(spacing: 8) {
                    ForEach(pollingNotes) { note in
                        NoteCard(note: note)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private var externalNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggleExternalNotes) {
                HStack {
                    Text("External Notes (\(externalNotes.count))")
                        .font(.headline)
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: showExternalNotes ? "chevron.up" : "chevron.down")
                        .foregroundColor(.appText)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showExternalNotes {
                VStack(spacing: 8) {
                    ForEach(externalNotes) { note in
                        ExternalNoteCard(
                            note: note,
                            onDelete: { onDeleteNote(note) }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private var addNoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Note")
                .font(.headline)
                .foregroundColor(.appText)
            
            TextField("Enter your note...", text: Binding(
                get: { newNoteText },
                set: { onNewNoteTextChange($0) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(Color.white)
            .cornerRadius(8)
            
            Toggle("Private Note", isOn: Binding(
                get: { isPrivateNote },
                set: { _ in onPrivateNoteToggle() }
            ))
            .foregroundColor(.appText)
            
            Button(action: onAddNote) {
                Text("Add Note")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(newNoteText.isEmpty)
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Images")
                .font(.headline)
                .foregroundColor(.appText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(candidateImages) { image in
                        AsyncImage(url: URL(string: image.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
}

struct NoteCard: View {
    let note: PollingNote
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.note ?? "No note content")
                .font(.body)
                .foregroundColor(.appText)
            HStack {
                Text(note.name)
                    .font(.caption)
                    .foregroundColor(.appGold)
                Spacer()
                if let date = ISO8601DateFormatter().date(from: note.createdAt) {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text(note.createdAt)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(8)
    }
}

struct ExternalNoteCard: View {
    let note: ExternalNote
    let onDelete: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.pollingOrderMemberId.name)
                    .font(.headline)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            Text(note.text)
                .font(.body)
                .foregroundColor(.appText)
            if let date = ISO8601DateFormatter().date(from: note.timestamp) {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text(note.timestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(8)
    }
}

@MainActor
class CandidatesViewModel: ObservableObject {
    @Published var candidates: [Candidate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
            candidates = try await apiService.fetchCandidates()
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
    
    func addExternalNote() {
        guard !newNoteText.isEmpty else { return }
        
        // Create a mock PollingOrderMember for the new note
        let mockMember = PollingOrderMember(
            id: -1,
            name: "Current User",
            email: "",
            approved: true,
            removed: false,
            active: true
        )
        
        let newNote = ExternalNote(
            id: -1, // Use -1 for new notes, should be replaced by real id from backend
            candidateId: -1,
            pollingOrderMemberId: mockMember,
            text: newNoteText,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        externalNotes.append(newNote)
        newNoteText = ""
        isPrivateNote = false
    }
    
    func deleteExternalNote(_ note: ExternalNote) {
        externalNotes.removeAll { $0.id == note.id }
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

#Preview {
    CandidatesView()
} 