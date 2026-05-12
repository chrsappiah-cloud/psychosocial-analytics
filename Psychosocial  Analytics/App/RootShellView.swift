//
//  RootShellView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

enum AppTab: String, Hashable, CaseIterable, Identifiable {
    case dashboard, assessments, analytics, reports, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .assessments: "Assessments"
        case .analytics: "Analytics"
        case .reports: "Reports"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "sparkle.magnifyingglass"
        case .assessments: "doc.text.fill"
        case .analytics: "chart.xyaxis.line"
        case .reports: "signature"
        case .settings: "gearshape.fill"
        }
    }
}

struct RootShellView: View {
    @Query(sort: \AssessmentDraft.updatedAt, order: .reverse) private var drafts: [AssessmentDraft]
    @AppStorage(SyncBackupPreferences.selectedTabKey) private var selectedTabRaw: String = AppTab.dashboard.rawValue

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { AppTab(rawValue: selectedTabRaw) ?? .dashboard },
            set: { selectedTabRaw = $0.rawValue }
        )
    }

    private var reportCount: Int {
        drafts.filter { $0.assessmentPayload.report != nil }.count
    }

    private var openDraftCount: Int {
        drafts.filter { $0.status != .signed && $0.status != .exported }.count
    }

    var body: some View {
        TabView(selection: selectedTabBinding) {
            DashboardView { tab in
                selectedTabRaw = tab.rawValue
            }
                .tabItem { Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.systemImage) }
                .tag(AppTab.dashboard)

            AssessmentsView()
                .tabItem { Label(AppTab.assessments.title, systemImage: AppTab.assessments.systemImage) }
                .badge(openDraftCount)
                .tag(AppTab.assessments)

            AnalyticsView()
                .tabItem { Label(AppTab.analytics.title, systemImage: AppTab.analytics.systemImage) }
                .tag(AppTab.analytics)

            ReportsView()
                .tabItem { Label(AppTab.reports.title, systemImage: AppTab.reports.systemImage) }
                .badge(reportCount)
                .tag(AppTab.reports)

            SettingsView()
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
                .tag(AppTab.settings)
        }
        .tint(.emeraldAction)
    }
}

#Preview {
    RootShellView()
        .modelContainer(for: AssessmentDraft.self, inMemory: true)
}
