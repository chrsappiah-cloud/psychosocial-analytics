import SwiftUI

public struct SettingsView: View {
    @StateObject private var coordinator = AppCoordinator.shared
    @StateObject private var env = AppEnvironment.shared
    @StateObject private var access = AccessControlService.shared
    @State private var showDeleteAccountConfirm = false
    @State private var showDeleteAccountFinalConfirm = false
    @State private var isDeletingAccount = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    AppBrandHeader(style: .compact, screenTitle: "Settings")

                    PremiumTheme.cardStyle {
                        VStack(spacing: 16) {
                            BrandMark(size: 56)
                            Text(AppBrand.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(PremiumTheme.textPrimary)
                                .accessibilityIdentifier(AccessibilityID.appBrandTitle)
                            Text(AppBrand.tagline)
                                .font(.subheadline)
                                .foregroundStyle(PremiumTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            HStack(spacing: 20) {
                                settingsPill("Role", access.currentUser.role.displayName)
                            }
                            HStack(spacing: 20) {
                                settingsPill("Version", appVersion)
                                settingsPill("Build", appBuild)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 16)

                    AdminAccessView()
                        .padding(.horizontal, 16)

                    #if DEBUG
                    PremiumTheme.cardStyle {
                        VStack(alignment: .leading, spacing: 10) {
                            BrandedSectionTitle("Developer")
                            Picker("Environment", selection: Binding(
                                get: { env.current },
                                set: { env.update(to: $0) }
                            )) {
                                Text("Development").tag(EnvironmentType.development)
                                Text("Staging").tag(EnvironmentType.staging)
                                Text("Production").tag(EnvironmentType.production)
                            }
                            Text("API: \(env.apiBaseURL.absoluteString)")
                                .font(.caption)
                                .foregroundStyle(PremiumTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    #endif

                    PremiumTheme.cardStyle {
                        VStack(alignment: .leading, spacing: 12) {
                            BrandedSectionTitle("Account", subtitle: "Manage your session and data on this device")

                            if !access.currentUser.email.isEmpty {
                                HStack {
                                    Label(access.currentUser.displayName, systemImage: "person.circle")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(PremiumTheme.textPrimary)
                                    Spacer()
                                    Text(access.currentUser.role.displayName)
                                        .font(.caption)
                                        .foregroundStyle(PremiumTheme.emeraldLight)
                                }
                                Text(access.currentUser.email)
                                    .font(.caption)
                                    .foregroundStyle(PremiumTheme.textSecondary)
                            }

                            Button(role: .destructive) {
                                withAnimation {
                                    coordinator.signOut()
                                }
                            } label: {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                    .frame(maxWidth: .infinity)
                            }
                            .tint(PremiumTheme.danger)
                            .psychosocialSecondaryButton()

                            Divider().overlay(PremiumTheme.border)

                            Text("Deleting your account permanently removes your profile, assessments, clients, and uploads stored on this device.")
                                .font(.caption)
                                .foregroundStyle(PremiumTheme.textSecondary)

                            Button(role: .destructive) {
                                showDeleteAccountConfirm = true
                            } label: {
                                HStack {
                                    if isDeletingAccount {
                                        ProgressView().tint(PremiumTheme.danger)
                                    }
                                    Label("Delete Account", systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .disabled(isDeletingAccount)
                            .psychosocialSecondaryButton()
                            .accessibilityIdentifier(AccessibilityID.buttonDeleteAccount)
                        }
                    }
                    .padding(.horizontal, 16)
                    .alert("Delete account?", isPresented: $showDeleteAccountConfirm) {
                        Button("Cancel", role: .cancel) {}
                        Button("Continue", role: .destructive) {
                            showDeleteAccountFinalConfirm = true
                        }
                    } message: {
                        Text("This permanently deletes your account and all local app data. This cannot be undone.")
                    }
                    .alert("Confirm permanent deletion", isPresented: $showDeleteAccountFinalConfirm) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete Account", role: .destructive) {
                            performAccountDeletion()
                        }
                    } message: {
                        Text("Your profile, assessments, clients, and uploads on this device will be erased.")
                    }

                    PremiumTheme.cardStyle {
                        VStack(alignment: .leading, spacing: 10) {
                            BrandedSectionTitle("Support")
                            Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                                Label("Privacy policy", systemImage: "hand.raised")
                            }
                            Link(destination: URL(string: "mailto:support@psychosocialanalytics.com")!) {
                                Label("Contact support", systemImage: "envelope")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(AccessibilityID.screenSettings)
            .psychosocialScreen()
        }
    }

    private func settingsPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(PremiumTheme.textTertiary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PremiumTheme.emeraldLight)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(PremiumTheme.surface, in: Capsule())
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private func performAccountDeletion() {
        isDeletingAccount = true
        do {
            try AccountDeletionService.shared.deleteAccount()
        } catch {
            AppCoordinator.shared.showNotification(
                "Could not delete account: \(error.localizedDescription)",
                type: .error
            )
        }
        isDeletingAccount = false
    }
}
