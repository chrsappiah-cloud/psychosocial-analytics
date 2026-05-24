import XCTest
@testable import PsychosocialAnalytics

final class MiddlewareTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testJSONContentTypeMiddlewareAddsHeaders() throws {
        var request = URLRequest(url: URL(string: "https://example.com/v1/ping")!)
        try JSONContentTypeMiddleware().prepare(request: &request, context: APIRequest(path: "v1/ping"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), "PsychosocialAnalytics/1.0")
    }

    func testAuthorizationMiddlewareAddsBearerToken() throws {
        var request = URLRequest(url: URL(string: "https://example.com/v1/secure")!)
        let mw = AuthorizationMiddleware(tokenProvider: { "test-token-123" })
        try mw.prepare(request: &request, context: APIRequest(path: "v1/secure"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token-123")
    }

    func testAPIClientPerformsGETAndDecodesResponse() async throws {
        let assessment = TestFixtures.makeAssessment()
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertTrue(request.url?.path.contains("assessments") == true)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, MockBackendResponses.fetchAssessments([assessment]))
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = APIClient(
            baseURL: URL(string: "https://api.test.local")!,
            session: session,
            middleware: [JSONContentTypeMiddleware()]
        )

        let result: FetchAssessmentsResponse = try await client.perform(
            APIRequest(path: "v1/assessments"),
            as: FetchAssessmentsResponse.self
        )
        XCTAssertEqual(result.assessments.count, 1)
    }

    func testAPIClientMapsHTTPError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, Data("unavailable".utf8))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = APIClient(
            baseURL: URL(string: "https://api.test.local")!,
            session: URLSession(configuration: config)
        )

        do {
            let _: FetchAssessmentsResponse = try await client.perform(
                APIRequest(path: "v1/assessments"),
                as: FetchAssessmentsResponse.self
            )
            XCTFail("Expected HTTP error")
        } catch let error as APIClientError {
            if case .httpStatus(let code, _) = error {
                XCTAssertEqual(code, 503)
            } else {
                XCTFail("Unexpected APIClientError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
