//
//  PollingView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

struct PollingView: View {
    @StateObject private var viewModel = PollingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Loading polling data...")
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
                                await viewModel.loadCurrentPollingData()
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
                } else if viewModel.currentPolling == nil {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 50))
                            .foregroundColor(.appGold)
                        
                        Text("No Active Pollings Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("There are currently no active polling sessions for your order. You can review the most recent closed polling by going to the Report screen.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        NavigationLink(destination: ReportView()) {
                            HStack {
                                Image(systemName: "chart.bar.doc.horizontal")
                                Text("View Reports")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.appGold)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    // Active polling content
                    ActivePollingView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("\(viewModel.pollingOrderName) Polling")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadCurrentPollingData()
            }
        }
    }
}

struct ActivePollingView: View {
    @ObservedObject var viewModel: PollingViewModel
    @State private var selectedMember: PollingMember?
    @State private var showingMemberSelector = false
    @State private var isSubmitting = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Polling Header
                if let polling = viewModel.currentPolling {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(polling.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Polling Dates: \(formatDate(polling.startDate)) thru \(formatDate(polling.endDate))")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                }
                
                // Member Selection
                VStack(spacing: 12) {
                    HStack {
                        Text("Voting as:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Button(selectedMember?.name ?? "Vote as Self") {
                            showingMemberSelector = true
                        }
                        .foregroundColor(.appGold)
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Candidates List
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.candidateVotes) { vote in
                        CandidateVoteCard(
                            vote: vote,
                            onVoteChanged: { newVote in
                                viewModel.updateVote(for: vote.candidateId, vote: newVote)
                            },
                            onNoteChanged: { newNote in
                                viewModel.updateNote(for: vote.candidateId, note: newNote)
                            },
                            onPrivateChanged: { isPrivate in
                                viewModel.updatePrivate(for: vote.candidateId, isPrivate: isPrivate)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Submit Buttons
                VStack(spacing: 12) {
                    Button("Submit as Draft") {
                        Task {
                            await viewModel.submitVote()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.appSecondary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(isSubmitting)
                    
                    Button("Submit Completed Votes") {
                        Task {
                            await viewModel.submitVote()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.appSuccess)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(isSubmitting)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingMemberSelector) {
            MemberSelectorView(
                members: viewModel.orderMembers,
                selectedMember: $selectedMember,
                onMemberSelected: { member in
                    selectedMember = member
                    viewModel.selectMember(member?.id ?? -1)
                    showingMemberSelector = false
                }
            )
        }
        .overlay(
            Group {
                if isSubmitting {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Submitting votes...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
        )
        .alert("Success", isPresented: $showSuccessMessage) {
            Button("OK") { }
        } message: {
            Text("Your votes have been submitted successfully.")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct CandidateVoteCard: View {
    let vote: CandidateVote
    let onVoteChanged: (Int?) -> Void
    let onNoteChanged: (String) -> Void
    let onPrivateChanged: (Bool) -> Void
    
    @State private var note: String
    @State private var isPrivate: Bool
    @State private var selectedVote: Int?
    @State private var showingNotesModal = false
    
    init(vote: CandidateVote, onVoteChanged: @escaping (Int?) -> Void, onNoteChanged: @escaping (String) -> Void, onPrivateChanged: @escaping (Bool) -> Void) {
        self.vote = vote
        self.onVoteChanged = onVoteChanged
        self.onNoteChanged = onNoteChanged
        self.onPrivateChanged = onPrivateChanged
        self._note = State(initialValue: vote.note)
        self._isPrivate = State(initialValue: vote.isPrivate)
        self._selectedVote = State(initialValue: vote.vote)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Candidate Name
            Text(vote.candidateName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Vote Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Vote:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 12) {
                    VoteButton(title: "Yes", value: 1, isSelected: selectedVote == 1) {
                        selectedVote = selectedVote == 1 ? nil : 1
                        onVoteChanged(selectedVote)
                    }
                    VoteButton(title: "Wait", value: 2, isSelected: selectedVote == 2) {
                        selectedVote = selectedVote == 2 ? nil : 2
                        onVoteChanged(selectedVote)
                    }
                    VoteButton(title: "No", value: 3, isSelected: selectedVote == 3) {
                        selectedVote = selectedVote == 3 ? nil : 3
                        onVoteChanged(selectedVote)
                    }
                    VoteButton(title: "Abstain", value: 4, isSelected: selectedVote == 4) {
                        selectedVote = selectedVote == 4 ? nil : 4
                        onVoteChanged(selectedVote)
                    }
                }
            }
            
            // Note Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Notes:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Button("View All Notes") {
                        showingNotesModal = true
                    }
                    .font(.caption)
                    .foregroundColor(.appGold)
                    
                    Toggle("Private", isOn: $isPrivate)
                        .toggleStyle(SwitchToggleStyle(tint: .appGold))
                        .onChange(of: isPrivate) { _, newValue in
                            onPrivateChanged(newValue)
                        }
                }
                
                TextField("Add your notes here...", text: $note, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: note) { _, newValue in
                        onNoteChanged(newValue)
                    }
                    .lineLimit(3...6)
            }
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .sheet(isPresented: $showingNotesModal) {
            CandidateNotesModal(candidateId: vote.candidateId, candidateName: vote.candidateName)
        }
    }
}

struct VoteButton: View {
    let title: String
    let value: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appGold : Color.appSecondary)
                .foregroundColor(.white)
                .cornerRadius(6)
        }
    }
}

struct MemberSelectorView: View {
    let members: [PollingMember]
    @Binding var selectedMember: PollingMember?
    let onMemberSelected: (PollingMember?) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section("Vote as Self") {
                    Button("Vote as Self") {
                        onMemberSelected(nil)
                    }
                    .foregroundColor(.primary)
                }
                
                Section("Vote as Proxy") {
                    ForEach(members) { member in
                        Button(member.name) {
                            onMemberSelected(member)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Select Member")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CandidateNotesModal: View {
    let candidateId: Int
    let candidateName: String
    @State private var pollingNotes: [PollingNote] = []
    @State private var externalNotes: [ExternalNote] = []
    @State private var showExternalNotes = true
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var expandedPolls: Set<String> = [] // Track expanded poll titles
    
    private let apiService = APIService.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.white)
                    Text("Loading notes...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error loading notes")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Polling Notes Section
                            if !pollingNotes.isEmpty {
                                ForEach(sortedPollTitles, id: \.self) { pollTitle in
                                    let notesForPoll = groupedPollingNotes[pollTitle] ?? []
                                    notesSection(
                                        title: pollTitle,
                                        isExpanded: Binding(
                                            get: { expandedPolls.contains(pollTitle) },
                                            set: { expanded in
                                                if expanded { expandedPolls.insert(pollTitle) } else { expandedPolls.remove(pollTitle) }
                                            }
                                        ),
                                        notes: notesForPoll.map { note in
                                            NoteItem(
                                                text: note.note ?? "No note content",
                                                author: note.name,
                                                timestamp: note.createdAt,
                                                pollTitle: note.pollingName
                                            )
                                        }
                                    )
                                }
                            }
                            // External Notes Section
                            if !externalNotes.isEmpty {
                                notesSection(
                                    title: "External Notes (\(externalNotes.count))",
                                    isExpanded: $showExternalNotes,
                                    notes: externalNotes.map { note in
                                        NoteItem(
                                            text: note.text,
                                            author: note.pollingOrderMemberId.name,
                                            timestamp: note.timestamp,
                                            pollTitle: nil
                                        )
                                    }
                                )
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("\(candidateName) - Notes")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadNotes()
            }
        }
    }
    
    private func notesSection(title: String, isExpanded: Binding<Bool>, notes: [NoteItem]) -> some View {
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
    
    private func loadNotes() async {
        isLoading = true
        errorMessage = nil
        do {
            async let pollingNotesTask = apiService.getPollingNoteByCandidateId(candidateId: candidateId)
            async let externalNotesTask = apiService.getExternalNoteByCandidateId(candidateId: candidateId)
            let (polling, external) = try await (pollingNotesTask, externalNotesTask)
            pollingNotes = polling
            externalNotes = external
            // Expand the most recent poll by default
            if let mostRecent = sortedPollTitles.first {
                expandedPolls = [mostRecent]
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    // Group polling notes by pollingName
    private var groupedPollingNotes: [String: [PollingNote]] {
        Dictionary(grouping: pollingNotes) { $0.pollingName }
    }
    // Sort poll titles by most recent poll (using endDate desc, fallback to startDate)
    private var sortedPollTitles: [String] {
        groupedPollingNotes.keys.sorted { lhs, rhs in
            let lhsDate = groupedPollingNotes[lhs]?.first?.endDate ?? groupedPollingNotes[lhs]?.first?.startDate ?? ""
            let rhsDate = groupedPollingNotes[rhs]?.first?.endDate ?? groupedPollingNotes[rhs]?.first?.startDate ?? ""
            return lhsDate > rhsDate
        }
    }
}

struct CandidateNoteCard: View {
    let note: NoteItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.text)
                .font(.body)
                .foregroundColor(.appText)
            HStack {
                Text(note.author)
                    .font(.caption)
                    .foregroundColor(.appGold)
                Spacer()
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
        }
        .padding(12)
        .background(Color.appCardBackground.opacity(0.5))
        .cornerRadius(8)
    }
}

@MainActor
class PollingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var pollingList: [Polling] = []
    @Published var errorMessage: String?
    @Published var currentPolling: Polling?
    @Published var pollingOrderName: String = ""
    @Published var candidateVotes: [CandidateVote] = []
    @Published var orderMembers: [PollingMember] = []
    @Published var selectedMember: PollingMember?
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    func loadCurrentPollingData() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let currentUser = keychainService.getUserData() else {
                errorMessage = "User data not found. Please log in again."
                isLoading = false
                return
            }
            guard let pollingOrderId = currentUser.pollingOrderId else {
                errorMessage = "Polling order ID not found. Please contact support."
                isLoading = false
                return
            }
            currentPolling = try await apiService.getCurrentPolling(orderId: pollingOrderId)
            if let polling = currentPolling {
                let allMembers = try await apiService.getAllMembers(orderId: pollingOrderId)
                orderMembers = allMembers.filter { $0.active && $0.approved && !$0.removed }
                let memberId = selectedMember?.id.description ?? currentUser.id.description
                let summaries = try await apiService.getPollingSummary(pollingId: polling.id, memberId: memberId)
                candidateVotes = summaries.map { summary in
                    CandidateVote(
                        candidateId: summary.candidateId,
                        candidateName: summary.name,
                        note: summary.note ?? "",
                        vote: summary.vote,
                        isPrivate: summary.isPrivate ?? false,
                        pollingNotesId: (summary.pollingNotesId != nil && summary.pollingNotesId != 0) ? summary.pollingNotesId : nil,
                        completed: summary.completed
                    )
                }
            }
            // If currentPolling is nil, it means no active polling - this is handled in the UI
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func selectMember(_ memberId: Int) {
        if memberId == -1 {
            selectedMember = nil
        } else {
            selectedMember = orderMembers.first { $0.id == memberId }
        }
        Task { await loadCurrentPollingData() }
    }
    
    func updateVote(for candidateId: Int, vote: Int?) {
        if let index = candidateVotes.firstIndex(where: { $0.candidateId == candidateId }) {
            candidateVotes[index].vote = vote
        }
    }
    func updateNote(for candidateId: Int, note: String) {
        if let index = candidateVotes.firstIndex(where: { $0.candidateId == candidateId }) {
            candidateVotes[index].note = note
        }
    }
    func updatePrivate(for candidateId: Int, isPrivate: Bool) {
        if let index = candidateVotes.firstIndex(where: { $0.candidateId == candidateId }) {
            candidateVotes[index].isPrivate = isPrivate
        }
    }
    func submitVote() async {
        isLoading = true
        defer { isLoading = false }
        guard let currentUser = keychainService.getUserData(), let polling = currentPolling else { return }
        let memberId = selectedMember?.id ?? currentUser.id
        let now = ISO8601DateFormatter().string(from: Date())
        let noteRequests = candidateVotes.map { vote in
            PollingNoteRequest(
                pollingId: polling.id,
                pollingName: polling.name,
                startDate: polling.startDate,
                endDate: polling.endDate,
                pollingOrderId: polling.pollingOrderId,
                candidateId: vote.candidateId,
                pollingCandidateId: vote.pollingNotesId, // Use correct field if available
                name: vote.candidateName,
                link: "", // No link in CandidateVote, use empty string
                watchList: false, // No watchList in CandidateVote, use false
                pollingNotesId: vote.pollingNotesId,
                note: vote.note,
                vote: vote.vote,
                pnCreatedAt: nil, // Set if available
                pollingOrderMemberId: memberId,
                completed: vote.completed,
                isPrivate: vote.isPrivate,
                authToken: (memberId == currentUser.id) ? keychainService.getAuthToken() : nil
            )
        }
        // Log the payload as JSON
        if let jsonData = try? JSONEncoder().encode(noteRequests),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Submitting PollingNoteRequest payload:\n\(jsonString)")
        } else {
            print("Failed to encode PollingNoteRequest payload.")
        }
        do {
            let success = try await apiService.createPollingNotes(notes: noteRequests)
            if !success { errorMessage = "Failed to submit votes. Please try again." }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    func loadPollingData() async { await loadCurrentPollingData() }
}

#Preview {
    PollingView()
} 