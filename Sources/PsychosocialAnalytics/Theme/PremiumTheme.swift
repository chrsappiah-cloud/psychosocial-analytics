import SwiftUI

/// Dark, high-contrast palette tuned for clinical workflows and App Store distribution.
public struct PremiumTheme {
    // MARK: - Surfaces
    public static let background = Color(red: 0.07, green: 0.08, blue: 0.10)
    public static let surface = Color(red: 0.12, green: 0.14, blue: 0.17)
    public static let surfaceElevated = Color(red: 0.16, green: 0.18, blue: 0.22)
    public static let border = Color.white.opacity(0.12)

    // Legacy aliases (kept for gradual migration)
    public static let pearlWhite = surfaceElevated
    public static let pearlGray = background

    // MARK: - Text
    public static let textPrimary = Color(red: 0.96, green: 0.97, blue: 0.98)
    public static let textSecondary = Color(red: 0.68, green: 0.72, blue: 0.78)
    public static let textTertiary = Color(red: 0.52, green: 0.56, blue: 0.62)

    // MARK: - Brand
    public static let emerald = Color(red: 0.18, green: 0.78, blue: 0.58)
    public static let emeraldLight = Color(red: 0.35, green: 0.90, blue: 0.72)
    public static let premiumGold = Color(red: 0.90, green: 0.76, blue: 0.38)
    public static let goldGradient = LinearGradient(
        colors: [
            Color(red: 0.90, green: 0.76, blue: 0.38),
            Color(red: 0.98, green: 0.88, blue: 0.55)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    public static let diamondGlass = Color.white.opacity(0.08)

    // MARK: - Status
    public static let warning = Color(red: 0.95, green: 0.62, blue: 0.28)
    public static let danger = Color(red: 0.95, green: 0.38, blue: 0.38)
    public static let info = Color(red: 0.45, green: 0.68, blue: 0.95)

    public static func cardStyle<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .background(surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

// MARK: - Reusable modifiers

public extension View {
    @ViewBuilder
    func psychosocialListChrome() -> some View {
        #if os(iOS)
        self.scrollContentBackground(.hidden)
        #else
        self
        #endif
    }

    @ViewBuilder
    func psychosocialNavigationTitle(_ mode: PsychosocialNavigationTitleMode) -> some View {
        #if os(iOS)
        switch mode {
        case .large: self.navigationBarTitleDisplayMode(.large)
        case .inline: self.navigationBarTitleDisplayMode(.inline)
        }
        #else
        self
        #endif
    }

    /// Full-screen dark background with readable navigation chrome.
    func psychosocialScreen() -> some View {
        self
            .background(PremiumTheme.background.ignoresSafeArea())
            .foregroundStyle(PremiumTheme.textPrimary)
            .tint(PremiumTheme.emerald)
    }

    func psychosocialPrimaryButton() -> some View {
        self
            .font(.body.weight(.semibold))
            .foregroundStyle(PremiumTheme.background)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(PremiumTheme.emerald, in: Capsule())
    }

    func psychosocialSecondaryButton() -> some View {
        self
            .font(.body.weight(.medium))
            .foregroundStyle(PremiumTheme.emeraldLight)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(PremiumTheme.emerald.opacity(0.18), in: Capsule())
            .overlay(Capsule().stroke(PremiumTheme.emerald.opacity(0.45), lineWidth: 1))
    }

    func psychosocialBadge(_ tone: BadgeTone = .neutral) -> some View {
        self
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tone.background, in: Capsule())
            .foregroundStyle(tone.foreground)
    }
}

public enum PsychosocialNavigationTitleMode {
    case large, inline
}

public enum BadgeTone {
    case neutral, success, warning, gold

    var background: Color {
        switch self {
        case .neutral: return PremiumTheme.surface
        case .success: return PremiumTheme.emerald.opacity(0.22)
        case .warning: return PremiumTheme.warning.opacity(0.22)
        case .gold: return PremiumTheme.premiumGold.opacity(0.22)
        }
    }

    var foreground: Color {
        switch self {
        case .neutral: return PremiumTheme.textSecondary
        case .success: return PremiumTheme.emeraldLight
        case .warning: return PremiumTheme.warning
        case .gold: return PremiumTheme.premiumGold
        }
    }
}
