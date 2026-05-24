import Foundation
@testable import PsychosocialAnalytics

// MARK: - Test fixtures

final class Box<T> {
    var value: T?
}

enum TestSupport {
    static func readHTTPBody(from stream: InputStream?) -> Data? {
        guard let stream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data.isEmpty ? nil : data
    }
}

enum TestFixtures {
    static func makeAssessment(status: AssessmentStatus = .draft) -> Assessment {
        Assessment(
            id: UUID(),
            organizationID: UUID(),
            createdByUserID: UUID(),
            clientID: UUID(),
            status: status,
            sections: [],
            riskFlags: [],
            aiDrafts: [],
            signatures: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func tempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PsychosocialAnalyticsTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func makeRepository() throws -> AssessmentRepository {
        let dir = try tempDirectory()
        let database = try LocalDatabase(directory: dir)
        return AssessmentRepository(database: database, backend: MockPsychosocialBackend())
    }
}

// MARK: - Mocks

final class MockGenAIService: GenAIServiceProtocol, @unchecked Sendable {
    var result = AIGenerationResult(
        content: "E2E CLINICAL SUMMARY: Client stable.",
        model: .gpt4o,
        confidence: 0.9,
        section: .clinicalSummary
    )
    var shouldFail = false

    func generateReportDraft(for assessment: Assessment, model: AIModel?) async throws -> AIGenerationResult {
        if shouldFail { throw APIClientError.transport("mock failure") }
        if let model {
            return AIGenerationResult(
                content: result.content,
                model: model,
                confidence: result.confidence,
                section: result.section
            )
        }
        return result
    }
}

/// Stub URL protocol for middleware/backend integration tests.
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: APIClientError.transport("no handler"))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}

enum MockBackendResponses {
    static func fetchAssessments(_ items: [Assessment]) -> Data {
        try! JSONEncoder().encode(FetchAssessmentsResponse(assessments: items))
    }

    static func syncAssessments(count: Int) -> Data {
        try! JSONEncoder().encode(
            SyncAssessmentsResponse(syncedCount: count, serverTimestamp: Date(timeIntervalSince1970: 1_700_000_000))
        )
    }

    static let generateDraftContent = "BACKEND AI: Clinical summary with strengths and goals."

    static func generateDraft(model: AIModel = .gpt4o) -> Data {
        try! JSONEncoder().encode(
            GenerateDraftResponse(
                content: generateDraftContent,
                model: model,
                confidence: 0.92,
                section: .clinicalSummary
            )
        )
    }
}
