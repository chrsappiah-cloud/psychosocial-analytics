//
//  DashboardView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \AssessmentDraft.updatedAt, order: .reverse) private var drafts: [AssessmentDraft]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summaryRow
                    flaggedCard
                    completionCard
                    aiQueueCard
                }
                .padding(20)
            }
            .background(Color.pearlBackground.ignoresSafeArea())
            .navigationTitle("Dashboard")
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            metricTile(title: "Caseload", value: "\(drafts.count)", tint: .emeraldAction)
            metricTile(title: "Drafts", value: "\(drafts.filter { $0.status == .draft }.count)", tint: .royalGold)
            metricTile(title: "Signed", value: "\(drafts.filter { $0.status == .signed }.count)", tint: .obsidianText)
        }
    }

    private func metricTile(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var flaggedCard: some View {
        DashboardCard(title: "Flagged Assessments", systemImage: "exclamationmark.shield.fill", tint: .royalGold) {
            Text("No active risk flags. Newly created assessments will surface here when safeguarding indicators are detected.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var completionCard: some View {
        DashboardCard(title: "Completion Funnel", systemImage: "chart.bar.fill", tint: .emeraldAction) {
            Text("Section-by-section completion will appear once you start your first assessment.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var aiQueueCard: some View {
        DashboardCard(title: "AI Draft Queue", systemImage: "sparkles", tint: .emeraldAction) {
            Text("AI-generated section drafts await human review here. Every paragraph is tagged as draft until signed.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DashboardCard<Content: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: AssessmentDraft.self, inMemory: true)
}
