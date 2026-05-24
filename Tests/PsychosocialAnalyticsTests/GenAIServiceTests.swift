import XCTest
@testable import PsychosocialAnalytics

final class GenAIServiceTests: XCTestCase {
    func testPromptBuilderIncludesSectionAnswers() {
        var assessment = TestFixtures.makeAssessment()
        assessment.sections = [
            AssessmentSectionPayload(
                id: UUID(),
                section: .presentingProblem,
                answers: [
                    FieldAnswer(id: UUID(), key: "clientDescription", label: "Client's Description", value: "Anxiety and insomnia")
                ],
                completionScore: 0.5,
                lastEditedAt: Date()
            )
        ]
        let prompt = AssessmentPromptBuilder().buildPrompt(for: assessment)
        XCTAssertTrue(prompt.contains("Presenting Problem"))
        XCTAssertTrue(prompt.contains("Anxiety and insomnia"))
    }

    func testPromptBuilderHandlesEmptyAssessment() {
        let prompt = AssessmentPromptBuilder().buildPrompt(for: TestFixtures.makeAssessment())
        XCTAssertTrue(prompt.contains("template draft"))
    }

    func testLocalMockGenerationReturnsStructuredContent() async throws {
        let service = GenAIService(simulatedLatencyNanoseconds: 0)
        let result = try await service.generateReportDraft(for: TestFixtures.makeAssessment(), model: .gpt4o)
        XCTAssertTrue(result.content.contains("CLINICAL SUMMARY"))
        XCTAssertEqual(result.model, .gpt4o)
        XCTAssertEqual(result.section, .clinicalSummary)
        XCTAssertGreaterThan(result.confidence, 0)
    }

    func testLocalMockReflectsCompletedSectionCount() async throws {
        var assessment = TestFixtures.makeAssessment()
        assessment.sections = [
            AssessmentSectionPayload(
                id: UUID(), section: .referral, answers: [],
                completionScore: 1, lastEditedAt: Date()
            ),
            AssessmentSectionPayload(
                id: UUID(), section: .clinicalSummary, answers: [],
                completionScore: 0.5, lastEditedAt: Date()
            )
        ]
        let service = GenAIService(simulatedLatencyNanoseconds: 0)
        let result = try await service.generateReportDraft(for: assessment, model: .llama3Instruct)
        XCTAssertTrue(result.content.contains("2 completed section"))
        XCTAssertEqual(result.model, .llama3Instruct)
    }

    func testRemoteModeUsesBackend() async throws {
        let backend = MockAIGenerationBackend()
        backend.responseContent = "REMOTE: Integrated clinical narrative."
        let service = GenAIService(backend: backend)
        let assessment = TestFixtures.makeAssessment()
        let result = try await service.generateReportDraft(for: assessment, model: .gpt4o)
        XCTAssertEqual(result.content, "REMOTE: Integrated clinical narrative.")
        XCTAssertEqual(backend.lastRequest?.model, .gpt4o)
        XCTAssertEqual(backend.lastRequest?.assessmentID, assessment.id)
        XCTAssertFalse(backend.lastRequest?.prompt.isEmpty ?? true)
    }

    func testRemoteModePropagatesBackendFailure() async {
        let backend = MockAIGenerationBackend()
        backend.shouldFail = true
        let service = GenAIService(backend: backend)
        do {
            _ = try await service.generateReportDraft(for: TestFixtures.makeAssessment(), model: .gpt4o)
            XCTFail("Expected failure")
        } catch let error as AIGenerationError {
            if case .backendUnavailable = error { } else {
                XCTFail("Unexpected: \(error)")
            }
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }

    func testAIModelRawValues() {
        XCTAssertEqual(AIModel.gpt4o.rawValue, "gpt-4o")
        XCTAssertEqual(AIModel.llama3Instruct.rawValue, "llama-3.1-instruct")
        XCTAssertEqual(AIModel.allCases.count, 2)
    }
}
