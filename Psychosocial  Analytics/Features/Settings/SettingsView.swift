//
//  SettingsView.swift
//  Psychosocial  Analytics
//

import SwiftUI

struct SettingsView: View {
    static let supportURL = URL(
        string: "https://wcs-full.vercel.app/chrsappiah@gmail.com/christopher.appiahthompson@myworldclass.org"
    )!

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    LabeledContent("Role", value: UserRole.socialWorker.displayName)
                    LabeledContent("Subscription", value: "Trial")
                }

                Section("Organization") {
                    LabeledContent("Plan", value: "Starter")
                    LabeledContent("Seats", value: "1")
                }

                Section("AI Provider") {
                    NavigationLink {
                        AIProviderSettingsView()
                    } label: {
                        LabeledContent("Provider", value: AIProviderSettings.shared.configuration.kind.displayName)
                    }
                    if AIProviderSettings.shared.configuration.kind == .openAICompatible {
                        LabeledContent("Model", value: AIProviderSettings.shared.configuration.modelIdentifier)
                        LabeledContent("API Key",
                                       value: AIProviderSettings.shared.hasAPIKey ? "Stored in Keychain" : "Not set")
                    }
                    Text("AI-generated content always requires human review before signature or export.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Help & Support") {
                    Link(destination: SettingsView.supportURL) {
                        HStack {
                            Image(systemName: "lifepreserver")
                                .foregroundStyle(Color.emeraldAction)
                            Text("Contact Support")
                        }
                    }
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }
}

#Preview {
    SettingsView()
}
