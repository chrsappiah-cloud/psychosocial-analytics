import Foundation

/// Auto-navigates the app for App Store screenshot capture (`--screenshot=<mode>`).
@MainActor
public enum ScreenshotLaunchConfig {
    public static func applyIfNeeded(
        coordinator: AppCoordinator = .shared,
        access: AccessControlService = .shared
    ) {
        guard let mode = ProcessInfo.processInfo.arguments
            .first(where: { $0.hasPrefix("--screenshot=") })?
            .replacingOccurrences(of: "--screenshot=", with: ""),
              !mode.isEmpty else { return }

        switch mode {
        case "login":
            coordinator.signOut()
            coordinator.isAuthenticated = false
        case "home":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .dashboard
        case "upload":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .upload
        case "upload-newclient":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .upload
            UserDefaults.standard.set(1, forKey: "uitest_upload_segment")
        case "assess":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .assessments
        case "clients":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .clients
        case "insights":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .analytics
        case "reports":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .reports
        case "settings":
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .settings
        case "admin-overview", "admin-access", "admin-storage":
            signInAdmin(access: access, coordinator: coordinator)
            coordinator.activeTab = .admin
            UserDefaults.standard.set(adminSectionIndex(for: mode), forKey: "uitest_admin_section")
        default:
            signInUser(access: access, coordinator: coordinator)
            coordinator.activeTab = .dashboard
        }
    }

    private static func signInUser(access: AccessControlService, coordinator: AppCoordinator) {
        access.updateEmail("clinician@psychosocialanalytics.com")
        access.updateDisplayName("Clinical User")
        coordinator.isAuthenticated = true
    }

    private static func signInAdmin(access: AccessControlService, coordinator: AppCoordinator) {
        access.promoteToAdministrator()
        access.updateEmail("admin@psychosocialanalytics.com")
        access.updateDisplayName("Administrator")
        coordinator.isAuthenticated = true
    }

    private static func adminSectionIndex(for mode: String) -> Int {
        switch mode {
        case "admin-access": return 1
        case "admin-storage": return 2
        default: return 0
        }
    }
}
