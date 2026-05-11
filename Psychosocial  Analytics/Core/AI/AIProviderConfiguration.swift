//
//  AIProviderConfiguration.swift
//  Psychosocial  Analytics
//

import Foundation
import Observation

enum AIProviderKind: String, Codable, CaseIterable, Identifiable {
    case localDeterministic
    case openAICompatible

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .localDeterministic: "Local (deterministic)"
        case .openAICompatible: "OpenAI-compatible"
        }
    }
}

struct AIProviderConfiguration: Codable, Equatable {
    var kind: AIProviderKind = .localDeterministic
    var baseURLString: String = "https://api.openai.com/v1"
    var modelIdentifier: String = "gpt-4o-mini"
    var temperature: Double = 0.2
    var requestTimeoutSeconds: Double = 60
}

@MainActor
@Observable
final class AIProviderSettings {
    static let shared = AIProviderSettings()

    private static let configurationDefaultsKey = "psa_ai_provider_configuration"
    private static let apiKeyKeychainKey = "psa_ai_provider_api_key"

    var configuration: AIProviderConfiguration {
        didSet { persistConfiguration() }
    }

    var apiKey: String? {
        get { KeychainStorage.get(Self.apiKeyKeychainKey) }
        set { KeychainStorage.set(newValue, for: Self.apiKeyKeychainKey) }
    }

    var hasAPIKey: Bool { (apiKey ?? "").isEmpty == false }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.configurationDefaultsKey),
           let decoded = try? JSONDecoder().decode(AIProviderConfiguration.self, from: data) {
            self.configuration = decoded
        } else {
            self.configuration = AIProviderConfiguration()
        }
    }

    private func persistConfiguration() {
        guard let data = try? JSONEncoder().encode(configuration) else { return }
        UserDefaults.standard.set(data, forKey: Self.configurationDefaultsKey)
    }

    func makeGenerator() -> ReportGenerator {
        switch configuration.kind {
        case .localDeterministic:
            return LocalDeterministicReportGenerator()
        case .openAICompatible:
            return OpenAICompatibleReportGenerator(
                configuration: configuration,
                apiKey: apiKey
            )
        }
    }
}
