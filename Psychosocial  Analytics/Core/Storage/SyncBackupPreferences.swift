//
//  SyncBackupPreferences.swift
//  Psychosocial  Analytics
//

import Foundation

enum SyncBackupPreferences {
    static let selectedTabKey = "psa_selected_tab"
    static let cloudKitSyncEnabledKey = "psa_cloudkit_sync_enabled"
    static let iCloudBackupEnabledKey = "psa_icloud_backup_enabled"
    static let cloudKitStartupIssueKey = "psa_cloudkit_startup_issue"

    static func requestedCloudKitSyncEnabled(userDefaults: UserDefaults = .standard) -> Bool {
        userDefaults.object(forKey: cloudKitSyncEnabledKey) as? Bool ?? true
    }

    static func recordCloudKitStartupIssue(_ issue: String?, userDefaults: UserDefaults = .standard) {
        guard let issue, !issue.isEmpty else {
            userDefaults.removeObject(forKey: cloudKitStartupIssueKey)
            return
        }
        userDefaults.set(issue, forKey: cloudKitStartupIssueKey)
    }

    static func cloudStatus(
        cloudKitEnabled: Bool,
        iCloudBackupEnabled: Bool,
        startupIssue: String? = nil
    ) -> String {
        if cloudKitEnabled, startupIssue != nil {
            return iCloudBackupEnabled
                ? "CloudKit sync could not start, so the app is using on-device storage with iCloud backup recovery enabled."
                : "CloudKit sync could not start, so the app is using on-device storage only for this launch."
        }

        return switch (cloudKitEnabled, iCloudBackupEnabled) {
        case (true, true):
            "CloudKit sync is active and iCloud backup recovery is enabled."
        case (true, false):
            "CloudKit sync is active. iCloud backup recovery is paused."
        case (false, true):
            "Running locally with iCloud backup recovery enabled."
        case (false, false):
            "Running locally with cloud backup features paused."
        }
    }

    static func databaseStatus(cloudKitEnabled: Bool, startupIssue: String? = nil) -> String {
        if cloudKitEnabled, startupIssue != nil {
            return "On-device SwiftData fallback"
        }
        return cloudKitEnabled ? "CloudKit-backed SwiftData" : "On-device SwiftData only"
    }

    static func backendStatus(configuration: AIProviderConfiguration, hasAPIKey: Bool) -> String {
        switch configuration.kind {
        case .localDeterministic:
            "On-device report generation is available."
        case .openAICompatible:
            hasAPIKey ? "Remote AI endpoint is configured." : "Remote AI endpoint needs an API key."
        }
    }
}
