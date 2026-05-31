import Foundation

public enum AppRole: String, Codable, CaseIterable, Hashable, Sendable {
    case user
    case administrator

    public var displayName: String {
        switch self {
        case .user: return "Clinician"
        case .administrator: return "Administrator"
        }
    }
}

public struct AppPermission: OptionSet, Codable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let viewDashboard = AppPermission(rawValue: 1 << 0)
    public static let manageClients = AppPermission(rawValue: 1 << 1)
    public static let uploadMedia = AppPermission(rawValue: 1 << 2)
    public static let importFromURL = AppPermission(rawValue: 1 << 3)
    public static let manageAssessments = AppPermission(rawValue: 1 << 4)
    public static let viewReports = AppPermission(rawValue: 1 << 5)
    public static let manageAccess = AppPermission(rawValue: 1 << 6)
    public static let configureStorage = AppPermission(rawValue: 1 << 7)

    public static let standardUser: AppPermission = [
        .viewDashboard, .manageClients, .uploadMedia, .importFromURL,
        .manageAssessments, .viewReports
    ]

    public static let administrator: AppPermission = [
        .viewDashboard, .manageClients, .uploadMedia, .importFromURL,
        .manageAssessments, .viewReports, .manageAccess, .configureStorage
    ]
}

public struct AppUserProfile: Codable, Sendable, Identifiable {
    public let id: UUID
    public var email: String
    public var displayName: String
    public var role: AppRole
    public var isActive: Bool

    public init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        role: AppRole = .user,
        isActive: Bool = true
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.isActive = isActive
    }
}

public struct StorageBackendStatus: Codable, Sendable, Identifiable {
    public let id: String
    public var name: String
    public var isConnected: Bool
    public var lastSync: Date?

    public init(id: String, name: String, isConnected: Bool, lastSync: Date? = nil) {
        self.id = id
        self.name = name
        self.isConnected = isConnected
        self.lastSync = lastSync
    }
}
