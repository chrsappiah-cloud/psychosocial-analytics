//
//  SyncBackupPreferencesTests.swift
//  Psychosocial  AnalyticsTests
//

import Testing
@testable import Psychosocial__Analytics

struct SyncBackupPreferencesTests {

    @Test func cloudStatusReflectsEnabledServices() {
        #expect(
            SyncBackupPreferences.cloudStatus(cloudKitEnabled: true, iCloudBackupEnabled: true) ==
            "CloudKit sync is active and iCloud backup recovery is enabled."
        )
        #expect(
            SyncBackupPreferences.cloudStatus(cloudKitEnabled: false, iCloudBackupEnabled: true) ==
            "Running locally with iCloud backup recovery enabled."
        )
    }

    @Test func cloudStatusReflectsStartupFallback() {
        #expect(
            SyncBackupPreferences.cloudStatus(
                cloudKitEnabled: true,
                iCloudBackupEnabled: true,
                startupIssue: "Container unavailable"
            ) ==
            "CloudKit sync could not start, so the app is using on-device storage with iCloud backup recovery enabled."
        )
        #expect(
            SyncBackupPreferences.databaseStatus(
                cloudKitEnabled: true,
                startupIssue: "Container unavailable"
            ) ==
            "On-device SwiftData fallback"
        )
    }

    @Test func backendStatusReflectsProviderRequirements() {
        let local = AIProviderConfiguration(kind: .localDeterministic)
        #expect(
            SyncBackupPreferences.backendStatus(configuration: local, hasAPIKey: false) ==
            "On-device report generation is available."
        )

        let remote = AIProviderConfiguration(kind: .openAICompatible)
        #expect(
            SyncBackupPreferences.backendStatus(configuration: remote, hasAPIKey: false) ==
            "Remote AI endpoint needs an API key."
        )
        #expect(
            SyncBackupPreferences.backendStatus(configuration: remote, hasAPIKey: true) ==
            "Remote AI endpoint is configured."
        )
    }
}
