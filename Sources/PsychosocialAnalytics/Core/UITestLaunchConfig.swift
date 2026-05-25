import Foundation

/// Prepares deterministic data when running XCUITest (`--uitesting`).
@MainActor
public enum UITestLaunchConfig {
    public static func applyIfNeeded() async {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("--uitesting") else { return }

        if args.contains("--skip-login") {
            AccessControlService.shared.promoteToAdministrator()
            AppCoordinator.shared.isAuthenticated = true
            if args.contains("--admin-tab") {
                AppCoordinator.shared.activeTab = .admin
            }
        }

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
