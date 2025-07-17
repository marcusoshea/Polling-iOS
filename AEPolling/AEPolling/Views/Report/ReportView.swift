//
//  ReportView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI
import Charts

struct ReportView: View {
    let cardWidth: CGFloat
    @StateObject private var viewModel = ReportViewModel()
    @State private var expandedCandidates: [Int: Bool] = [:] // Track expansion state per candidate
    
    var body: some View {
        NavigationView {
            VStack {
                contentView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadInitialReportData()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(errorMessage)
        } else {
            reportScrollView
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                Text("Loading report data...")
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
                        await viewModel.loadInitialReportData()
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
    
    private var reportScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Toggle and report info at the top
                if viewModel.inProcessAvailable && viewModel.closedAvailable {
                    Picker("Report Type", selection: $viewModel.showingInProcess) {
                        Text("In-Process").tag(true)
                        Text("Closed").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.showingInProcess) { newValue in
                        Task { await viewModel.toggleReport(to: newValue) }
                    }
                } else if viewModel.inProcessAvailable {
                    Text("In-Process Report")
                        .font(.headline)
                        .foregroundColor(.appPrimary)
                } else if viewModel.closedAvailable {
                    Text("Closed Report")
                        .font(.headline)
                        .foregroundColor(.appPrimary)
                }
                // Polling name and dates
                if let report = viewModel.pollingReport {
                    VStack(spacing: 4) {
                        let formattedStart = formatDate(report.start_date)
                        let formattedEnd = formatDate(report.end_date)
                        if viewModel.showingInProcess {
                            Text("This in process report for the \(report.polling_order_name) for \(report.polling_name) will run from \(formattedStart) to \(formattedEnd)")
                                .font(.subheadline)
                                .foregroundColor(.appText)
                        } else {
                            Text("This report for the \(report.polling_order_name) for \(report.polling_name) ran from \(formattedStart) to \(formattedEnd)")
                                .font(.subheadline)
                                .foregroundColor(.appText)
                        }
                    }
                    .padding(16)
                    .background(Color.appCardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                HStack {
                    Spacer()
                    LazyVStack(spacing: 24) {
                        Text("Polling Candidate List:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                            .padding(.horizontal, 20)
                        ForEach(viewModel.candidateReports.sorted(by: { $0.percentage > $1.percentage })) { candidateVM in
                            CandidateReportCard(
                                candidateVM: candidateVM,
                                notesExpanded: Binding(
                                    get: { expandedCandidates[candidateVM.id] ?? false },
                                    set: { expandedCandidates[candidateVM.id] = $0 }
                                )
                            )
                        }
                    }
                    .frame(width: 360)
                    Spacer()
                }
            }
            .padding(.vertical, 16)
        }
    }
}

private func formatDate(_ isoString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = isoFormatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    return isoString
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.appText.opacity(0.8))
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
}

struct ActivityRow: View {
    let activity: PollingNote
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activityIcon)
                .font(.subheadline)
                .foregroundColor(activityColor)
                .frame(width: 24, height: 24)
                .background(activityColor.opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.note ?? "(No note)")
                    .font(.subheadline)
                    .foregroundColor(.appText)
                Text(activity.member_name ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.appText.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var activityIcon: String {
        return "note.text" // Assuming PollingNote is a type of activity
    }
    
    private var activityColor: Color {
        return .appSecondary // Assuming PollingNote is a type of activity
    }
}

@MainActor
class ReportViewModel: ObservableObject {
    @Published var totalVotes = 0
    @Published var candidateCount = 0
    @Published var positiveVotes = 0
    @Published var negativeVotes = 0
    @Published var recentNotes: [PollingNote] = []
    @Published var chartData: [VoteData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var activeMembers: String = ""
    @Published var memberParticipation: String = ""
    @Published var pollingReport: PollingReport?
    @Published var inProcessAvailable: Bool = false
    @Published var closedAvailable: Bool = false
    @Published var showingInProcess: Bool = false // default to false, will set to true if in-process exists
    @Published var candidateReports: [CandidateReportViewModel] = []

    private let apiService = APIService.shared

    func loadInitialReportData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        guard let user = KeychainService.shared.getUserData(), let orderId = user.pollingOrderId else {
            errorMessage = "No user or polling order found. Please log in again."
            return
        }
        var inProcessReport: PollingReportResponse? = nil
        var closedReport: PollingReportResponse? = nil
        var inProcessError: Error? = nil
        var closedError: Error? = nil
        // Try in-process report first
        print("[ReportViewModel] Requesting in-process report for orderId: \(orderId)")
        do {
            inProcessReport = try await apiService.getPollingReportResponse(orderId: orderId, inProcess: true)
            inProcessAvailable = inProcessReport != nil
            print("[ReportViewModel] In-process report available: \(inProcessAvailable)")
        } catch {
            inProcessAvailable = false
            inProcessError = error
            print("[ReportViewModel] In-process report error: \(error.localizedDescription)")
        }
        // If no in-process, try closed report
        if !inProcessAvailable {
            print("[ReportViewModel] Requesting closed report for orderId: \(orderId)")
            do {
                closedReport = try await apiService.getPollingReportResponse(orderId: orderId, inProcess: false)
                closedAvailable = closedReport != nil
                print("[ReportViewModel] Closed report available: \(closedAvailable)")
            } catch {
                closedAvailable = false
                closedError = error
                print("[ReportViewModel] Closed report error: \(error.localizedDescription)")
            }
        }
        // Show whichever is available
        if inProcessAvailable, let report = inProcessReport {
            showingInProcess = true
            await setReportData(from: report, orderId: orderId, inProcess: true)
        } else if closedAvailable, let report = closedReport {
            showingInProcess = false
            await setReportData(from: report, orderId: orderId, inProcess: false)
        } else {
            print("[ReportViewModel] No report data available for orderId: \(orderId)")
            errorMessage = inProcessError?.localizedDescription ?? closedError?.localizedDescription ?? "No report data available."
        }
    }

    func setReportData(from reportResponse: PollingReportResponse?, orderId: Int, inProcess: Bool) async {
        guard let report = reportResponse?.report else { return }
        pollingReport = report
        activeMembers = reportResponse?.activeMembers ?? ""
        memberParticipation = reportResponse?.memberParticipation ?? ""
        totalVotes = Int(memberParticipation) ?? 0
        candidateCount = Int(activeMembers) ?? 0
        do {
            // Fetch all candidates for the order
            let allCandidates = try await apiService.getAllCandidates(orderId: report.polling_order_id)
            print("📊 [ReportViewModel] Found \(allCandidates.count) total candidates")
            var candidateVMs: [CandidateReportViewModel] = []
            for candidate in allCandidates {
                // Fetch all notes for this candidate
                let pollingNotes = try await apiService.getPollingNoteByCandidateId(candidateId: candidate.id)
                // Filter notes for this polling
                let notesForPolling = pollingNotes.filter { $0.pollingId == report.polling_id }
                

                
                // Add candidate if they have any notes for this polling (including null notes)
                if !notesForPolling.isEmpty {
                    let vm = CandidateReportViewModel(candidate: candidate, pollingNotes: notesForPolling, report: report)
                    candidateVMs.append(vm)
                }
            }
            print("📊 [ReportViewModel] Created \(candidateVMs.count) candidate VMs with notes")
            self.candidateReports = candidateVMs
        } catch {
            print("Failed to fetch candidates or notes: \(error)")
            self.candidateReports = []
        }
    }

    func toggleReport(to inProcess: Bool) async {
        guard let user = KeychainService.shared.getUserData(), let orderId = user.pollingOrderId else {
            errorMessage = "No user or polling order found. Please log in again."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            showingInProcess = inProcess
            let report = try await apiService.getPollingReportResponse(orderId: orderId, inProcess: inProcess)
            await setReportData(from: report, orderId: orderId, inProcess: inProcess)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct CandidateReportViewModel: Identifiable {
    let id: Int
    let name: String
    let candidate: Candidate
    let pollingNotes: [PollingNote]
    let recommended: String
    let yesCount: Int
    let noCount: Int
    let waitCount: Int
    let abstainCount: Int
    let percentage: Double
    let hasNotes: Bool
    let showRecommendation: Bool
    init(candidate: Candidate, pollingNotes: [PollingNote], report: PollingReport) {
        self.id = candidate.id
        self.name = candidate.name
        self.candidate = candidate
        // Only include polling notes for the current polling session
        self.pollingNotes = pollingNotes.filter { $0.pollingId == report.polling_id }
        // Calculate vote counts
        self.yesCount = self.pollingNotes.filter { $0.vote == 1 }.count
        self.noCount = self.pollingNotes.filter { $0.vote == 2 }.count
        self.waitCount = self.pollingNotes.filter { $0.vote == 3 }.count
        self.abstainCount = self.pollingNotes.filter { $0.vote == 4 }.count
        // Percentage calculation: (Yes / (Yes + No + Wait)) * 100, Abstain not included in denominator
        let denominator = yesCount + noCount + waitCount
        self.percentage = denominator > 0 ? (Double(yesCount) / Double(denominator)) * 100.0 : 0.0
        // Recommendation logic (threshold from report.polling_order_polling_score)
        let threshold = Double(report.polling_order_polling_score)
        if threshold == 0 {
            self.recommended = ""
            self.showRecommendation = false
        } else if percentage >= threshold {
            self.recommended = "has been recommended to join the order with a rating of:"
            self.showRecommendation = true
        } else {
            self.recommended = "has NOT been recommended to join the order with a rating of:"
            self.showRecommendation = true
        }
        self.hasNotes = !self.pollingNotes.isEmpty
    }
}

@MainActor
class OrderPickerViewModel: ObservableObject {
    @Published var orders: [PollingOrder] = []
    
    private let apiService = APIService.shared
    
    func loadOrders() async {
        // Mock data for now
        orders = [
            PollingOrder(id: 1234, name: "Spring Elections 2024", adminId: 1, adminAssistantId: 2, notesTimeVisible: 24),
            PollingOrder(id: 1235, name: "Officer Nominations", adminId: 1, adminAssistantId: 2, notesTimeVisible: 24)
        ]
    }
}

struct CandidateReportCard: View {
    let candidateVM: CandidateReportViewModel
    @Binding var notesExpanded: Bool
    var filteredNotes: [PollingNote] {
        let filtered = candidateVM.pollingNotes.filter { note in
            if let text = note.note {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && trimmed.lowercased() != "no note content"
            }
            return false
        }
        return filtered
    }
    private var voteBreakdownText: String {
        var parts: [String] = []
        if candidateVM.yesCount > 0 { parts.append("Yes: \(candidateVM.yesCount)") }
        if candidateVM.noCount > 0 { parts.append("No: \(candidateVM.noCount)") }
        if candidateVM.waitCount > 0 { parts.append("Wait: \(candidateVM.waitCount)") }
        if candidateVM.abstainCount > 0 { parts.append("Abstain: \(candidateVM.abstainCount)") }
        let joined = parts.joined(separator: ", ")
        return "( \(joined) ) = \(String(format: "%.2f", candidateVM.percentage))%"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(candidateVM.name)
                .font(.headline)
                .foregroundColor(.appPrimary)
            if candidateVM.showRecommendation {
                Text(candidateVM.recommended)
                    .font(.subheadline)
                    .foregroundColor(.appText)
            }
            Text(voteBreakdownText)
                .font(.caption)
                .foregroundColor(.appText.opacity(0.8))
            
            // Always show notes section for candidates with any notes
            if !candidateVM.pollingNotes.isEmpty {
                DisclosureGroup(isExpanded: $notesExpanded) {
                    if !filteredNotes.isEmpty {
                        ForEach(filteredNotes, id: \.id) { note in
                            NoteCard(note: note)
                        }
                    } else {
                        Text("No notes available for this candidate.")
                            .font(.subheadline)
                            .foregroundColor(.appText.opacity(0.7))
                            .padding(.vertical, 8)
                    }
                } label: {
                    Text("Notes")
                        .font(.subheadline)
                        .foregroundColor(.appText)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    GeometryReader { geometry in
        ReportView(cardWidth: geometry.size.width * 0.96)
    }
} 