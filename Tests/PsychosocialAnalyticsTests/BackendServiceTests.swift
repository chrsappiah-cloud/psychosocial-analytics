import XCTest
@testable import PsychosocialAnalytics

final class BackendServiceTests: XCTestCase {
    func testMockBackendSyncAndFetch() async throws {
        let seed = [TestFixtures.makeAssessment()]
        let backend = MockPsychosocialBackend(seed: seed)
        let fetched = try await backend.fetchAssessments()
        XCTAssertEqual(fetched.count, 1)

        var updated = fetched
        updated[0].status = .inReview
        let sync = try await backend.syncAssessments(updated)
        XCTAssertEqual(sync.syncedCount, 1)

        let again = try await backend.fetchAssessments()
        XCTAssertEqual(again.first?.status, .inReview)
    }

    func testPsychosocialBackendServiceFetchViaAPIClient() async throws {
        let assessment = TestFixtures.makeAssessment()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockBackendResponses.fetchAssessments([assessment]))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = APIClient(
            baseURL: URL(string: "https://staging.api.psychosocialanalytics.com")!,
            session: URLSession(configuration: config),
            middleware: [
                JSONContentTypeMiddleware(),
                AuthorizationMiddleware(tokenProvider: { "staging-key" })
            ]
        )
        let service = PsychosocialBackendService(client: client)
        let items = try await service.fetchAssessments()
        XCTAssertEqual(items.count, 1)
    }

    func testPsychosocialBackendServiceSyncPOST() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertTrue(request.url?.path.contains("sync") == true)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockBackendResponses.syncAssessments(count: 2))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = APIClient(
            baseURL: URL(string: "https://api.psychosocialanalytics.com")!,
            session: URLSession(configuration: config)
        )
        let service = PsychosocialBackendService(client: client)
        let result = try await service.syncAssessments([
            TestFixtures.makeAssessment(),
            TestFixtures.makeAssessment(status: .signed)
        ])
        XCTAssertEqual(result.syncedCount, 2)
    }
}
