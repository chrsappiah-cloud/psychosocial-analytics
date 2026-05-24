import Foundation

public struct SyncAssessmentsRequest: Codable {
    public let assessments: [Assessment]
}

public struct SyncAssessmentsResponse: Codable, Equatable {
    public let syncedCount: Int
    public let serverTimestamp: Date
}

public struct FetchAssessmentsResponse: Codable {
    public let assessments: [Assessment]
}

/// Remote API for psychosocial records.
public protocol PsychosocialBackendProtocol: Sendable {
    func fetchAssessments() async throws -> [Assessment]
    func syncAssessments(_ assessments: [Assessment]) async throws -> SyncAssessmentsResponse
}

/// Production-oriented backend using API middleware.
public final class PsychosocialBackendService: PsychosocialBackendProtocol, @unchecked Sendable {
    private let client: APIClientProtocol

    public init(client: APIClientProtocol) {
        self.client = client
    }

    public convenience init(baseURL: URL, tokenProvider: @escaping @Sendable () -> String? = { nil }) {
        let middleware: [any RequestMiddleware] = [
            JSONContentTypeMiddleware(),
            AuthorizationMiddleware(tokenProvider: tokenProvider)
        ]
        self.init(client: APIClient(baseURL: baseURL, middleware: middleware))
    }

    public func fetchAssessments() async throws -> [Assessment] {
        let response: FetchAssessmentsResponse = try await client.perform(
            APIRequest(path: "v1/assessments"),
            as: FetchAssessmentsResponse.self
        )
        return response.assessments
    }

    public func syncAssessments(_ assessments: [Assessment]) async throws -> SyncAssessmentsResponse {
        let body = try JSONEncoder().encode(SyncAssessmentsRequest(assessments: assessments))
        return try await client.perform(
            APIRequest(path: "v1/assessments/sync", method: "POST", body: body),
            as: SyncAssessmentsResponse.self
        )
    }
}

/// In-memory backend for previews and offline demos.
public final class MockPsychosocialBackend: PsychosocialBackendProtocol, @unchecked Sendable {
    private var store: [Assessment]
    private let lock = NSLock()

    public init(seed: [Assessment] = []) {
        self.store = seed
    }

    public func fetchAssessments() async throws -> [Assessment] {
        lock.lock()
        defer { lock.unlock() }
        return store
    }

    public func syncAssessments(_ assessments: [Assessment]) async throws -> SyncAssessmentsResponse {
        lock.lock()
        store = assessments
        lock.unlock()
        return SyncAssessmentsResponse(syncedCount: assessments.count, serverTimestamp: Date())
    }
}
