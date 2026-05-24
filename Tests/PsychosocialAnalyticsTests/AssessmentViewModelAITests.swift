import XCTest
@testable import PsychosocialAnalytics

@MainActor
final class AssessmentViewModelAITests: XCTestCase {
    func testGenerateAIDraftAppendsDraftAndPersists() async throws {
        let repository = try TestFixtures.makeRepository()
        let ai = MockGenAIService()
        ai.result = AIGenerationResult(
            content: "VM TEST: Clinical narrative.",
            model: .gpt4o,
            confidence: 0.91,
            section: .goalsRecommendations
        )
        let vm = AssessmentViewModel(repository: repository, aiService: ai)
        try await Task.sleep(nanoseconds: 100_000_000)

        guard let id = vm.assessments.first?.id else {
            XCTFail("Missing assessment")
            return
        }
        vm.currentAssessment = vm.assessment(id: id)
        await vm.generateAIDraft(model: .gpt4o)

        XCTAssertFalse(vm.isGeneratingAI)
        XCTAssertNil(vm.lastAIError)
        let updated = vm.assessment(id: id)
        XCTAssertEqual(updated?.aiDrafts.count, 1)
        XCTAssertEqual(updated?.aiDrafts.first?.content, "VM TEST: Clinical narrative.")
        XCTAssertEqual(updated?.aiDrafts.first?.section, .goalsRecommendations)

        await vm.persistNow()
        let reloaded = AssessmentViewModel(repository: repository, aiService: ai)
        await reloaded.reload()
        XCTAssertEqual(reloaded.assessment(id: id)?.aiDrafts.count, 1)
    }

    func testGenerateAIDraftWithoutSelectionSetsError() async throws {
        let vm = AssessmentViewModel(
            repository: try TestFixtures.makeRepository(),
            aiService: MockGenAIService()
        )
        try await Task.sleep(nanoseconds: 100_000_000)
        vm.currentAssessment = nil
        await vm.generateAIDraft()
        XCTAssertEqual(vm.lastAIError, "No assessment selected")
    }

    func testGenerateAIDraftHandlesServiceFailure() async throws {
        let ai = MockGenAIService()
        ai.shouldFail = true
        let vm = AssessmentViewModel(repository: try TestFixtures.makeRepository(), aiService: ai)
        try await Task.sleep(nanoseconds: 100_000_000)
        vm.currentAssessment = vm.assessments.first
        await vm.generateAIDraft()
        XCTAssertNotNil(vm.lastAIError)
        XCTAssertEqual(vm.assessments.first?.aiDrafts.count ?? 0, 0)
    }

    func testIsGeneratingAITogglesDuringRequest() async throws {
        let ai = SlowMockGenAIService(delayNanoseconds: 200_000_000)
        let vm = AssessmentViewModel(repository: try TestFixtures.makeRepository(), aiService: ai)
        try await Task.sleep(nanoseconds: 100_000_000)
        vm.currentAssessment = vm.assessments.first

        let task = Task { await vm.generateAIDraft() }
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(vm.isGeneratingAI)
        await task.value
        XCTAssertFalse(vm.isGeneratingAI)
    }
}

/// Defers response so loading state can be observed.
final class SlowMockGenAIService: GenAIServiceProtocol, @unchecked Sendable {
    let delayNanoseconds: UInt64
    init(delayNanoseconds: UInt64) { self.delayNanoseconds = delayNanoseconds }

    func generateReportDraft(for assessment: Assessment, model: AIModel?) async throws -> AIGenerationResult {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        return AIGenerationResult(
            content: "Slow draft",
            model: model ?? .gpt4o,
            confidence: 0.8,
            section: .clinicalSummary
        )
    }
}
