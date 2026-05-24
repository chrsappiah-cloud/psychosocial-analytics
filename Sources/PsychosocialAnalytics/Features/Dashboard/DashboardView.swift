import SwiftUI

public struct DashboardView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    AppBrandHeader(style: .hero)

                    PremiumTheme.cardStyle {
                        VStack(alignment: .leading, spacing: 14) {
                            BrandedSectionTitle("Welcome back", subtitle: "Your caseload at a glance")
                            HStack(spacing: 12) {
                                StatCard(title: "Active cases", value: "12", color: PremiumTheme.emerald, icon: "person.2.fill")
                                StatCard(title: "Pending", value: "4", color: PremiumTheme.warning, icon: "clock.fill")
                                StatCard(title: "Completed", value: "45", color: PremiumTheme.info, icon: "checkmark.seal.fill")
                            }
                        }
                    }

                    PremiumTheme.cardStyle {
                        VStack(alignment: .leading, spacing: 14) {
                            BrandedSectionTitle("Recent reports", subtitle: "Latest activity across your practice")
                            reportRow(
                                title: "John Doe — Initial assessment",
                                subtitle: "Drafted 2 hours ago"
                            )
                            Divider().overlay(PremiumTheme.border)
                            reportRow(
                                title: "Maria Garcia — Quarterly review",
                                subtitle: "Drafted yesterday"
                            )
                            Divider().overlay(PremiumTheme.border)
                            reportRow(
                                title: "Jane Doe — Risk re-evaluation",
                                subtitle: "Drafted 3 days ago"
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(AccessibilityID.screenDashboard)
            .psychosocialScreen()
        }
    }

    private func reportRow(title: String, subtitle: String) -> some View {
        PremiumListRow(icon: "doc.text.fill", title: title, subtitle: subtitle)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(PremiumTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(PremiumTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}
