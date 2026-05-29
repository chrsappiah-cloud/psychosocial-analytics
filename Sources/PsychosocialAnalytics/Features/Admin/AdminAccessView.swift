import SwiftUI

public struct AdminAccessView: View {
    @StateObject private var access = AccessControlService.shared
    @State private var storageStatuses: [StorageBackendStatus] = []
    @State private var selectedRole: AppRole = .user
    @State private var selectedTier: SubscriptionTier = .professional
    @State private var accountActive = true

    private let storage = StorageCoordinator.makeDefault()

    public init() {}

    public var body: some View {
        Group {
            if access.isAdministrator {
                adminContent
            } else {
                Text("Administrator sign-in required for access controls.")
                    .foregroundStyle(PremiumTheme.textSecondary)
                    .padding()
            }
        }
        .task {
            storageStatuses = await storage.backendStatuses()
            selectedRole = access.currentUser.role
            selectedTier = access.currentUser.tier
            accountActive = access.currentUser.isActive
        }
    }

    private var adminContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            PremiumTheme.cardStyle {
                VStack(alignment: .leading, spacing: 12) {
                    BrandedSectionTitle("User access control")
                    Picker("Role", selection: $selectedRole) {
                        ForEach(AppRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    Picker("Access tier", selection: $selectedTier) {
                        ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                            Text(tier.displayName).tag(tier)
                        }
                    }
                    Toggle("Account active", isOn: $accountActive)
                        .tint(PremiumTheme.emerald)
                    Button("Apply access settings") {
                        access.updateUser(role: selectedRole, tier: selectedTier, isActive: accountActive)
                        AppCoordinator.shared.showNotification("Access settings updated", type: .success)
                    }
                    .psychosocialPrimaryButton()
                    .accessibilityIdentifier(AccessibilityID.buttonApplyAccess)
                }
            }

            PremiumTheme.cardStyle {
                VStack(alignment: .leading, spacing: 10) {
                    BrandedSectionTitle("Storage backends", subtitle: "Supabase primary · CloudKit · iCloud · Cloudflare backup")
                    ForEach(storageStatuses) { status in
                        HStack {
                            Circle()
                                .fill(status.isConnected ? PremiumTheme.emerald : PremiumTheme.danger)
                                .frame(width: 8, height: 8)
                            Text(status.name)
                            Spacer()
                            Text(status.isConnected ? "Connected" : "Offline")
                                .font(.caption)
                                .foregroundStyle(PremiumTheme.textSecondary)
                        }
                    }
                }
            }

            Button("Grant me administrator (debug)") {
                access.promoteToAdministrator()
            }
            .font(.caption)
            .foregroundStyle(PremiumTheme.textTertiary)
        }
    }
}
