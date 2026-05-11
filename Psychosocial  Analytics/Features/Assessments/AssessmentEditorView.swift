//
//  AssessmentEditorView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

struct AssessmentEditorView: View {
    @Bindable var draft: AssessmentDraft
    @Environment(\.modelContext) private var modelContext
    @State private var editingSection: AssessmentSection?
    @State private var workingAnswers: [FieldAnswer] = []
    @State private var generatedReport: AssessmentReport?
    @State private var isGenerating = false
    @State private var generationError: String?

    private var generator: ReportGenerator { AIProviderSettings.shared.makeGenerator() }

    var body: some View {
        List {
            Section {
                LabeledContent("Status", value: draft.status.displayName)
                LabeledContent("Updated", value: draft.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }

            ForEach(AssessmentSectionGroup.allCases) { group in
                Section(group.title) {
                    ForEach(group.sections) { section in
                        Button {
                            workingAnswers = SectionTemplateLibrary.merged(
                                existing: draft.answers(for: section),
                                section: section
                            )
                            editingSection = section
                        } label: {
                            sectionRow(section)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section {
                Button {
                    Task { await generate() }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text(isGenerating ? "Generating draft report…" : "Generate Draft Report")
                        Spacer()
                        if isGenerating { ProgressView() }
                    }
                }
                .disabled(isGenerating)
                .tint(.emeraldAction)

                if let error = generationError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if let report = generatedReport ?? draft.assessmentPayload.report {
                    NavigationLink(value: report) {
                        Label("Preview Draft Report", systemImage: "doc.text.magnifyingglass")
                    }
                }
            } footer: {
                Text("Draft reports require human review before signature or export.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(draft.clientName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AssessmentReport.self) { ReportPreviewView(report: $0) }
        .sheet(item: $editingSection) { section in
            NavigationStack {
                SectionEditorView(section: section, answers: $workingAnswers) {
                    draft.setAnswers(workingAnswers, for: section)
                    try? modelContext.save()
                }
            }
        }
    }

    private func sectionRow(_ section: AssessmentSection) -> some View {
        let answered = draft.answers(for: section).filter { !$0.value.isEmpty }.count
        let total = SectionTemplateLibrary.template(for: section).definitions.count
        let complete = total > 0 && answered == total
        return HStack {
            Image(systemName: complete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(complete ? Color.emeraldAction : Color.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(section.title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Color.obsidianText)
                Text("\(answered) of \(total) fields")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.caption)
        }
    }

    private func generate() async {
        isGenerating = true
        generationError = nil
        defer { isGenerating = false }
        do {
            let report = try await generator.generate(from: draft)
            generatedReport = report
            draft.storeReport(report, riskFlags: report.riskNotes.map {
                RiskFlag(id: UUID(), type: $0.category, severity: $0.severity, note: $0.excerpt)
            })
            try? modelContext.save()
        } catch {
            generationError = error.localizedDescription
        }
    }
}
