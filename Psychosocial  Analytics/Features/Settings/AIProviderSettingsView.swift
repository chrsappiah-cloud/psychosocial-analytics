//
//  AIProviderSettingsView.swift
//  Psychosocial  Analytics
//

import SwiftUI

struct AIProviderSettingsView: View {
    @State private var settings = AIProviderSettings.shared
    @State private var apiKeyInput: String = ""
    @State private var apiKeyHidden: Bool = true
    @State private var savedConfirmation: Bool = false

    var body: some View {
        Form {
            Section("Generator") {
                Picker("Provider", selection: providerKindBinding) {
                    ForEach(AIProviderKind.allCases) { kind in
                        Text(kind.displayName).tag(kind)
                    }
                }
                .pickerStyle(.menu)

                Text(generatorExplanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if settings.configuration.kind == .openAICompatible {
                Section("Endpoint") {
                    TextField("Base URL", text: baseURLBinding)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    TextField("Model identifier", text: modelBinding)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Stepper(value: temperatureBinding, in: 0...1, step: 0.1) {
                        Text("Temperature: \(settings.configuration.temperature, specifier: "%.1f")")
                    }
                }

                Section {
                    HStack {
                        if apiKeyHidden {
                            SecureField("Bearer token", text: $apiKeyInput)
                        } else {
                            TextField("Bearer token", text: $apiKeyInput)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        Button { apiKeyHidden.toggle() } label: {
                            Image(systemName: apiKeyHidden ? "eye" : "eye.slash")
                        }
                        .buttonStyle(.borderless)
                    }
                    Button("Save Key to Keychain") { saveKey() }
                        .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        .tint(.emeraldAction)
                    if savedConfirmation {
                        Label("Saved", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Color.emeraldAction)
                            .font(.caption)
                    }
                    if settings.hasAPIKey {
                        Label("API key stored in Keychain", systemImage: "lock.fill")
                            .foregroundStyle(Color.emeraldAction)
                            .font(.caption)
                        Button("Remove Key", role: .destructive) {
                            settings.apiKey = nil
                            apiKeyInput = ""
                        }
                    }
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Keys are stored using the iOS Keychain with kSecAttrAccessibleAfterFirstUnlock. Keys are never written to UserDefaults or logs.")
                        .font(.caption)
                }
            }

            Section("Compliance") {
                Text("All AI-generated content is treated as draft and requires clinician review before signature or export.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("AI Provider")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var generatorExplanation: String {
        switch settings.configuration.kind {
        case .localDeterministic:
            return "Synthesizes the report on-device from the captured answers. No network call. Always available."
        case .openAICompatible:
            return "Sends the structured prompt to an OpenAI-compatible /chat/completions endpoint (OpenAI, vLLM, Ollama, OpenRouter, or your own proxy)."
        }
    }

    private func saveKey() {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        settings.apiKey = trimmed
        apiKeyInput = ""
        savedConfirmation = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            savedConfirmation = false
        }
    }

    private var providerKindBinding: Binding<AIProviderKind> {
        Binding(
            get: { settings.configuration.kind },
            set: { settings.configuration.kind = $0 }
        )
    }

    private var baseURLBinding: Binding<String> {
        Binding(
            get: { settings.configuration.baseURLString },
            set: { settings.configuration.baseURLString = $0 }
        )
    }

    private var modelBinding: Binding<String> {
        Binding(
            get: { settings.configuration.modelIdentifier },
            set: { settings.configuration.modelIdentifier = $0 }
        )
    }

    private var temperatureBinding: Binding<Double> {
        Binding(
            get: { settings.configuration.temperature },
            set: { settings.configuration.temperature = $0 }
        )
    }
}

#Preview {
    NavigationStack { AIProviderSettingsView() }
}
