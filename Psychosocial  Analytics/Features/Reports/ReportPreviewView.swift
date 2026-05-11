//
//  ReportPreviewView.swift
//  Psychosocial  Analytics
//

import SwiftUI

struct ReportPreviewView: View {
    let report: AssessmentReport

    var body: some View {
        ScrollView { renderableContent }
            .background(Color.pearlBackground.ignoresSafeArea())
            .navigationTitle("Draft Report")
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    var renderableContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            draftBanner
            if !report.riskNotes.isEmpty { riskCard }
            if !report.missingInformation.isEmpty { missingInfoCard }

            groupCard(title: "Basic Information", body: report.basicInformationNarrative)
            groupCard(title: "Background and Current Functioning",
                      body: report.backgroundAndFunctioningNarrative)

            clinicalSummaryCard
            goalsCard
            if let dx = report.diagnosticImpressions, !dx.isEmpty {
                paragraphCard(title: "Diagnostic Impressions", body: dx,
                              footer: "Clinician-reviewed only and policy-constrained.")
            }
        }
        .padding(20)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(report.clientName)
                .font(.title2.weight(.semibold))
            Text("Generated \(report.generatedAt.formatted(date: .abbreviated, time: .shortened)) · \(report.modelIdentifier)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var draftBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.emeraldAction)
            Text("AI-generated draft. Every paragraph requires clinician review before signature or export.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var riskCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Safeguarding Notes", systemImage: "exclamationmark.shield.fill")
                .foregroundStyle(Color.royalGold)
                .font(.headline)
            ForEach(report.riskNotes) { note in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(note.category) · \(note.severity.capitalized)")
                        .font(.callout.weight(.semibold))
                    Text("Source: \(note.sourceSection)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(note.excerpt)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Divider()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var missingInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Missing Information", systemImage: "questionmark.circle.fill")
                .foregroundStyle(.secondary)
                .font(.headline)
            ForEach(report.missingInformation, id: \.self) { item in
                Text("• \(item)").font(.callout).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var clinicalSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Clinical Summary, Impressions, and Assessment")
                .font(.headline)
            block("Problems", report.problems)
            block("Contributing Factors", report.contributingFactors)
            block("Assets and Resources", report.assetsAndResources)
            block("Prognosis", report.prognosis)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var goalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals and Recommendations")
                .font(.headline)
            bulletList("Short-Term Goals", items: report.goals.shortTerm)
            bulletList("Long-Term Goals", items: report.goals.longTerm)
            bulletList("Recommended Interventions", items: report.goals.recommendedInterventions)
            block("Plan for Intervention", report.planForIntervention)
            block("Follow-Up Plan", report.goals.followUpPlan)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func paragraphCard(title: String, body: String, footer: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(body).font(.callout).foregroundStyle(.primary)
            if let footer { Text(footer).font(.caption).foregroundStyle(.secondary) }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func groupCard(title: String, body: String) -> some View {
        paragraphCard(title: title, body: body)
    }

    private func block(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(value.isEmpty ? "Insufficient information." : value)
                .font(.callout).foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private func bulletList(_ title: String, items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                ForEach(items, id: \.self) { Text("• \($0)").font(.callout) }
            }
        }
    }
}
