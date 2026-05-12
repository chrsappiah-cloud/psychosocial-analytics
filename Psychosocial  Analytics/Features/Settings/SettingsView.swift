//
//  SettingsView.swift
//  Psychosocial  Analytics
//

import SwiftUI

struct SettingsView: View {
    static let supportURL = URL(
        string: "https://wcs-full.vercel.app/chrsappiah@gmail.com/christopher.appiahthompson@myworldclass.org"
    )!
    @State private var aiSettings = AIProviderSettings.shared
    @AppStorage(SyncBackupPreferences.cloudKitSyncEnabledKey) private var cloudKitSyncEnabled = true
    @AppStorage(SyncBackupPreferences.iCloudBackupEnabledKey) private var iCloudBackupEnabled = true
    @AppStorage(SyncBackupPreferences.cloudKitStartupIssueKey) private var cloudKitStartupIssue = ""

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

                Section("Sync & Backup") {
                    Toggle("CloudKit Sync", isOn: $cloudKitSyncEnabled)
                    Toggle("iCloud Backup Recovery", isOn: $iCloudBackupEnabled)
                    LabeledContent(
                        "Database",
                        value: SyncBackupPreferences.databaseStatus(
                            cloudKitEnabled: cloudKitSyncEnabled,
                            startupIssue: startupIssue
                        )
                    )
                    Text(SyncBackupPreferences.cloudStatus(
                        cloudKitEnabled: cloudKitSyncEnabled,
                        iCloudBackupEnabled: iCloudBackupEnabled,
                        startupIssue: startupIssue
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    if let startupIssue {
                        Text("Startup note: \(startupIssue)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    Text("Changes to CloudKit sync apply on the next launch because the model container is created at app startup.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Backend") {
                    LabeledContent("Report Engine", value: aiSettings.configuration.kind.displayName)
                    LabeledContent(
                        "Status",
                        value: SyncBackupPreferences.backendStatus(
                            configuration: aiSettings.configuration,
                            hasAPIKey: aiSettings.hasAPIKey
                        )
                    )
                    if aiSettings.configuration.kind == .openAICompatible {
                        LabeledContent("Endpoint", value: aiSettings.configuration.baseURLString)
                    }
                }

                Section("AI Provider") {
                    NavigationLink {
                        AIProviderSettingsView()
                    } label: {
                        LabeledContent("Provider", value: aiSettings.configuration.kind.displayName)
                    }
                    if aiSettings.configuration.kind == .openAICompatible {
                        LabeledContent("Model", value: aiSettings.configuration.modelIdentifier)
                        LabeledContent("API Key",
                                       value: aiSettings.hasAPIKey ? "Stored in Keychain" : "Not set")
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

    private var startupIssue: String? {
        cloudKitStartupIssue.isEmpty ? nil : cloudKitStartupIssue
    }
}

#Preview {
    SettingsView()
}
