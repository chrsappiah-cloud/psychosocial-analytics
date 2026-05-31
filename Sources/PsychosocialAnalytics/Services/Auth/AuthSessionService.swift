import Foundation

/// Testable sign-in rules shared by `LoginView` and session bootstrap helpers.
public enum AuthSessionService {
    public static let defaultAdminEmail = "admin@psychosocialanalytics.com"
    public static let defaultAdminPassword = "admin123"

    public static func isValidAdminCredentials(email: String, password: String) -> Bool {
        email.trimmingCharacters(in: .whitespaces).lowercased() == defaultAdminEmail
            && password.trimmingCharacters(in: .whitespaces) == defaultAdminPassword
    }

    public static func resolvedDisplayName(email: String, displayName: String) -> String {
        let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
        guard trimmedName.isEmpty else { return trimmedName }
        return email.components(separatedBy: "@").first ?? "User"
    }

    @MainActor
    public static func signInPublic(
        email: String,
        displayName: String,
        role: AppRole,
        access: AccessControlService
    ) {
        access.configureSession(role: role, isActive: true)
        access.updateEmail(email)
        access.updateDisplayName(resolvedDisplayName(email: email, displayName: displayName))
        access.persistCurrentUser()
    }

    @MainActor
    @discardableResult
    public static func signInAdmin(email: String, password: String, access: AccessControlService) -> Bool {
        guard isValidAdminCredentials(email: email, password: password) else { return false }
        access.promoteToAdministrator()
        access.updateEmail(email.trimmingCharacters(in: .whitespaces).lowercased())
        access.updateDisplayName("Administrator")
        access.persistCurrentUser()
        return true
    }
}
