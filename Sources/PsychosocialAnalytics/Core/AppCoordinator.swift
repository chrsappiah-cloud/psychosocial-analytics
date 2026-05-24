import SwiftUI

public enum AppTab: String, CaseIterable {
    case dashboard
    case assessments
    case clients
    case upload
    case analytics
    case reports
    case settings
    
    /// Short, legible labels for the tab bar.
    public var title: String {
        switch self {
        case .dashboard: return "Home"
        case .assessments: return "Assess"
        case .clients: return "Clients"
        case .upload: return "Upload"
        case .analytics: return "Insights"
        case .reports: return "Reports"
        case .settings: return "Settings"
        }
    }
    
    public var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .assessments: return "doc.text"
        case .clients: return "person.2"
        case .upload: return "arrow.up.doc.fill"
        case .analytics: return "chart.bar"
        case .reports: return "list.bullet.rectangle"
        case .settings: return "gearshape"
        }
    }

    public var accessibilityID: String {
        switch self {
        case .dashboard: return AccessibilityID.tabHome
        case .assessments: return AccessibilityID.tabAssess
        case .clients: return AccessibilityID.tabClients
        case .upload: return AccessibilityID.tabUpload
        case .analytics: return AccessibilityID.tabInsights
        case .reports: return AccessibilityID.tabReports
        case .settings: return AccessibilityID.tabSettings
        }
    }
}

public enum NotificationType {
    case success, error, warning, info
}

@MainActor
public class AppCoordinator: ObservableObject {
    public static let shared = AppCoordinator()
    
    @Published public var activeTab: AppTab = .dashboard
    @Published public var notificationMessage: String?
    @Published public var notificationType: NotificationType = .info
    @Published public var isCommandCenterOpen: Bool = false
    
    private init() {}
    
    public func showNotification(_ message: String, type: NotificationType = .info) {
        notificationMessage = message
        notificationType = type
        
        Task {
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            if notificationMessage == message {
                withAnimation {
                    notificationMessage = nil
                }
            }
        }
    }
}
