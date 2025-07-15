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
                        newNoteText: viewModel.newNoteText,
                        isPrivateNote: viewModel.isPrivateNote,
                        showPollingNotes: viewModel.showPollingNotes,
                        showExternalNotes: viewModel.showExternalNotes,
                        onNewNoteTextChange: { viewModel.updateNewNoteText($0) },
                        onPrivateNoteToggle: { viewModel.toggleIsPrivateNote() },
                        onAddNote: {
                            Task { await viewModel.addExternalNote() }
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
    
    @State private var selectedImage: CandidateImage?
    @State private var showingFullScreenImage = false
    
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
        .sheet(isPresented: $showingFullScreenImage) {
            if let selectedImage = selectedImage {
                FullScreenImageView(image: selectedImage)
            }
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingFullScreenImage = true
                            }
                        }
                        .onAppear {
                            print("🖼️ Attempting to load image: \(image.imageUrl)")
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

struct FullScreenImageView: View {
    let image: CandidateImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            print("🖼️ FullScreen: View appeared for image: \(image.imageUrl)")
        }
    }
}

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
                    imageUrl: imageUrl
                )
            }
            
            // Reset UI state for new candidate
            newNoteText = ""
            isPrivateNote = false
            showPollingNotes = false
            showExternalNotes = false
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
    
    func addExternalNote() async {
        guard !newNoteText.isEmpty else { return }
        
        guard let selectedCandidate = selectedCandidate else {
            errorMessage = "No candidate selected"
            return
        }
        
        do {
            try await apiService.createExternalNote(candidateId: selectedCandidate.id, note: newNoteText)
            
            // Reload external notes to get the updated list
            let updatedNotes = try await apiService.getExternalNoteByCandidateId(candidateId: selectedCandidate.id)
            externalNotes = updatedNotes
            
            newNoteText = ""
            isPrivateNote = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteExternalNote(_ note: ExternalNote) async {
        do {
            try await apiService.removeExternalNote(externalNoteId: note.id)
            
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

#Preview {
    CandidatesView()
} 