//
//  ReportView.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI
import Charts

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var selectedOrder: PollingOrder?
    @State private var showingOrderPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                contentView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingOrderPicker) {
                OrderPickerView(selectedOrder: $selectedOrder, orders: viewModel.pollingOrders)
            }
            .onChange(of: selectedOrder) {
                if let order = selectedOrder {
                    Task {
                        await viewModel.loadReportData(for: order.id)
                    }
                }
            }
            .task {
                await viewModel.loadReportData()
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
                        await viewModel.loadReportData()
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
            VStack(spacing: 20) {
                // Order Selection Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Polling Order")
                        .font(.headline)
                        .foregroundColor(.appText)
                    Button(action: {
                        showingOrderPicker = true
                    }) {
                        HStack {
                            Text(selectedOrder?.name ?? "Choose a polling order")
                                .foregroundColor(selectedOrder == nil ? .appText.opacity(0.6) : .appText)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.appText.opacity(0.6))
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.appBackground)
                        .cornerRadius(8)
                    }
                }
                .padding(20)
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                // Summary Cards
                if viewModel.pollingSummary != nil {
                    VStack(spacing: 16) {
                        SummaryCard(
                            title: "Total Polling",
                            value: "\(viewModel.totalVotes)",
                            icon: "list.clipboard",
                            color: .appPrimary
                        )
                        SummaryCard(
                            title: "Completed",
                            value: "\(viewModel.positiveVotes)",
                            icon: "checkmark.circle",
                            color: .appSuccess
                        )
                        SummaryCard(
                            title: "Pending",
                            value: "\(viewModel.negativeVotes)",
                            icon: "clock",
                            color: .appGold
                        )
                        SummaryCard(
                            title: "Candidates",
                            value: "\(viewModel.candidateCount)",
                            icon: "person.3",
                            color: .appSecondary
                        )
                    }
                    .padding(.horizontal, 20)
                }
                // Recent Activity Card
                if !viewModel.recentActivity.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(.appText)
                            .padding(.horizontal, 20)
                        VStack(spacing: 0) {
                            ForEach(viewModel.recentActivity.prefix(5), id: \ .id) { activity in
                                ActivityRow(activity: activity)
                                if activity.id != viewModel.recentActivity.prefix(5).last?.id {
                                    Divider()
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .background(Color.appCardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 16)
        }
    }
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
    let activity: PollingActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activityIcon)
                .font(.subheadline)
                .foregroundColor(activityColor)
                .frame(width: 24, height: 24)
                .background(activityColor.opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.appText)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.appText.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var activityIcon: String {
        switch activity.type {
        case "polling_created":
            return "plus.circle"
        case "polling_completed":
            return "checkmark.circle"
        case "score_updated":
            return "chart.bar"
        default:
            return "circle"
        }
    }
    
    private var activityColor: Color {
        switch activity.type {
        case "polling_created":
            return .appPrimary
        case "polling_completed":
            return .appSuccess
        case "score_updated":
            return .appSecondary
        default:
            return .appText
        }
    }
}

struct OrderPickerView: View {
    @Binding var selectedOrder: PollingOrder?
    let orders: [PollingOrder]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(orders) { order in
                Button(action: {
                    selectedOrder = order
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.name)
                                .font(.headline)
                                .foregroundColor(.appText)
                            
                            Text("Order #\(order.id)")
                                .font(.subheadline)
                                .foregroundColor(.appText.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        if selectedOrder?.id == order.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.appGold)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.appGold)
                }
            }
        }
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
    @Published var pollingSummary: PollingSummary?
    @Published var recentActivity: [PollingActivity] = []
    @Published var pollingOrders: [PollingOrder] = []
    
    private let apiService = APIService.shared
    
    func loadReport(for orderId: Int) async {
        // Mock data for now
        totalVotes = 150
        candidateCount = 5
        positiveVotes = 85
        negativeVotes = 45
        
        chartData = [
            VoteData(category: "Positive", count: positiveVotes),
            VoteData(category: "Negative", count: negativeVotes),
            VoteData(category: "Neutral", count: totalVotes - positiveVotes - negativeVotes)
        ]
        
        // Mock data for recent notes - using the new PollingNote structure
        // Note: This is mock data since the actual structure is complex
        // In a real scenario, these would come from the API
        recentNotes = []
    }
    
    func loadReportData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            // Use getPollingReport for summary and activities
            // For now, use the first available order or a default
            let orderId = pollingOrders.first?.id ?? 1
            let reports = try await apiService.getPollingReport(orderId: orderId)
            
            // Get the first report from the array
            guard let report = reports.first else {
                errorMessage = "No report data available"
                return
            }
            
            // Assume PollingReportSummary is used for summary cards
            let summary = report.summary
            // Map summary to local properties or a new struct if needed
            pollingSummary = nil // Set to nil or map as needed
            // For now, set recentActivity to empty or map from notes
            recentActivity = []
            pollingOrders = try await apiService.fetchPollingOrders()
            // Load report data
            await loadReport(for: orderId)
            // Update view model (mock data)
            totalVotes = summary.totalVotes
            candidateCount = report.candidates.count
            positiveVotes = summary.positiveVotes
            negativeVotes = summary.negativeVotes
            chartData = [
                VoteData(category: "Positive", count: positiveVotes),
                VoteData(category: "Negative", count: negativeVotes),
                VoteData(category: "Neutral", count: summary.neutralVotes)
            ]
            recentNotes = report.notes
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadReportData(for orderId: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let reports = try await apiService.getPollingReport(orderId: orderId)
            
            // Get the first report from the array
            guard let report = reports.first else {
                errorMessage = "No report data available"
                return
            }
            
            let summary = report.summary
            pollingSummary = nil // Set to nil or map as needed
            recentActivity = []
            pollingOrders = try await apiService.fetchPollingOrders()
            await loadReport(for: orderId)
            totalVotes = summary.totalVotes
            candidateCount = report.candidates.count
            positiveVotes = summary.positiveVotes
            negativeVotes = summary.negativeVotes
            chartData = [
                VoteData(category: "Positive", count: positiveVotes),
                VoteData(category: "Negative", count: negativeVotes),
                VoteData(category: "Neutral", count: summary.neutralVotes)
            ]
            recentNotes = report.notes
        } catch {
            errorMessage = error.localizedDescription
        }
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

#Preview {
    ReportView()
} 