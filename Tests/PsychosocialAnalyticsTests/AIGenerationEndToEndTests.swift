import XCTest
@testable import PsychosocialAnalytics

/// End-to-end AI path: UI layer (ViewModel) → GenAI → middleware → HTTP backend → persistence.
final class AIGenerationEndToEndTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    @MainActor
    func testCompleteAIGenerationPipeline() async throws {
        let dir = try TestFixtures.tempDirectory()
        let database = try LocalDatabase(directory: dir)
        let assessment = TestFixtures.makeAssessment()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            if request.url?.path.contains("ai/generate") == true {
                return (response, MockBackendResponses.generateDraft())
            }
            if request.httpMethod == "POST" {
                return (response, MockBackendResponses.syncAssessments(count: 1))
            }
            return (response, MockBackendResponses.fetchAssessments([assessment]))
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let apiClient = APIClient(
            baseURL: URL(string: "https://api.test.local")!,
            session: URLSession(configuration: config),
            middleware: [JSONContentTypeMiddleware()]
        )

        let recordBackend = PsychosocialBackendService(client: apiClient)
        let aiBackend = AIGenerationBackendService(client: apiClient)
        let repository = AssessmentRepository(database: database, backend: recordBackend)
        let genAI = GenAIService(backend: aiBackend)

        let vm = AssessmentViewModel(repository: repository, aiService: genAI)
        try await Task.sleep(nanoseconds: 150_000_000)

        guard let id = vm.assessments.first?.id else {
            XCTFail("Missing assessment")
            return
        }

        // Fill presenting problem for richer prompt
        let section = AssessmentSection.presentingProblem
        let fields = AssessmentSectionSchema.fields(for: section)
        vm.setValue("Client reports elevated stress.", assessmentID: id, section: section, field: fields[0])
        await vm.persistNow()

        vm.currentAssessment = vm.assessment(id: id)
        await vm.generateAIDraft(model: .gpt4o)

        let withDraft = vm.assessment(id: id)
        XCTAssertEqual(withDraft?.aiDrafts.count, 1)
        XCTAssertEqual(withDraft?.aiDrafts.first?.content, MockBackendResponses.generateDraftContent)

        await vm.persistNow()
        let restored = AssessmentViewModel(repository: repository, aiService: genAI)
        await restored.reload()
        XCTAssertEqual(restored.assessment(id: id)?.aiDrafts.count, 1)
    }
}
