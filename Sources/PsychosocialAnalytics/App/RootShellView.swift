import SwiftUI

public struct RootShellView: View {
    @StateObject private var coordinator = AppCoordinator.shared

    public init() {}

    public var body: some View {
        ZStack {
            AmbientBackground()

            TabView(selection: $coordinator.activeTab) {
                tab(DashboardView(), .dashboard)
                tab(AssessmentListView(), .assessments)
                tab(ClientsView(), .clients)
                tab(UploadHubView(), .upload)
                tab(AnalyticsView(), .analytics)
                tab(ReportsView(), .reports)
                tab(SettingsView(), .settings)
            }
            .tint(PremiumTheme.emerald)

            if let message = coordinator.notificationMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: notificationIcon)
                            .font(.subheadline.weight(.semibold))
                        Text(message)
                            .font(.subheadline.weight(.medium))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(notificationBackground, in: Capsule())
                    .foregroundStyle(PremiumTheme.textPrimary)
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 92)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .accessibilityAddTraits(.isModal)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var notificationIcon: String {
        switch coordinator.notificationType {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var notificationBackground: Color {
        switch coordinator.notificationType {
        case .success: return PremiumTheme.emerald.opacity(0.94)
        case .error: return PremiumTheme.danger.opacity(0.94)
        case .warning: return PremiumTheme.warning.opacity(0.94)
        case .info: return PremiumTheme.surfaceElevated
        }
    }

    @ViewBuilder
    private func tab<V: View>(_ view: V, _ tab: AppTab) -> some View {
        view
            .accessibilityIdentifier(tab.accessibilityID)
            .tabItem { Label(tab.title, systemImage: tab.icon) }
            .tag(tab)
    }
}
