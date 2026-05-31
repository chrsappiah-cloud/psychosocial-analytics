import Foundation

public enum AccessDeniedReason: String, Error, Sendable {
    case inactiveAccount = "Account is inactive."
    case administratorOnly = "Administrator access required."
    case permissionMissing = "You do not have permission for this action."
}

@MainActor
public final class AccessControlService: ObservableObject {
    public static let shared = AccessControlService()
    public static let savedProfileKey = "saved_user_profile"

    @Published public private(set) var currentUser: AppUserProfile
    @Published public private(set) var permissions: AppPermission

    public init(currentUser: AppUserProfile? = nil) {
        let resolved: AppUserProfile
        if let saved = Self.loadSavedProfile() {
            resolved = saved
        } else if let currentUser {
            resolved = currentUser
        } else {
            resolved = AppUserProfile(
                email: "clinician@psychosocialanalytics.com",
                displayName: "Clinical User",
                role: .user
            )
        }
        self.currentUser = resolved
        self.permissions = Self.permissions(for: resolved)
    }

    public func persistCurrentUser() {
        guard !currentUser.email.isEmpty else { return }
        if let data = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(data, forKey: Self.savedProfileKey)
        }
    }

    public func resetAccountAfterDeletion() {
        UserDefaults.standard.removeObject(forKey: Self.savedProfileKey)
        currentUser = AppUserProfile(
            email: "",
            displayName: "",
            role: .user,
            isActive: true
        )
        permissions = Self.permissions(for: currentUser)
    }

    private static func loadSavedProfile() -> AppUserProfile? {
        guard let data = UserDefaults.standard.data(forKey: savedProfileKey) else { return nil }
        return try? JSONDecoder().decode(AppUserProfile.self, from: data)
    }

    public var isAdministrator: Bool { currentUser.role == .administrator }

    public func can(_ permission: AppPermission) -> Bool {
        guard currentUser.isActive else { return false }
        return permissions.contains(permission)
    }

    public func require(_ permission: AppPermission) throws {
        guard can(permission) else {
            if !currentUser.isActive { throw AccessDeniedReason.inactiveAccount }
            if permission == .manageAccess || permission == .configureStorage {
                throw AccessDeniedReason.administratorOnly
            }
            throw AccessDeniedReason.permissionMissing
        }
    }

    public func updateUser(role: AppRole, isActive: Bool) {
        guard isAdministrator else { return }
        currentUser.role = role
        currentUser.isActive = isActive
        permissions = Self.permissions(for: currentUser)
    }

    public func promoteToAdministrator() {
        currentUser.role = .administrator
        permissions = Self.permissions(for: currentUser)
    }

    public func updateEmail(_ email: String) {
        currentUser.email = email
    }

    public func updateDisplayName(_ name: String) {
        currentUser.displayName = name
    }

    private static func permissions(for user: AppUserProfile) -> AppPermission {
        user.role == .administrator ? .administrator : .standardUser
    }
}
