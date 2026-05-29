import Foundation

public enum AccountDeletionError: Error, LocalizedError, Sendable {
    case wipeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .wipeFailed(let message): return message
        }
    }
}

/// Permanently deletes the on-device account and all associated local data (Guideline 5.1.1(v)).
@MainActor
public final class AccountDeletionService {
    public static let shared = AccountDeletionService()

    private init() {}

    public func deleteAccount(
        access: AccessControlService = .shared,
        coordinator: AppCoordinator = .shared
    ) throws {
        try wipeLocalAppData()
        access.resetAccountAfterDeletion()
        coordinator.signOut()
        coordinator.showNotification("Your account and local data have been deleted.", type: .success)
    }

    private func wipeLocalAppData() throws {
        let fileManager = FileManager.default
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appRoot = support.appendingPathComponent("PsychosocialAnalytics", isDirectory: true)

        if fileManager.fileExists(atPath: appRoot.path) {
            try fileManager.removeItem(at: appRoot)
        }

        for key in Self.userDefaultsKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static let userDefaultsKeys = [
        AccessControlService.savedProfileKey,
        "uitest_upload_segment",
        "uitest_admin_section",
    ]
}
