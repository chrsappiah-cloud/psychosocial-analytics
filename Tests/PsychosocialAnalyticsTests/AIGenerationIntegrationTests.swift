import XCTest
@testable import PsychosocialAnalytics

/// Middleware + AI backend + GenAIService + ViewModel.
final class AIGenerationIntegrationTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    @MainActor
    func testRemoteGenAIServiceThroughHTTPStack() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockBackendResponses.generateDraft(model: .llama3Instruct))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let backend = AIGenerationBackendService(
            client: APIClient(
                baseURL: URL(string: "https://api.test.local")!,
                session: URLSession(configuration: config)
            )
        )
        let service = GenAIService(backend: backend)
        let result = try await service.generateReportDraft(
            for: TestFixtures.makeAssessment(),
            model: .llama3Instruct
        )
        XCTAssertEqual(result.model, .llama3Instruct)
        XCTAssertEqual(result.content, MockBackendResponses.generateDraftContent)
    }

    @MainActor
    func testViewModelUsesRemoteAIAndPersistsDraft() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockBackendResponses.generateDraft())
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let aiBackend = AIGenerationBackendService(
            client: APIClient(
                baseURL: URL(string: "https://api.test.local")!,
                session: URLSession(configuration: config)
            )
        )
        let repository = try TestFixtures.makeRepository()
        let service = GenAIService(backend: aiBackend)
        let vm = AssessmentViewModel(repository: repository, aiService: service)
        try await Task.sleep(nanoseconds: 100_000_000)

        guard let id = vm.assessments.first?.id else {
            XCTFail("No assessment")
            return
        }
        vm.currentAssessment = vm.assessment(id: id)
        await vm.generateAIDraft()
        XCTAssertEqual(vm.assessment(id: id)?.aiDrafts.first?.content, MockBackendResponses.generateDraftContent)
    }
}
