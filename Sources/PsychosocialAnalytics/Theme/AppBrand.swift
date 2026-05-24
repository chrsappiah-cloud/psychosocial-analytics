import SwiftUI

/// Central brand identity for Psychosocial Analytics.
public enum AppBrand {
    public static let name = "Psychosocial Analytics"
    public static let nameLine1 = "Psychosocial"
    public static let nameLine2 = "Analytics"
    public static let tagline = "Clinical intelligence for social work"
    public static let shortTagline = "Caseload · Assessments · Insights"

    public static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.22, blue: 0.18),
            Color(red: 0.07, green: 0.08, blue: 0.12),
            Color(red: 0.05, green: 0.06, blue: 0.09)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let nameGradient = LinearGradient(
        colors: [PremiumTheme.emeraldLight, PremiumTheme.emerald, Color(red: 0.12, green: 0.55, blue: 0.72)],
        startPoint: .leading,
        endPoint: .trailing
    )

    public static let accentRingGradient = AngularGradient(
        colors: [
            PremiumTheme.emerald,
            PremiumTheme.premiumGold.opacity(0.9),
            PremiumTheme.emeraldLight,
            PremiumTheme.emerald
        ],
        center: .center
    )
}
