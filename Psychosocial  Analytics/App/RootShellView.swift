//
//  RootShellView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case dashboard, assessments, analytics, reports, settings
}

struct RootShellView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "sparkle.magnifyingglass") }
                .tag(AppTab.dashboard)

            AssessmentsView()
                .tabItem { Label("Assessments", systemImage: "doc.text.fill") }
                .tag(AppTab.assessments)

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.xyaxis.line") }
                .tag(AppTab.analytics)

            ReportsView()
                .tabItem { Label("Reports", systemImage: "signature") }
                .tag(AppTab.reports)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
        .tint(.emeraldAction)
    }
}

#Preview {
    RootShellView()
        .modelContainer(for: AssessmentDraft.self, inMemory: true)
}
