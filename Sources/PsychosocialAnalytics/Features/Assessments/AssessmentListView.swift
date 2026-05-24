import SwiftUI

public struct AssessmentListView: View {
    @StateObject private var viewModel = AssessmentViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBrandHeader(style: .compact, screenTitle: "Assessments")

                Group {
                    if viewModel.assessments.isEmpty {
                        ContentUnavailableView {
                            Label("No assessments yet", systemImage: "doc.text")
                                .foregroundStyle(PremiumTheme.emerald)
                        } description: {
                            Text("Start a new psychosocial assessment from your caseload.")
                                .foregroundStyle(PremiumTheme.textSecondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List(viewModel.assessments) { assessment in
                            NavigationLink {
                                AssessmentDetailView(viewModel: viewModel, assessmentID: assessment.id)
                            } label: {
                                PremiumListRow(
                                    icon: "doc.text.fill",
                                    title: assessment.displayTitle,
                                    subtitle: assessment.statusLabel,
                                    accent: assessment.statusColor
                                )
                            }
                            .listRowBackground(PremiumTheme.surface)
                            .listRowSeparatorTint(PremiumTheme.border)
                        }
                        .psychosocialListChrome()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.createAssessment()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(PremiumTheme.emeraldLight, PremiumTheme.surface)
                    }
                    .accessibilityIdentifier(AccessibilityID.buttonNewAssessment)
                    .accessibilityLabel("Create new assessment")
                }
            }
            .toolbarBackground(PremiumTheme.surface.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier(AccessibilityID.screenAssessments)
            .psychosocialScreen()
        }
    }
}

private extension Assessment {
    var displayTitle: String {
        "Psychosocial assessment"
    }

    var statusLabel: String {
        "Status: \(status.rawValue.capitalized)"
    }

    var statusColor: Color {
        switch status {
        case .draft: return PremiumTheme.warning
        case .inReview: return PremiumTheme.info
        case .signed, .exported: return PremiumTheme.emeraldLight
        }
    }
}
