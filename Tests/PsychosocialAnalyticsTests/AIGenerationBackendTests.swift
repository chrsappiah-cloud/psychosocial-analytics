import XCTest
@testable import PsychosocialAnalytics

final class AIGenerationBackendTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testHTTPGenerateDraftPOSTsCorrectPayload() async throws {
        let assessment = TestFixtures.makeAssessment()
        let captured = Box<GenerateDraftRequest>()

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertTrue(request.url?.absoluteString.contains("ai/generate") == true)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer ai-test-key")
            let bodyData = request.httpBody ?? TestSupport.readHTTPBody(from: request.httpBodyStream)
            XCTAssertNotNil(bodyData)
            captured.value = try JSONDecoder().decode(GenerateDraftRequest.self, from: bodyData!)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockBackendResponses.generateDraft())
        }

        let client = makeAIClient(token: "ai-test-key")
        let service = AIGenerationBackendService(client: client)
        let result = try await service.generateDraft(
            assessment: assessment,
            model: .gpt4o,
            prompt: "Summarize presenting problem."
        )

        XCTAssertEqual(result.content, MockBackendResponses.generateDraftContent)
        XCTAssertEqual(result.model, .gpt4o)
        XCTAssertEqual(captured.value?.assessmentID, assessment.id)
        XCTAssertEqual(captured.value?.model, .gpt4o)
        XCTAssertEqual(captured.value?.prompt, "Summarize presenting problem.")
    }

    func testHTTPGenerateDraftRejectsEmptyPrompt() async {
        let service = AIGenerationBackendService(client: makeAIClient())
        do {
            _ = try await service.generateDraft(
                assessment: TestFixtures.makeAssessment(),
                model: .gpt4o,
                prompt: "   "
            )
            XCTFail("Expected empty prompt error")
        } catch let error as AIGenerationError {
            XCTAssertEqual(error, .emptyPrompt)
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }

    func testHTTPGenerateDraftMaps503Error() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, Data("model unavailable".utf8))
        }
        let service = AIGenerationBackendService(client: makeAIClient())
        do {
            _ = try await service.generateDraft(
                assessment: TestFixtures.makeAssessment(),
                model: .llama3Instruct,
                prompt: "test"
            )
            XCTFail("Expected HTTP error")
        } catch let error as APIClientError {
            if case .httpStatus(let code, _) = error {
                XCTAssertEqual(code, 503)
            } else {
                XCTFail("Unexpected APIClientError")
            }
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }

    func testMockAIGenerationBackendStoresLastRequest() async throws {
        let mock = MockAIGenerationBackend()
        mock.responseContent = "Stored request test"
        let assessment = TestFixtures.makeAssessment()
        let result = try await mock.generateDraft(
            assessment: assessment,
            model: .llama3Instruct,
            prompt: "Build goals section."
        )
        XCTAssertEqual(result.content, "Stored request test")
        XCTAssertEqual(mock.lastRequest?.model, .llama3Instruct)
    }

    private func makeAIClient(token: String = "token") -> APIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return APIClient(
            baseURL: URL(string: "https://api.test.local")!,
            session: URLSession(configuration: config),
            middleware: [
                JSONContentTypeMiddleware(),
                AuthorizationMiddleware(tokenProvider: { token })
            ]
        )
    }
}
