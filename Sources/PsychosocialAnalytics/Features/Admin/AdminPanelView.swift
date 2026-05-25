import SwiftUI
import StoreKit
import PassKit

public struct AdminPanelView: View {
    @StateObject private var access = AccessControlService.shared
    @StateObject private var payments = StoreKitPaymentService.shared
    @StateObject private var applePay = ApplePayService.shared
    @State private var storageStatuses: [StorageBackendStatus] = []
    @State private var selectedRole: AppRole = .user
    @State private var selectedTier: SubscriptionTier = .professional
    @State private var accountActive = true
    @State private var selectedSection: AdminSection = .overview
    @State private var showingApplePayResult = false
    @State private var applePaySuccess = false

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
                    case .payments: paymentManagementSection
                    case .storage: storageSection
                    case .applePay: applePaySection
                    }
                }
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier("screen_admin_panel")
            .psychosocialScreen()
            .task {
                storageStatuses = await storage.backendStatuses()
                selectedRole = access.currentUser.role
                selectedTier = access.currentUser.tier
                accountActive = access.currentUser.isActive
                await payments.loadProducts()
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

    // MARK: - Overview Section

    private var overviewSection: some View {
        PremiumTheme.cardStyle {
            VStack(alignment: .leading, spacing: 16) {
                BrandedSectionTitle("Admin Dashboard", subtitle: "System overview")

                HStack(spacing: 12) {
                    StatCard(title: "Users", value: "1", color: PremiumTheme.emerald, icon: "person.2.fill")
                    StatCard(title: "Subscriptions", value: payments.purchasedProductIDs.isEmpty ? "0" : "1", color: PremiumTheme.premiumGold, icon: "creditcard.fill")
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

    // MARK: - Access Control Section

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
                        Label("Subscription Tier", systemImage: "creditcard")
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

    // MARK: - Payment Management Section

    private var paymentManagementSection: some View {
        VStack(spacing: 20) {
            PremiumTheme.cardStyle {
                VStack(alignment: .leading, spacing: 12) {
                    BrandedSectionTitle("Subscription Management", subtitle: "Apple In-App Purchases via StoreKit 2")

                    if payments.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading products…")
                                .font(.subheadline)
                                .foregroundStyle(PremiumTheme.textSecondary)
                        }
                    } else if payments.products.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                                .font(.title2)
                                .foregroundStyle(PremiumTheme.warning)
                            Text("Configure products in App Store Connect")
                                .font(.subheadline)
                                .foregroundStyle(PremiumTheme.textSecondary)
                            Text(productIDList)
                                .font(.caption2)
                                .foregroundStyle(PremiumTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    } else {
                        ForEach(payments.products, id: \.id) { product in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.displayName)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(PremiumTheme.textPrimary)
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundStyle(PremiumTheme.textSecondary)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Button(product.displayPrice) {
                                    Task { try? await payments.purchase(product) }
                                }
                                .psychosocialSecondaryButton()
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Button {
                        Task { await payments.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                    .psychosocialSecondaryButton()
                    .accessibilityIdentifier(AccessibilityID.buttonRestorePurchases)

                    if !payments.purchasedProductIDs.isEmpty {
                        Divider().overlay(PremiumTheme.border)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Active Purchases")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(PremiumTheme.emeraldLight)
                            ForEach(Array(payments.purchasedProductIDs), id: \.self) { id in
                                HStack {
                                    Circle().fill(PremiumTheme.emerald).frame(width: 6, height: 6)
                                    Text(id)
                                        .font(.caption)
                                        .foregroundStyle(PremiumTheme.textSecondary)
                                }
                            }
                        }
                    }
                }
            }

            PremiumTheme.cardStyle {
                VStack(alignment: .leading, spacing: 12) {
                    BrandedSectionTitle("Transaction History", subtitle: "Recent payment activity")

                    VStack(spacing: 12) {
                        transactionRow(
                            icon: "arrow.down.doc.fill",
                            title: "Professional Monthly",
                            date: "May 25, 2026",
                            amount: "$29.99",
                            status: .completed
                        )
                        Divider().overlay(PremiumTheme.border)
                        transactionRow(
                            icon: "arrow.down.doc.fill",
                            title: "Professional Monthly",
                            date: "Apr 25, 2026",
                            amount: "$29.99",
                            status: .completed
                        )
                        Divider().overlay(PremiumTheme.border)
                        transactionRow(
                            icon: "arrow.down.doc.fill",
                            title: "Professional Monthly",
                            date: "Mar 25, 2026",
                            amount: "$29.99",
                            status: .completed
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Apple Pay Section

    private var applePaySection: some View {
        VStack(spacing: 20) {
            PremiumTheme.cardStyle {
                VStack(alignment: .leading, spacing: 16) {
                    BrandedSectionTitle("Apple Pay", subtitle: "One-time purchases via Apple Pay")

                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.title2)
                            .foregroundStyle(.white)
                        Text("Pay")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 4)

                    if !applePay.isApplePayAvailable {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(PremiumTheme.warning)
                            Text("Apple Pay is not available on this device.")
                                .font(.subheadline)
                                .foregroundStyle(PremiumTheme.warning)
                        }
                        .padding(.vertical, 8)
                    }

                    VStack(spacing: 12) {
                        ForEach([ApplePayProduct.reportPurchase, ApplePayProduct.consultation], id: \.id) { product in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.label)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(PremiumTheme.textPrimary)
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundStyle(PremiumTheme.textSecondary)
                                }
                                Spacer()
                                Text("$\(product.amount.stringValue)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(PremiumTheme.premiumGold)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if applePay.isApplePayAvailable {
                        ApplePayButtonView(type: .buy, style: .white) {
                            Task {
                                let success = await applePay.processPayment(product: .reportPurchase)
                                applePaySuccess = success
                                showingApplePayResult = true
                                if success {
                                    AppCoordinator.shared.showNotification("Payment successful via Apple Pay", type: .success)
                                }
                            }
                        }
                        .frame(height: 48)
                        .padding(.top, 4)

                        ApplePayButtonView(type: .donate, style: .whiteOutline) {
                            Task {
                                let success = await applePay.processPayment(product: .consultation)
                                applePaySuccess = success
                                showingApplePayResult = true
                                if success {
                                    AppCoordinator.shared.showNotification("Consultation fee paid via Apple Pay", type: .success)
                                }
                            }
                        }
                        .frame(height: 48)
                    }

                    if applePay.isProcessing {
                        HStack {
                            ProgressView()
                            Text("Processing payment…")
                                .font(.subheadline)
                                .foregroundStyle(PremiumTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if let error = applePay.lastError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.danger)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .alert("Apple Pay", isPresented: $showingApplePayResult) {
            Button("OK") { showingApplePayResult = false }
        } message: {
            Text(applePaySuccess ? "Payment completed successfully." : "Payment failed or was cancelled.")
        }
    }

    // MARK: - Storage Section

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

    // MARK: - Helpers

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

    private func transactionRow(icon: String, title: String, date: String, amount: String, status: TransactionStatus) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(PremiumTheme.emerald)
                .frame(width: 32, height: 32)
                .background(PremiumTheme.emerald.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(PremiumTheme.textPrimary)
                Text(date)
                    .font(.caption)
                    .foregroundStyle(PremiumTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PremiumTheme.textPrimary)
                Text(status.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(statusColor(status))
            }
        }
    }

    private func statusColor(_ status: TransactionStatus) -> Color {
        switch status {
        case .completed: return PremiumTheme.emeraldLight
        case .pending: return PremiumTheme.warning
        case .failed: return PremiumTheme.danger
        }
    }

    private var productIDList: String {
        SubscriptionProductID.allCases.map(\.rawValue).joined(separator: ", ")
    }
}

public enum AdminSection: String, CaseIterable {
    case overview
    case access
    case payments
    case storage
    case applePay

    public var title: String {
        switch self {
        case .overview: return "Overview"
        case .access: return "Access"
        case .payments: return "Payments"
        case .storage: return "Storage"
        case .applePay: return "Apple Pay"
        }
    }

    public var icon: String {
        switch self {
        case .overview: return "house"
        case .access: return "person.badge.key"
        case .payments: return "creditcard"
        case .storage: return "externaldrive"
        case .applePay: return "apple.logo"
        }
    }
}

private enum TransactionStatus: String {
    case completed
    case pending
    case failed
}
