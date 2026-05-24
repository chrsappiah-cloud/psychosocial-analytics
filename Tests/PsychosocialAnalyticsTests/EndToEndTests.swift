import XCTest
@testable import PsychosocialAnalytics

/// Full stack: database → repository → middleware/backend → view model → AI.
final class EndToEndTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    @MainActor
    func testFullClinicalWorkflow() async throws {
        let dir = try TestFixtures.tempDirectory()
        let database = try LocalDatabase(directory: dir)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            if request.httpMethod == "POST" {
                return (response, MockBackendResponses.syncAssessments(count: 1))
            }
            return (response, MockBackendResponses.fetchAssessments([]))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let backend = PsychosocialBackendService(
            client: APIClient(
                baseURL: URL(string: "https://api.test.local")!,
                session: URLSession(configuration: config),
                middleware: [
                    JSONContentTypeMiddleware(),
                    AuthorizationMiddleware(tokenProvider: { "e2e-token" })
                ]
            )
        )
        let repository = AssessmentRepository(database: database, backend: backend)
        let ai = MockGenAIService()
        let vm = AssessmentViewModel(repository: repository, aiService: ai)
        try await Task.sleep(nanoseconds: 150_000_000)

        // 1. Create assessment (database)
        vm.createAssessment()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertGreaterThanOrEqual(vm.assessments.count, 1)
        guard let assessmentID = vm.assessments.first?.id else {
            XCTFail("Assessment not created")
            return
        }
        vm.currentAssessment = vm.assessment(id: assessmentID)

        // 2. Complete a psychosocial section (database)
        let section = AssessmentSection.clinicalSummary
        let fields = AssessmentSectionSchema.fields(for: section)
        vm.resetSection(assessmentID: assessmentID, section: section)
        for spec in fields {
            let value = spec.kind == .toggle ? "true" : "Clinical E2E value for \(spec.id)"
            vm.setValue(value, assessmentID: assessmentID, section: section, field: spec)
        }
        await vm.persistNow()
        XCTAssertEqual(vm.completion(assessmentID: assessmentID, section: section), 1.0, accuracy: 0.001)

        // 3. Sync with backend (middleware + API)
        await vm.syncWithBackend()
        try await Task.sleep(nanoseconds: 150_000_000)

        // 4. Generate AI draft (AI service)
        await vm.generateAIDraft()
        let updated = vm.assessment(id: assessmentID)
        XCTAssertFalse(updated?.aiDrafts.isEmpty ?? true)
        XCTAssertTrue(updated?.aiDrafts.first?.content.contains("E2E CLINICAL") == true)

        // 5. Verify database still holds section answers after reload
        await vm.persistNow()
        let freshVM = AssessmentViewModel(repository: repository, aiService: ai)
        await freshVM.reload()
        XCTAssertEqual(
            freshVM.value(assessmentID: assessmentID, section: section, fieldKey: fields[0].id),
            "Clinical E2E value for \(fields[0].id)"
        )
    }

    func testEnvironmentMiddlewareURLPipeline() {
        let env = AppEnvironment()
        env.update(to: .development)
        XCTAssertTrue(env.apiBaseURL.absoluteString.contains("localhost"))
        env.update(to: .staging)
        XCTAssertTrue(env.apiBaseURL.absoluteString.contains("staging"))
        env.update(to: .production)
        XCTAssertTrue(env.apiBaseURL.absoluteString.contains("api.psychosocialanalytics.com"))
    }
}
