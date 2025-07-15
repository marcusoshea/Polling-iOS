//
//  CandidatesView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct CandidatesView: View {
    @StateObject private var viewModel = CandidatesViewModel()
    @State private var showingCandidateDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else if viewModel.candidates.isEmpty {
                    emptyView
                } else {
                    candidatesListView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Candidates")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCandidateDetail) {
                candidateDetailSheet
            }
            .task {
                await viewModel.loadCandidates()
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
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
        }
    }
    
    private func errorView(_ errorMessage: String) -> some View {
        VStack {
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
        }
    }
    
    private var emptyView: some View {
        VStack {
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
        }
    }
    
    private var candidatesListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    ForEach(viewModel.candidates) { candidate in
                        Button(action: {
                            showingCandidateDetail = true
                            Task {
                                await viewModel.loadCandidateDetails(for: candidate)
                            }
                        }) {
                            HStack {
                                Text(candidate.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appText)
                                if candidate.watchList == true {
                                    Text(" Watchlist")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.appGold)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.appText.opacity(0.6))
                            }
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        if candidate.id != viewModel.candidates.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(Color.appCardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
        }
    }
    
    private var candidateDetailSheet: some View {
        if let candidate = viewModel.selectedCandidate {
            if viewModel.isLoading {
                return AnyView(
                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.white)
                            Text("Loading candidate details...")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground)
                )
            } else {
                return AnyView(
                    CandidateDetailView(
                        candidate: candidate,
                        pollingNotes: viewModel.pollingNotes,
                        externalNotes: viewModel.externalNotes,
                        pollingGroups: viewModel.pollingGroups,
                        candidateImages: viewModel.candidateImages,
                        isPrivateNote: viewModel.isPrivateNote,
                        showPollingNotes: viewModel.showPollingNotes,
                        showExternalNotes: viewModel.showExternalNotes,
                        onPrivateNoteToggle: { viewModel.toggleIsPrivateNote() },
                        onAddNote: { noteText in
                            Task { await viewModel.addExternalNote(noteText) }
                        },
                        onDeleteNote: { note in
                            Task { await viewModel.deleteExternalNote(note) }
                        },
                        onTogglePollingNotes: { viewModel.togglePollingNotesExpanded() },
                        onToggleExternalNotes: { viewModel.toggleExternalNotesExpanded() },
                        onToggleWatchlist: { viewModel.toggleCandidateWatchlist($0) }
                    )
                )
            }
        } else {
            return AnyView(EmptyView())
        }
    }
}

// CandidateCard removed; now all candidates are on a single card

struct CandidateDetailView: View {
    let candidate: Candidate
    let pollingNotes: [PollingNote]
    let externalNotes: [ExternalNote]
    let pollingGroups: [PollingGroup]
    let candidateImages: [CandidateImage]
    let isPrivateNote: Bool
    let showPollingNotes: Bool
    let showExternalNotes: Bool
    let onPrivateNoteToggle: () -> Void
    let onAddNote: (String) -> Void
    let onDeleteNote: (ExternalNote) -> Void
    let onTogglePollingNotes: () -> Void
    let onToggleExternalNotes: () -> Void
    let onToggleWatchlist: (Candidate) -> Void
    
    @State private var selectedImage: CandidateImage?
    @State private var showingFullScreenImage = false
    @State private var shouldPresentSheet = false
    @State private var expandedPolls: Set<String> = []
    @State private var localNoteText: String = ""
    
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
        .background(Color.appBackground)
        .sheet(isPresented: $shouldPresentSheet) {
            if let selectedImage = selectedImage {
                FullScreenImageView(image: selectedImage)
            }
        }
        .onChange(of: shouldPresentSheet) { newValue in
            if !newValue {
                // Sheet was dismissed, reset the selected image
                selectedImage = nil
            }
        }
        .onAppear {
            // Expand the most recent poll by default
            if let mostRecent = sortedPollTitles.first {
                expandedPolls = [mostRecent]
            }
            // Initialize local note text with parent value
            // localNoteText = newNoteText // Removed
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
            
            // No Notes Message
            if pollingNotes.isEmpty && externalNotes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "note.text")
                        .font(.system(size: 50))
                        .foregroundColor(.appGold)
                    Text("No Notes Available")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("No notes have been submitted for this candidate yet.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
            }
            
