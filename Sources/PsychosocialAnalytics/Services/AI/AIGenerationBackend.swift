import Foundation

public struct GenerateDraftRequest: Codable, Equatable {
    public let assessmentID: UUID
    public let model: AIModel
    public let prompt: String
    public let maxTokens: Int

    public init(assessmentID: UUID, model: AIModel, prompt: String, maxTokens: Int = 2048) {
        self.assessmentID = assessmentID
        self.model = model
        self.prompt = prompt
        self.maxTokens = maxTokens
    }
}

public struct GenerateDraftResponse: Codable, Equatable {
    public let content: String
    public let model: AIModel
    public let confidence: Double
    public let section: AssessmentSection
}

public enum AIGenerationError: Error, Equatable, Sendable {
    case emptyPrompt
    case backendUnavailable(String)
}

/// Remote AI generation API (middleware → backend).
public protocol AIGenerationBackendProtocol: Sendable {
    func generateDraft(
        assessment: Assessment,
        model: AIModel,
        prompt: String
    ) async throws -> GenerateDraftResponse
}

public final class AIGenerationBackendService: AIGenerationBackendProtocol, @unchecked Sendable {
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

    public func generateDraft(
        assessment: Assessment,
        model: AIModel,
        prompt: String
    ) async throws -> GenerateDraftResponse {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIGenerationError.emptyPrompt
        }
        let body = try JSONEncoder().encode(
            GenerateDraftRequest(assessmentID: assessment.id, model: model, prompt: prompt)
        )
        return try await client.perform(
            APIRequest(path: "v1/ai/generate", method: "POST", body: body),
            as: GenerateDraftResponse.self
        )
    }
}

/// In-memory AI backend for tests and offline fallback.
public final class MockAIGenerationBackend: AIGenerationBackendProtocol, @unchecked Sendable {
    public var responseContent = "MOCK AI: Clinical summary generated."
    public var shouldFail = false
    public var lastRequest: GenerateDraftRequest?

    public init() {}

    public func generateDraft(
        assessment: Assessment,
        model: AIModel,
        prompt: String
    ) async throws -> GenerateDraftResponse {
        if shouldFail { throw AIGenerationError.backendUnavailable("mock failure") }
        lastRequest = GenerateDraftRequest(assessmentID: assessment.id, model: model, prompt: prompt)
        return GenerateDraftResponse(
            content: responseContent,
            model: model,
            confidence: 0.88,
            section: .clinicalSummary
        )
    }
}
