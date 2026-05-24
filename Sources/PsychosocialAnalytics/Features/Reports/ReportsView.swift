import SwiftUI

public struct ReportItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let date: String
    public let status: String
}

public struct ReportsView: View {
    public init() {}

    private let reports: [ReportItem] = [
        ReportItem(title: "John Doe — Initial assessment", date: "Today", status: "Draft"),
        ReportItem(title: "Maria Garcia — Quarterly review", date: "Yesterday", status: "Signed"),
        ReportItem(title: "Jane Doe — Risk re-evaluation", date: "3 days ago", status: "Exported")
    ]

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBrandHeader(style: .compact, screenTitle: "Reports")

                List(reports) { report in
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(PremiumTheme.emerald)
                            .frame(width: 40, height: 40)
                            .background(PremiumTheme.emerald.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(PremiumTheme.textPrimary)
                            Text(report.date)
                                .font(.caption)
                                .foregroundStyle(PremiumTheme.textSecondary)
                        }
                        Spacer(minLength: 8)
                        Text(report.status)
                            .psychosocialBadge(statusTone(report.status))
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(PremiumTheme.surface)
                    .listRowSeparatorTint(PremiumTheme.border)
                }
                .psychosocialListChrome()
            }
            .toolbarBackground(PremiumTheme.surface.opacity(0.95), for: .navigationBar)
            .accessibilityIdentifier(AccessibilityID.screenReports)
            .psychosocialScreen()
        }
    }

    private func statusTone(_ status: String) -> BadgeTone {
        switch status.lowercased() {
        case "signed": return .success
        case "draft": return .warning
        default: return .gold
        }
    }
}
