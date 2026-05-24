import SwiftUI

public struct AnalyticsView: View {
    public init() {}

    private let metrics: [(String, String, Color, String)] = [
        ("Average risk score", "2.4", PremiumTheme.emerald, "chart.line.uptrend.xyaxis"),
        ("Reports per week", "18", PremiumTheme.info, "doc.richtext"),
        ("AI drafts used", "73%", PremiumTheme.premiumGold, "sparkles"),
        ("Open cases", "12", PremiumTheme.warning, "folder.fill")
    ]

    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    AppBrandHeader(style: .compact, screenTitle: "Insights")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(metrics, id: \.0) { metric in
                            PremiumMetricCard(
                                title: metric.0,
                                value: metric.1,
                                color: metric.2,
                                icon: metric.3
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(AccessibilityID.screenInsights)
            .psychosocialScreen()
        }
    }
}
