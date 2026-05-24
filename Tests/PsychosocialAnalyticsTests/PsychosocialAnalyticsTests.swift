import XCTest
@testable import PsychosocialAnalytics

final class PsychosocialAnalyticsTests: XCTestCase {
    func testAppTabsHaveTitlesAndIcons() {
        for tab in AppTab.allCases {
            XCTAssertFalse(tab.title.isEmpty)
            XCTAssertFalse(tab.icon.isEmpty)
            XCTAssertFalse(tab.accessibilityID.isEmpty)
        }
    }

    func testEnvironmentSwitchUpdatesURL() {
        let env = AppEnvironment()
        env.update(to: .development)
        XCTAssertTrue(env.apiBaseURL.absoluteString.contains("localhost"))
        env.update(to: .production)
        XCTAssertTrue(env.apiBaseURL.absoluteString.contains("api"))
    }

    @MainActor
    func testSectionSchemaCoversAllSections() {
        for section in AssessmentSection.allCases {
            XCTAssertFalse(AssessmentSectionSchema.title(for: section).isEmpty,
                           "Missing title for \(section)")
            XCTAssertFalse(AssessmentSectionSchema.fields(for: section).isEmpty,
                           "Missing fields for \(section)")
        }
    }

    @MainActor
    func testSectionFormBindingUpdatesAnswersAndCompletion() async throws {
        let repository = try TestFixtures.makeRepository()
        let vm = AssessmentViewModel(repository: repository, aiService: MockGenAIService())
        try await Task.sleep(nanoseconds: 100_000_000)

        guard let assessmentID = vm.assessments.first?.id else {
            XCTFail("No seeded assessment")
            return
        }
        let section = AssessmentSection.presentingProblem
        let fields = AssessmentSectionSchema.fields(for: section)
        XCTAssertGreaterThan(fields.count, 1)

        vm.resetSection(assessmentID: assessmentID, section: section)
        vm.setValue("Client reports anxiety.",
                    assessmentID: assessmentID,
                    section: section,
                    field: fields[0])

        XCTAssertEqual(
            vm.value(assessmentID: assessmentID, section: section, fieldKey: fields[0].id),
            "Client reports anxiety."
        )

        let partial = vm.completion(assessmentID: assessmentID, section: section)
        XCTAssertGreaterThan(partial, 0)
        XCTAssertLessThan(partial, 1)

        for spec in fields.dropFirst() {
            let v = spec.kind == .toggle ? "true" : "value"
            vm.setValue(v, assessmentID: assessmentID, section: section, field: spec)
        }
        XCTAssertEqual(vm.completion(assessmentID: assessmentID, section: section), 1.0, accuracy: 0.0001)
    }

    func testGenAIServiceGeneratesDraft() async throws {
        let service = GenAIService(simulatedLatencyNanoseconds: 0)
        let result = try await service.generateReportDraft(for: TestFixtures.makeAssessment(), model: .gpt4o)
        XCTAssertTrue(result.content.contains("CLINICAL SUMMARY"))
    }
}
