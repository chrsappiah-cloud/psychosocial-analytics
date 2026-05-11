//
//  OpenAICompatibleReportGenerator.swift
//  Psychosocial  Analytics
//

import Foundation

enum AIError: LocalizedError {
    case invalidBaseURL
    case missingAPIKey
    case httpError(status: Int, body: String)
    case emptyResponse
    case malformedJSON(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL: "Invalid AI provider base URL."
        case .missingAPIKey: "AI provider API key is not set."
        case .httpError(let status, let body): "AI provider returned HTTP \(status). \(body)"
        case .emptyResponse: "AI provider returned an empty response."
        case .malformedJSON(let detail): "AI response did not match the expected schema. \(detail)"
        }
    }
}

struct OpenAICompatibleReportGenerator: ReportGenerator {
    let configuration: AIProviderConfiguration
    let apiKey: String?

    var modelIdentifier: String { configuration.modelIdentifier }

    func generate(from draft: AssessmentDraft) async throws -> AssessmentReport {
        guard let baseURL = URL(string: configuration.baseURLString) else {
            throw AIError.invalidBaseURL
        }
        guard let apiKey, !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }

        let assessment = makeAssessment(from: draft)
        let prompt = ReportPromptBuilder.build(for: assessment, modelIdentifier: modelIdentifier)
        let endpoint = baseURL.appendingPathComponent("chat/completions")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = configuration.requestTimeoutSeconds
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let systemContent = prompt.system
            + "\n\nReturn ONLY a JSON object matching the following schema. No prose.\nSchema:\n"
            + prompt.jsonSchema

        let body: [String: Any] = [
            "model": modelIdentifier,
            "temperature": configuration.temperature,
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": systemContent],
                ["role": "user", "content": prompt.user]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AIError.emptyResponse }
        guard (200..<300).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "(non-utf8 body)"
            throw AIError.httpError(status: http.statusCode, body: String(bodyText.prefix(400)))
        }

        let chat = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = chat.choices.first?.message.content,
              let contentData = content.data(using: .utf8) else {
            throw AIError.emptyResponse
        }

        let payload: ModelReportPayload
        do {
            payload = try JSONDecoder().decode(ModelReportPayload.self, from: contentData)
        } catch {
            throw AIError.malformedJSON(String(describing: error))
        }

        let risks = RiskDetector.scan(payload: draft.assessmentPayload)

        return AssessmentReport(
            clientName: draft.clientName,
            modelIdentifier: modelIdentifier,
            basicInformationNarrative: payload.basicInformationNarrative,
            backgroundAndFunctioningNarrative: payload.backgroundAndFunctioningNarrative,
            problems: payload.problems,
            contributingFactors: payload.contributingFactors,
            assetsAndResources: payload.assetsAndResources,
            prognosis: payload.prognosis,
            planForIntervention: payload.planForIntervention,
            diagnosticImpressions: payload.diagnosticImpressions,
            goals: payload.goals,
            sectionDrafts: payload.sectionDrafts ?? [:],
            missingInformation: payload.missingInformation,
            riskNotes: risks
        )
    }

    private func makeAssessment(from draft: AssessmentDraft) -> Assessment {
        let payload = draft.assessmentPayload
        let sections = AssessmentSection.allCases.map { section in
            AssessmentSectionPayload(
                id: UUID(),
                section: section,
                answers: payload.answers(for: section),
                completionScore: 0,
                lastEditedAt: draft.updatedAt
            )
        }
        return Assessment(
            id: draft.id,
            organizationID: UUID(),
            createdByUserID: UUID(),
            clientID: UUID(),
            status: draft.status,
            sections: sections,
            riskFlags: payload.riskFlags,
            aiDrafts: [],
            signatures: [],
            createdAt: draft.createdAt,
            updatedAt: draft.updatedAt
        )
    }
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable { let message: Message }
    struct Message: Decodable { let content: String }
}

private struct ModelReportPayload: Decodable {
    let basicInformationNarrative: String
    let backgroundAndFunctioningNarrative: String
    let problems: String
    let contributingFactors: String
    let assetsAndResources: String
    let prognosis: String
    let planForIntervention: String
    let diagnosticImpressions: String?
    let goals: ReportGoalsBlock
    let sectionDrafts: [String: String]?
    let missingInformation: [String]
}
