import Foundation

public enum AccessDeniedReason: String, Error, Sendable {
    case inactiveAccount = "Account is inactive."
    case subscriptionRequired = "An active subscription is required."
    case administratorOnly = "Administrator access required."
    case permissionMissing = "You do not have permission for this action."
}

@MainActor
public final class AccessControlService: ObservableObject {
    public static let shared = AccessControlService()

    @Published public private(set) var currentUser: AppUserProfile
    @Published public private(set) var permissions: AppPermission

    public init(
        currentUser: AppUserProfile = AppUserProfile(
            email: "clinician@psychosocialanalytics.com",
            displayName: "Clinical User",
            role: .user,
            tier: .professional
        )
    ) {
        self.currentUser = currentUser
        self.permissions = Self.permissions(for: currentUser)
    }

    public var isAdministrator: Bool { currentUser.role == .administrator }

    public func can(_ permission: AppPermission) -> Bool {
        guard currentUser.isActive else { return false }
        if permission == .uploadMedia || permission == .importFromURL {
            guard currentUser.tier.allowsUploads || isAdministrator else { return false }
        }
        return permissions.contains(permission)
    }

    public func require(_ permission: AppPermission) throws {
        guard can(permission) else {
            if !currentUser.isActive { throw AccessDeniedReason.inactiveAccount }
            if (permission == .uploadMedia || permission == .importFromURL), !currentUser.tier.allowsUploads {
                throw AccessDeniedReason.subscriptionRequired
            }
            if permission == .manageAccess || permission == .managePayments || permission == .configureStorage {
                throw AccessDeniedReason.administratorOnly
            }
            throw AccessDeniedReason.permissionMissing
        }
    }

    public func updateUser(role: AppRole, tier: SubscriptionTier, isActive: Bool) {
        guard isAdministrator else { return }
        currentUser.role = role
        currentUser.tier = tier
        currentUser.isActive = isActive
        permissions = Self.permissions(for: currentUser)
    }

    public func promoteToAdministrator() {
        currentUser.role = .administrator
        currentUser.tier = .enterprise
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
