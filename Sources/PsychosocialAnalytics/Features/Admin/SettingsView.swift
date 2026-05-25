import SwiftUI
import StoreKit

public struct SettingsView: View {
    @StateObject private var coordinator = AppCoordinator.shared
    @StateObject private var env = AppEnvironment.shared
    @StateObject private var access = AccessControlService.shared
    @StateObject private var payments = StoreKitPaymentService.shared

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
                                settingsPill("Plan", access.currentUser.tier.displayName)
                            }
                            HStack(spacing: 20) {
                                settingsPill("Version", appVersion)
                                settingsPill("Build", appBuild)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 16)

                    subscriptionSection
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
                            BrandedSectionTitle("Session")
                            HStack {
                                Label(access.currentUser.displayName, systemImage: "person.circle")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(PremiumTheme.textPrimary)
                                Spacer()
                                Text(access.currentUser.role.displayName)
                                    .font(.caption)
                                    .foregroundStyle(PremiumTheme.emeraldLight)
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
                        }
                    }
                    .padding(.horizontal, 16)

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
            .task { await payments.loadProducts() }
        }
    }

    private var subscriptionSection: some View {
        PremiumTheme.cardStyle {
            VStack(alignment: .leading, spacing: 12) {
                BrandedSectionTitle("Subscription", subtitle: "Apple In-App Purchase")
                if payments.products.isEmpty {
                    Text("Loading App Store products…")
                        .font(.caption)
                        .foregroundStyle(PremiumTheme.textSecondary)
                } else {
                    ForEach(payments.products, id: \.id) { product in
                        Button {
                            Task { try? await payments.purchase(product) }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                            }
                        }
                        .psychosocialSecondaryButton()
                    }
                }
                Button("Restore purchases") {
                    Task { await payments.restorePurchases() }
                }
                .accessibilityIdentifier(AccessibilityID.buttonRestorePurchases)
                .psychosocialSecondaryButton()
            }
        }
        .padding(.horizontal, 16)
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
}
