import Foundation
import StoreKit

public enum SubscriptionProductID: String, CaseIterable, Sendable {
    case professionalMonthly = "com.wcs.psychosocial.pro.monthly"
    case professionalYearly = "com.wcs.psychosocial.pro.yearly"
    case enterpriseMonthly = "com.wcs.psychosocial.enterprise.monthly"

    public var tier: SubscriptionTier {
        switch self {
        case .professionalMonthly, .professionalYearly: return .professional
        case .enterpriseMonthly: return .enterprise
        }
    }
}

@MainActor
public final class StoreKitPaymentService: ObservableObject {
    public static let shared = StoreKitPaymentService()

    @Published public private(set) var products: [Product] = []
    @Published public private(set) var purchasedProductIDs: Set<String> = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { await listenForTransactions() }
    }

    deinit { updatesTask?.cancel() }

    public func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let ids = SubscriptionProductID.allCases.map(\.rawValue)
            products = try await Product.products(for: ids).sorted { $0.price < $1.price }
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlements()
            applyTier(for: product.id)
            AppCoordinator.shared.showNotification("Subscription activated", type: .success)
        case .userCancelled:
            break
        case .pending:
            AppCoordinator.shared.showNotification("Purchase pending approval", type: .info)
        @unknown default:
            break
        }
    }

    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            AppCoordinator.shared.showNotification("Purchases restored", type: .success)
        } catch {
            errorMessage = error.localizedDescription
            AppCoordinator.shared.showNotification("Restore failed", type: .error)
        }
    }

    public var activeTier: SubscriptionTier {
        if purchasedProductIDs.contains(where: { $0.contains("enterprise") }) { return .enterprise }
        if purchasedProductIDs.contains(where: { $0.contains("pro") }) { return .professional }
        return AccessControlService.shared.currentUser.tier
    }

    private func refreshEntitlements() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
        if let first = purchased.first {
            applyTier(for: first)
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    private func applyTier(for productID: String) {
        let tier: SubscriptionTier
        if productID.contains("enterprise") {
            tier = .enterprise
        } else if productID.contains("pro") {
            tier = .professional
        } else {
            tier = .free
        }
        let access = AccessControlService.shared
        access.updateUser(role: access.currentUser.role, tier: tier, isActive: true)
    }
}
