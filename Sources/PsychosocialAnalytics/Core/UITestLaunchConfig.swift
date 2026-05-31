import Foundation

/// Prepares deterministic data when running XCUITest (`--uitesting`).
@MainActor
public enum UITestLaunchConfig {
    /// Synchronous launch setup (auth state) — run before first frame.
    public static func applyLaunchArgumentsIfNeeded() {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("--uitesting") else { return }

        if args.contains("--fresh-auth") {
            UserDefaults.standard.removeObject(forKey: AccessControlService.savedProfileKey)
            AccessControlService.shared.resetAccountAfterDeletion()
            AppCoordinator.shared.signOut()
        }

        if args.contains("--skip-login") {
            AccessControlService.shared.promoteToAdministrator()
            AppCoordinator.shared.isAuthenticated = true
            if args.contains("--admin-tab") {
                AppCoordinator.shared.activeTab = .admin
            }
        }
    }

    public static func applyIfNeeded() async {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("--uitesting") else { return }

        applyLaunchArgumentsIfNeeded()

        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PsychosocialAnalytics", isDirectory: true)
        let assessmentsFile = dir.appendingPathComponent("assessments.json")
        guard FileManager.default.fileExists(atPath: assessmentsFile.path),
              let data = try? Data(contentsOf: assessmentsFile),
              let list = try? JSONDecoder().decode([Assessment].self, from: data),
              list.isEmpty else { return }
        try? FileManager.default.removeItem(at: assessmentsFile)
    }
}
