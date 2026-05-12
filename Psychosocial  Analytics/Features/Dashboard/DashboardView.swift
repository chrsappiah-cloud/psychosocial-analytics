//
//  DashboardView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \AssessmentDraft.updatedAt, order: .reverse) private var drafts: [AssessmentDraft]
    @AppStorage(SyncBackupPreferences.cloudKitSyncEnabledKey) private var cloudKitSyncEnabled = true
    @AppStorage(SyncBackupPreferences.iCloudBackupEnabledKey) private var iCloudBackupEnabled = true
    @AppStorage(SyncBackupPreferences.cloudKitStartupIssueKey) private var cloudKitStartupIssue = ""
    let onSelectTab: (AppTab) -> Void

    init(onSelectTab: @escaping (AppTab) -> Void = { _ in }) {
        self.onSelectTab = onSelectTab
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    navigationRail
                    summaryRow
                    flaggedCard
                    completionCard
                    aiQueueCard
                    cloudContinuityCard
                }
                .padding(20)
            }
            .background(Color.pearlBackground.ignoresSafeArea())
            .navigationTitle("Dashboard")
        }
    }

    private var navigationRail: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Navigation")
                .font(.headline)

            HStack(spacing: 10) {
                quickActionButton(title: "New Assessment", systemImage: "plus.circle.fill", tab: .assessments)
                quickActionButton(title: "Reports", systemImage: "signature", tab: .reports)
            }

            HStack(spacing: 10) {
                quickActionButton(title: "Analytics", systemImage: "chart.xyaxis.line", tab: .analytics)
                quickActionButton(title: "Settings", systemImage: "gearshape.fill", tab: .settings)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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

    private var cloudContinuityCard: some View {
        DashboardCard(title: "Cloud Continuity", systemImage: "icloud.and.arrow.up.fill", tint: .emeraldAction) {
            VStack(alignment: .leading, spacing: 10) {
                Text(SyncBackupPreferences.cloudStatus(
                    cloudKitEnabled: cloudKitSyncEnabled,
                    iCloudBackupEnabled: iCloudBackupEnabled,
                    startupIssue: startupIssue
                ))
                .font(.callout)
                .foregroundStyle(.secondary)

                if let startupIssue {
                    Text("Startup note: \(startupIssue)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Button {
                    onSelectTab(.settings)
                } label: {
                    Label("Open Sync Settings", systemImage: "gearshape.2.fill")
                }
                .buttonStyle(.bordered)
                .tint(.emeraldAction)
            }
        }
    }

    private func quickActionButton(title: String, systemImage: String, tab: AppTab) -> some View {
        Button {
            onSelectTab(tab)
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.emeraldAction)
    }

    private var startupIssue: String? {
        cloudKitStartupIssue.isEmpty ? nil : cloudKitStartupIssue
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
