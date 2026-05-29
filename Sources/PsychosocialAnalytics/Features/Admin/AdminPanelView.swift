import SwiftUI

public struct AdminPanelView: View {
    @StateObject private var access = AccessControlService.shared
    @State private var storageStatuses: [StorageBackendStatus] = []
    @State private var selectedRole: AppRole = .user
    @State private var selectedTier: SubscriptionTier = .professional
    @State private var accountActive = true
    @State private var selectedSection: AdminSection = .overview

    private let storage = StorageCoordinator.makeDefault()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    AppBrandHeader(style: .compact, screenTitle: "Admin Panel")

                    sectionPicker

                    switch selectedSection {
                    case .overview: overviewSection
                    case .access: accessControlSection
                    case .storage: storageSection
                    }
                }
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier("screen_admin_panel")
            .psychosocialScreen()
            .onAppear {
                if let index = UserDefaults.standard.object(forKey: "uitest_admin_section") as? Int,
                   let section = AdminSection.allCases[safe: index] {
                    selectedSection = section
                    UserDefaults.standard.removeObject(forKey: "uitest_admin_section")
                }
            }
            .task {
                storageStatuses = await storage.backendStatuses()
                selectedRole = access.currentUser.role
                selectedTier = access.currentUser.tier
                accountActive = access.currentUser.isActive
            }
        }
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AdminSection.allCases, id: \.self) { section in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSection = section
                        }
                    } label: {
                        Label(section.title, systemImage: section.icon)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedSection == section
                                    ? PremiumTheme.emerald.opacity(0.2)
                                    : PremiumTheme.surface,
                                in: Capsule()
                            )
                            .foregroundStyle(
                                selectedSection == section
                                    ? PremiumTheme.emeraldLight
                                    : PremiumTheme.textSecondary
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedSection == section
                                            ? PremiumTheme.emerald.opacity(0.4)
                                            : PremiumTheme.border,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var overviewSection: some View {
        PremiumTheme.cardStyle {
            VStack(alignment: .leading, spacing: 16) {
                BrandedSectionTitle("Admin Dashboard", subtitle: "System overview")

                HStack(spacing: 12) {
                    StatCard(title: "Users", value: "1", color: PremiumTheme.emerald, icon: "person.2.fill")
                    StatCard(title: "Plan", value: access.currentUser.tier.displayName, color: PremiumTheme.premiumGold, icon: "person.badge.key")
                    StatCard(title: "Storage", value: storageStatuses.filter(\.isConnected).count.formatted(), color: PremiumTheme.info, icon: "externaldrive.fill")
                }

                Divider().overlay(PremiumTheme.border)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Current Session", systemImage: "person.circle")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PremiumTheme.textPrimary)

                    infoRow("User", access.currentUser.displayName)
                    infoRow("Role", access.currentUser.role.displayName)
                    infoRow("Plan", access.currentUser.tier.displayName)
                    infoRow("Status", access.currentUser.isActive ? "Active" : "Inactive")
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var accessControlSection: some View {
        PremiumTheme.cardStyle {
            VStack(alignment: .leading, spacing: 16) {
                BrandedSectionTitle("User Access Control", subtitle: "Manage roles, tiers, and account status")

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Role", systemImage: "person.badge.key")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(PremiumTheme.textSecondary)
                        Picker("Role", selection: $selectedRole) {
                            ForEach(AppRole.allCases, id: \.self) { role in
                                Text(role.displayName).tag(role)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Access Tier", systemImage: "person.badge.key")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(PremiumTheme.textSecondary)
                        Picker("Tier", selection: $selectedTier) {
                            ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                                Text(tier.displayName).tag(tier)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Toggle(isOn: $accountActive) {
                        Label("Account Active", systemImage: accountActive ? "checkmark.shield" : "shield.slash")
                            .foregroundStyle(accountActive ? PremiumTheme.emeraldLight : PremiumTheme.danger)
                    }
                    .tint(PremiumTheme.emerald)

                    Button {
                        access.updateUser(role: selectedRole, tier: selectedTier, isActive: accountActive)
                        AppCoordinator.shared.showNotification("Access settings updated", type: .success)
                    } label: {
                        Label("Apply Access Settings", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .psychosocialPrimaryButton()
                    .accessibilityIdentifier(AccessibilityID.buttonApplyAccess)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var storageSection: some View {
        PremiumTheme.cardStyle {
            VStack(alignment: .leading, spacing: 12) {
                BrandedSectionTitle("Storage Backends", subtitle: "Supabase primary · CloudKit · iCloud · Cloudflare backup")

                ForEach(storageStatuses) { status in
                    HStack {
                        Circle()
                            .fill(status.isConnected ? PremiumTheme.emerald : PremiumTheme.danger)
                            .frame(width: 8, height: 8)
                        Text(status.name)
                            .font(.subheadline)
                            .foregroundStyle(PremiumTheme.textPrimary)
                        Spacer()
                        Text(status.isConnected ? "Connected" : "Offline")
                            .font(.caption)
                            .foregroundStyle(status.isConnected ? PremiumTheme.emeraldLight : PremiumTheme.danger)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(PremiumTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PremiumTheme.textPrimary)
        }
    }
}

public enum AdminSection: String, CaseIterable {
    case overview
    case access
    case storage

    public var title: String {
        switch self {
        case .overview: return "Overview"
        case .access: return "Access"
        case .storage: return "Storage"
        }
    }

    public var icon: String {
        switch self {
        case .overview: return "house"
        case .access: return "person.badge.key"
        case .storage: return "externaldrive"
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