            // Add Note Section
            addNoteSection
        }
    }
    
    private var pollingNotesSection: some View {
        VStack(spacing: 16) {
            ForEach(sortedPollTitles, id: \.self) { pollTitle in
                let notesForPoll = groupedPollingNotes[pollTitle] ?? []
                let validNotes = notesForPoll.filter { note in
                    let noteText = note.note ?? ""
                    return !noteText.isEmpty && noteText != "No note content"
                }
                
                if !validNotes.isEmpty {
                    notesSection(
                        title: pollTitle,
                        isExpanded: Binding(
                            get: { expandedPolls.contains(pollTitle) },
                            set: { expanded in
                                if expanded { expandedPolls.insert(pollTitle) } else { expandedPolls.remove(pollTitle) }
                            }
                        ),
                        notes: validNotes.map { note in
                            NoteItem(
                                text: note.note ?? "",
                                author: note.name,
                                timestamp: note.createdAt,
                                pollTitle: note.pollingName
                            )
                        }
                    )
                }
            }
        }
    }
    
    private var externalNotesSection: some View {
        Group {
            if !externalNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Non Polling Notes (\(externalNotes.count))")
                        .font(.headline)
                        .foregroundColor(.appText)
                    ForEach(externalNotes) { note in
                        let currentUserId = KeychainService.shared.getUserData()?.id
                        let canDelete = note.pollingOrderMemberId.id == currentUserId
                        ExternalNoteCard(
                            note: note,
                            onDelete: { onDeleteNote(note) },
                            canDelete: canDelete
                        )
                    }
                }
                .padding(20)
                .background(Color.appCardBackground)
                .cornerRadius(16)
            } else {
                EmptyView()
            }
        }
    }
    
    private var addNoteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Note")
                .font(.headline)
                .foregroundColor(.appText)
            
            TextField("Enter your note...", text: $localNoteText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white)
                .cornerRadius(8)
            
            Button(action: {
                onAddNote(localNoteText)
                localNoteText = ""
            }) {
                Text("Add Note")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(localNoteText.isEmpty)
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
                        VStack(spacing: 8) {
                            AsyncImage(url: URL(string: image.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    VStack {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                            .background(Color.gray.opacity(0.3))
                                            .cornerRadius(8)
                                        Text("Loading...")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                case .failure:
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                            .frame(width: 100, height: 100)
                                            .background(Color.gray.opacity(0.3))
                                            .cornerRadius(8)
                                        Text("Failed to load")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .onTapGesture {
                                print("🖼️ Image tapped: \(image.imageUrl)")
                                selectedImage = image
                                shouldPresentSheet = true
                            }
                            .onAppear {
                                print("🖼️ Attempting to load image: \(image.imageUrl)")
                            }
                            
                            // Image Description
                            // Only use plainDescription for image descriptions that may contain HTML from external sources
                            if !image.imageDescription.isEmpty {
                                Text(image.plainDescription)
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 100)
                                    .lineLimit(3)
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
    
    private var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: note.createdAt) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        } else {
            // Try without fractional seconds
            let simpleFormatter = ISO8601DateFormatter()
            if let date = simpleFormatter.date(from: note.createdAt) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            } else {
                return note.createdAt
            }
        }
    }
    
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
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
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
    let canDelete: Bool
    
    private var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: note.timestamp) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        } else {
            // Try without fractional seconds
            let simpleFormatter = ISO8601DateFormatter()
            if let date = simpleFormatter.date(from: note.timestamp) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            } else {
                return note.timestamp
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.pollingOrderMemberId.name)
                    .font(.headline)
                Spacer()
                if canDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            Text(note.text)
                .font(.body)
                .foregroundColor(.appText)
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.appCardBackground)
        .cornerRadius(8)
    }
}

struct FullScreenImageView: View {
    let image: CandidateImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                
                Spacer()
            }
            
            Spacer()
            
            AsyncImage(url: URL(string: image.imageUrl)) { phase in
                switch phase {
                case .empty:
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading image...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                case .failure(let error):
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Failed to load image")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            
            Spacer()
        }
        .background(Color.black)
        .onAppear {
            print("🖼️ FullScreen: View appeared for image: \(image.imageUrl)")
        }
    }
}

// Helper function to clean HTML text
private func cleanHtmlText(_ htmlString: String) -> String {
    let data = Data(htmlString.utf8)
    if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
        return attributedString.string
    }
    return htmlString
}

// Helper functions for polling notes grouping
extension CandidateDetailView {
    var groupedPollingNotes: [String: [PollingNote]] {
        let validNotes = pollingNotes.filter { note in
            let noteText = note.note ?? ""
            return !noteText.isEmpty && noteText != "No note content"
        }
        return Dictionary(grouping: validNotes) { $0.pollingName }
    }
    
    var sortedPollTitles: [String] {
        groupedPollingNotes.keys.sorted { lhs, rhs in
            let lhsDate = groupedPollingNotes[lhs]?.first?.endDate ?? groupedPollingNotes[lhs]?.first?.startDate ?? ""
            let rhsDate = groupedPollingNotes[rhs]?.first?.endDate ?? groupedPollingNotes[rhs]?.first?.startDate ?? ""
            return lhsDate > rhsDate
        }
    }
    
    func notesSection(title: String, isExpanded: Binding<Bool>, notes: [NoteItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.wrappedValue.toggle() }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.appText)
                    Spacer()
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .foregroundColor(.appText)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded.wrappedValue {
                VStack(spacing: 8) {
                    ForEach(notes, id: \.id) { note in
                        CandidateNoteCard(note: note)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
}



#Preview {
    CandidatesView()
} 
