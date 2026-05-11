//
//  AnalyticsView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var drafts: [AssessmentDraft]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    statusBreakdown
                    placeholderCard
                }
                .padding(20)
            }
            .background(Color.pearlBackground.ignoresSafeArea())
            .navigationTitle("Analytics")
        }
    }

    private var statusBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Breakdown")
                .font(.headline)
            ForEach(AssessmentStatus.allCases, id: \.self) { status in
                HStack {
                    Text(status.displayName)
                        .font(.callout)
                    Spacer()
                    Text("\(drafts.filter { $0.status == status }.count)")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var placeholderCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.emeraldAction)
                Text("Trend Analytics")
                    .font(.headline)
            }
            Text("Section completion velocity, risk-flag frequency, and AI review turnaround will render here once data is available.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: AssessmentDraft.self, inMemory: true)
}
