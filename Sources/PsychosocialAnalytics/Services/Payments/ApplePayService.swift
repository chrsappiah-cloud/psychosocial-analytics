import Foundation
import PassKit
import SwiftUI

public struct ApplePayProduct: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let amount: NSDecimalNumber
    public let description: String

    public init(id: String, label: String, amount: NSDecimalNumber, description: String) {
        self.id = id
        self.label = label
        self.amount = amount
        self.description = description
    }

    public static let reportPurchase = ApplePayProduct(
        id: "com.wcs.psychosocial.report",
        label: "Single Report",
        amount: NSDecimalNumber(string: "9.99"),
        description: "One-time purchase of a single psychosocial report"
    )

    public static let consultation = ApplePayProduct(
        id: "com.wcs.psychosocial.consultation",
        label: "Consultation Fee",
        amount: NSDecimalNumber(string: "49.99"),
        description: "One-time clinical consultation fee"
    )
}

@MainActor
public final class ApplePayService: NSObject, ObservableObject {
    public static let shared = ApplePayService()

    @Published public private(set) var isApplePayAvailable = false
    @Published public private(set) var isProcessing = false
    @Published public private(set) var lastError: String?

    private var currentCompletion: ((Bool) -> Void)?

    override private init() {
        super.init()
        isApplePayAvailable = PKPaymentAuthorizationController.canMakePayments()
    }

    public func canMakePayments(usingNetworks networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)
    }

    public func processPayment(
        product: ApplePayProduct,
        merchantIdentifier: String = "merchant.com.wcs.psychosocialanalytics"
    ) async -> Bool {
        guard isApplePayAvailable else {
            lastError = "Apple Pay is not available on this device."
            return false
        }

        isProcessing = true
        lastError = nil

        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"

        let item = PKPaymentSummaryItem(label: product.label, amount: product.amount)
        request.paymentSummaryItems = [item]

        return await withCheckedContinuation { continuation in
            self.currentCompletion = { success in
                self.isProcessing = false
                continuation.resume(returning: success)
            }

            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            controller.delegate = self
            controller.present { presented in
                if !presented {
                    self.isProcessing = false
                    self.lastError = "Failed to present Apple Pay."
                    self.currentCompletion?(false)
                    self.currentCompletion = nil
                }
            }
        }
    }
}

extension ApplePayService: PKPaymentAuthorizationControllerDelegate {
    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }

    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        currentCompletion?(true)
        currentCompletion = nil
    }
}

public struct ApplePayButtonView: UIViewRepresentable {
    public let type: PKPaymentButtonType
    public let style: PKPaymentButtonStyle
    public let action: () -> Void

    public init(
        type: PKPaymentButtonType = .buy,
        style: PKPaymentButtonStyle = .white,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.style = style
        self.action = action
    }

    public func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: style)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        button.cornerRadius = 12
        return button
    }

    public func updateUIView(_ uiView: PKPaymentButton, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    public class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func didTap() { action() }
    }
}
