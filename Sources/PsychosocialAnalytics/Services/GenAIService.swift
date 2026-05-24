import Foundation

public enum AIModel: String, Codable, CaseIterable {
    case llama3Instruct = "llama-3.1-instruct"
    case gpt4o = "gpt-4o"
}

public struct AIRequest: Codable, Equatable {
    public let model: AIModel
    public let prompt: String
    public let maxTokens: Int
}

public struct AIResponse: Codable, Equatable {
    public let content: String
}

public struct AIGenerationResult: Equatable, Sendable {
    public let content: String
    public let model: AIModel
    public let confidence: Double
    public let section: AssessmentSection
}

public protocol GenAIServiceProtocol: Sendable {
    func generateReportDraft(for assessment: Assessment, model: AIModel?) async throws -> AIGenerationResult
}

public enum GenAIServiceMode: Sendable {
    case localMock(simulatedLatencyNanoseconds: UInt64 = 0)
    case remote(AIGenerationBackendProtocol)
}

/// Coordinates prompt building, local mock generation, and remote AI API calls.
public final class GenAIService: GenAIServiceProtocol, @unchecked Sendable {
    private let mode: GenAIServiceMode
    private let promptBuilder: AssessmentPromptBuilder
    private let defaultModel: AIModel

    public init(
        mode: GenAIServiceMode = .localMock(simulatedLatencyNanoseconds: 0),
        promptBuilder: AssessmentPromptBuilder = AssessmentPromptBuilder(),
        defaultModel: AIModel = .gpt4o
    ) {
        self.mode = mode
        self.promptBuilder = promptBuilder
        self.defaultModel = defaultModel
    }

    public convenience init(backend: AIGenerationBackendProtocol, defaultModel: AIModel = .gpt4o) {
        self.init(mode: .remote(backend), defaultModel: defaultModel)
    }

    public convenience init(simulatedLatencyNanoseconds: UInt64 = 2_000_000_000) {
        self.init(mode: .localMock(simulatedLatencyNanoseconds: simulatedLatencyNanoseconds))
    }

    /// Factory respecting launch arguments (`--ai-fast`, `--uitesting`).
    public static func forApp() -> GenAIService {
        let args = ProcessInfo.processInfo.arguments
        let fast = args.contains("--ai-fast") || args.contains("--uitesting")
        return GenAIService(simulatedLatencyNanoseconds: fast ? 0 : 2_000_000_000)
    }

    public func generateReportDraft(
        for assessment: Assessment,
        model: AIModel? = nil
    ) async throws -> AIGenerationResult {
        let selectedModel = model ?? defaultModel
        let prompt = promptBuilder.buildPrompt(for: assessment)

        switch mode {
        case .localMock(let latency):
            if latency > 0 { try await Task.sleep(nanoseconds: latency) }
            return AIGenerationResult(
                content: localMockContent(assessment: assessment),
                model: selectedModel,
                confidence: 0.75,
                section: .clinicalSummary
            )
        case .remote(let backend):
            let response = try await backend.generateDraft(
                assessment: assessment,
                model: selectedModel,
                prompt: prompt
            )
            return AIGenerationResult(
                content: response.content,
                model: response.model,
                confidence: response.confidence,
                section: response.section
            )
        }
    }

    private func localMockContent(assessment: Assessment) -> String {
        let sectionCount = assessment.sections.filter { $0.completionScore > 0 }.count
        return """
        CLINICAL SUMMARY:
        Client presents with complex psychosocial needs based on \(sectionCount) completed section(s).

        STRENGTHS SUMMARY:
        Resilient family support and strong vocational history.

        GOALS & RECOMMENDATIONS:
        1. Engage in cognitive behavioral therapy.
        2. Vocational training for re-employment.
        """
    }
}
