//
//  ReportsView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

struct ReportsView: View {
    @Query(sort: \AssessmentDraft.updatedAt, order: .reverse) private var drafts: [AssessmentDraft]

    private var draftsWithReports: [AssessmentDraft] {
        drafts.filter { $0.assessmentPayload.report != nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if draftsWithReports.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(draftsWithReports) { draft in
                            if let report = draft.assessmentPayload.report {
                                NavigationLink(value: report) {
                                    row(draft: draft, report: report)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color.pearlBackground.ignoresSafeArea())
            .navigationTitle("Reports")
            .navigationDestination(for: AssessmentReport.self) { ReportPreviewView(report: $0) }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Reports Yet", systemImage: "signature")
        } description: {
            Text("Generate a draft report from the Assessments tab to preview it here.")
        }
    }

    private func row(draft: AssessmentDraft, report: AssessmentReport) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(draft.clientName)
                    .font(.body.weight(.semibold))
                Spacer()
                Text(draft.status.displayName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            Text("Generated \(report.generatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !report.riskNotes.isEmpty {
                Label("\(report.riskNotes.count) safeguarding note(s)", systemImage: "exclamationmark.shield.fill")
                    .font(.caption)
                    .foregroundStyle(Color.royalGold)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ReportsView()
        .modelContainer(for: AssessmentDraft.self, inMemory: true)
}
