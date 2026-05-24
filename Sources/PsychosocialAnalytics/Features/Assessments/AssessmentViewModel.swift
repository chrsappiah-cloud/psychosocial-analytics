import Foundation
import SwiftUI

@MainActor
public class AssessmentViewModel: ObservableObject {
    @Published public var assessments: [Assessment] = []
    @Published public var currentAssessment: Assessment?
    @Published public var isGeneratingAI = false
    @Published public var lastAIError: String?

    private let repository: AssessmentRepositoryProtocol
    private let aiService: GenAIServiceProtocol

    public init(repository: AssessmentRepositoryProtocol? = nil,
                aiService: GenAIServiceProtocol = GenAIService.forApp()) {
        if let repository {
            self.repository = repository
        } else {
            let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let supportDir = paths[0].appendingPathComponent("PsychosocialAnalytics", isDirectory: true)
            let database = (try? LocalDatabase(directory: supportDir)) ?? LocalDatabase(
                persistence: PersistenceService(baseURL: supportDir)
            )
            self.repository = AssessmentRepository(
                database: database,
                backend: MockPsychosocialBackend()
            )
        }
        self.aiService = aiService
        Task { await reload() }
    }

    public func reload() async {
        do {
            assessments = try await repository.loadAssessments()
        } catch {
            print("Failed to load assessments: \(error)")
            assessments = []
        }
    }

    public func createAssessment() {
        Task {
            do {
                let created = try await repository.createAssessment()
                currentAssessment = created
                await reload()
                AppCoordinator.shared.showNotification("New assessment created", type: .success)
            } catch {
                AppCoordinator.shared.showNotification("Could not create assessment", type: .error)
            }
        }
    }

    /// Awaits the latest in-memory state being written to the local database.
    public func persistNow() async {
        try? await repository.saveAssessments(assessments)
    }

    public func syncWithBackend() async {
        do {
            let result = try await repository.syncWithBackend()
            await reload()
            AppCoordinator.shared.showNotification(
                "Synced \(result.syncedCount) assessment(s)",
                type: .success
            )
        } catch {
            AppCoordinator.shared.showNotification("Sync failed", type: .error)
        }
    }

    public func generateAIDraft(model: AIModel = .gpt4o) async {
        guard let assessment = currentAssessment else {
            lastAIError = "No assessment selected"
            AppCoordinator.shared.showNotification("Select an assessment first", type: .warning)
            return
        }
        isGeneratingAI = true
        lastAIError = nil
        defer { isGeneratingAI = false }

        do {
            let result = try await aiService.generateReportDraft(for: assessment, model: model)
            updateAssessment(id: assessment.id) { a in
                a.aiDrafts.append(
                    AIDraft(
                        id: UUID(),
                        section: result.section,
                        content: result.content,
                        confidence: result.confidence
                    )
                )
            }
            await persistNow()
            AppCoordinator.shared.showNotification("AI draft generated successfully", type: .success)
        } catch {
            lastAIError = error.localizedDescription
            AppCoordinator.shared.showNotification("Failed to generate AI draft", type: .error)
        }
    }

    public func aiDraftCount(for assessmentID: UUID) -> Int {
        assessment(id: assessmentID)?.aiDrafts.count ?? 0
    }

    // MARK: - Section form support

    public func assessment(id: UUID) -> Assessment? {
        assessments.first(where: { $0.id == id })
    }

    private func updateAssessment(id: UUID, mutate: (inout Assessment) -> Void) {
        guard let idx = assessments.firstIndex(where: { $0.id == id }) else { return }
        var copy = assessments[idx]
        mutate(&copy)
        copy.updatedAt = Date()
        assessments[idx] = copy
        if currentAssessment?.id == id { currentAssessment = copy }
        Task {
            try? await repository.saveAssessments(assessments)
        }
    }

    private func ensureSectionIndex(in assessment: inout Assessment,
                                    section: AssessmentSection) -> Int {
        if let i = assessment.sections.firstIndex(where: { $0.section == section }) {
            return i
        }
        let payload = AssessmentSectionPayload(
            id: UUID(),
            section: section,
            answers: [],
            completionScore: 0,
            lastEditedAt: Date()
        )
        assessment.sections.append(payload)
        return assessment.sections.count - 1
    }

    public func value(assessmentID: UUID,
                      section: AssessmentSection,
                      fieldKey: String) -> String {
        guard let a = assessment(id: assessmentID),
              let payload = a.sections.first(where: { $0.section == section }),
              let answer = payload.answers.first(where: { $0.key == fieldKey })
        else { return "" }
        return answer.value
    }

    public func setValue(_ value: String,
                         assessmentID: UUID,
                         section: AssessmentSection,
                         field: SectionFieldSpec) {
        updateAssessment(id: assessmentID) { a in
            let sIdx = ensureSectionIndex(in: &a, section: section)
            if let aIdx = a.sections[sIdx].answers.firstIndex(where: { $0.key == field.id }) {
                a.sections[sIdx].answers[aIdx].value = value
            } else {
                a.sections[sIdx].answers.append(
                    FieldAnswer(id: UUID(), key: field.id, label: field.label, value: value)
                )
            }
            a.sections[sIdx].lastEditedAt = Date()
            let total = AssessmentSectionSchema.fields(for: section).count
            let filled = a.sections[sIdx].answers.filter { !$0.value.isEmpty && $0.value != "false" }.count
            a.sections[sIdx].completionScore = total == 0 ? 0 : Double(filled) / Double(total)
        }
    }

    public func binding(assessmentID: UUID,
                        section: AssessmentSection,
                        field: SectionFieldSpec) -> Binding<String> {
        Binding<String>(
            get: { [weak self] in
                self?.value(assessmentID: assessmentID, section: section, fieldKey: field.id) ?? ""
            },
            set: { [weak self] newValue in
                self?.setValue(newValue, assessmentID: assessmentID, section: section, field: field)
            }
        )
    }

    public func resetSection(assessmentID: UUID, section: AssessmentSection) {
        updateAssessment(id: assessmentID) { a in
            if let i = a.sections.firstIndex(where: { $0.section == section }) {
                a.sections[i].answers.removeAll()
                a.sections[i].completionScore = 0
                a.sections[i].lastEditedAt = Date()
            }
        }
    }

    public func completion(assessmentID: UUID, section: AssessmentSection) -> Double {
        guard let a = assessment(id: assessmentID),
              let payload = a.sections.first(where: { $0.section == section })
        else { return 0 }
        return payload.completionScore
    }
}
