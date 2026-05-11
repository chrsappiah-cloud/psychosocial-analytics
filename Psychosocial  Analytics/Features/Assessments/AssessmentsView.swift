//
//  AssessmentsView.swift
//  Psychosocial  Analytics
//

import SwiftUI
import SwiftData

struct AssessmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AssessmentDraft.updatedAt, order: .reverse) private var drafts: [AssessmentDraft]
    @State private var showingNewDraftSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if drafts.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(drafts) { draft in
                            NavigationLink(value: draft) {
                                draftRow(draft)
                            }
                        }
                        .onDelete(perform: deleteDrafts)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color.pearlBackground.ignoresSafeArea())
            .navigationTitle("Assessments")
            .navigationDestination(for: AssessmentDraft.self) { draft in
                AssessmentEditorView(draft: draft)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewDraftSheet = true
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewDraftSheet) {
                NewAssessmentSheet { name in
                    addDraft(named: name)
                }
            }
        }
    }

    private func draftRow(_ draft: AssessmentDraft) -> some View {
        HStack(spacing: 12) {
            statusDot(draft.status)
            VStack(alignment: .leading, spacing: 2) {
                Text(draft.clientName)
                    .font(.body.weight(.semibold))
                Text("Updated \(draft.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(draft.status.displayName)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.vertical, 4)
    }

    private func statusDot(_ status: AssessmentStatus) -> some View {
        Circle()
            .fill(color(for: status))
            .frame(width: 10, height: 10)
    }

    private func color(for status: AssessmentStatus) -> Color {
        switch status {
        case .draft: .royalGold
        case .inReview: .emeraldAction.opacity(0.6)
        case .signed: .emeraldAction
        case .exported: .obsidianText
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Assessments Yet", systemImage: "doc.text.fill")
        } description: {
            Text("Tap + to start a new psychosocial assessment, or load a sample to preview the report flow.")
        } actions: {
            VStack(spacing: 8) {
                Button {
                    showingNewDraftSheet = true
                } label: {
                    Text("Start First Assessment")
                }
                .buttonStyle(.borderedProminent)
                .tint(.emeraldAction)

                Button {
                    loadSample()
                } label: {
                    Label("Load Sample Assessment", systemImage: "sparkles")
                }
                .buttonStyle(.bordered)
                .tint(.emeraldAction)
            }
        }
    }

    private func addDraft(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let draft = AssessmentDraft(clientName: trimmed)
        modelContext.insert(draft)
    }

    private func loadSample() {
        let draft = SampleAssessmentData.seededDraft()
        modelContext.insert(draft)
        try? modelContext.save()
    }

    private func deleteDrafts(_ offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(drafts[index])
        }
    }
}

private struct NewAssessmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var clientName: String = ""
    let onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client name or identifier", text: $clientName)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(clientName)
                        dismiss()
                    }
                    .disabled(clientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AssessmentsView()
        .modelContainer(for: AssessmentDraft.self, inMemory: true)
}
