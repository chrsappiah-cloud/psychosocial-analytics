import SwiftUI

/// Generic, schema-driven form for any psychosocial assessment section.
public struct AssessmentSectionFormView: View {
    @ObservedObject var viewModel: AssessmentViewModel
    public let assessmentID: UUID
    public let section: AssessmentSection

    public init(viewModel: AssessmentViewModel,
                assessmentID: UUID,
                section: AssessmentSection) {
        self.viewModel = viewModel
        self.assessmentID = assessmentID
        self.section = section
    }

    public var body: some View {
        Form {
            ForEach(AssessmentSectionSchema.fields(for: section)) { spec in
                Section {
                    fieldEditor(for: spec)
                } header: {
                    Text(spec.label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PremiumTheme.textSecondary)
                }
            }
        }
        .psychosocialListChrome()
        .background(PremiumTheme.background)
        .navigationTitle(AssessmentSectionSchema.title(for: section))
        .psychosocialNavigationTitle(.inline)
        .preferredColorScheme(.dark)
        .tint(PremiumTheme.emerald)
    }

    @ViewBuilder
    private func fieldEditor(for spec: SectionFieldSpec) -> some View {
        let binding = viewModel.binding(
            assessmentID: assessmentID,
            section: section,
            field: spec
        )
        switch spec.kind {
        case .shortText:
            TextField(spec.placeholder ?? spec.label, text: binding, axis: .vertical)
                .foregroundStyle(PremiumTheme.textPrimary)
        case .longText:
            TextEditor(text: binding)
                .frame(minHeight: 100)
                .psychosocialListChrome()
                .padding(8)
                .background(PremiumTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(PremiumTheme.border)
                )
                .foregroundStyle(PremiumTheme.textPrimary)
        case .toggle:
            Toggle(isOn: Binding(
                get: { binding.wrappedValue == "true" },
                set: { binding.wrappedValue = $0 ? "true" : "false" }
            )) {
                Text(spec.label)
                    .foregroundStyle(PremiumTheme.textPrimary)
            }
            .tint(PremiumTheme.emerald)
        case .integer:
            TextField(spec.placeholder ?? "0", text: binding)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .foregroundStyle(PremiumTheme.textPrimary)
        }
    }
}

/// Detail screen for a single assessment.
public struct AssessmentDetailView: View {
    @ObservedObject var viewModel: AssessmentViewModel
    public let assessmentID: UUID

    public init(viewModel: AssessmentViewModel, assessmentID: UUID) {
        self.viewModel = viewModel
        self.assessmentID = assessmentID
    }

    public var body: some View {
        List {
            Section {
                ForEach(AssessmentSection.allCases, id: \.self) { section in
                    NavigationLink {
                        AssessmentSectionFormView(
                            viewModel: viewModel,
                            assessmentID: assessmentID,
                            section: section
                        )
                    } label: {
                        HStack {
                            Text(AssessmentSectionSchema.title(for: section))
                                .font(.body.weight(.medium))
                                .foregroundStyle(PremiumTheme.textPrimary)
                            Spacer()
                            let pct = Int(viewModel.completion(assessmentID: assessmentID, section: section) * 100)
                            Text("\(pct)% complete")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(pct == 100 ? PremiumTheme.emeraldLight : PremiumTheme.textSecondary)
                        }
                    }
                }
            } header: {
                Text("Psychosocial sections")
            }

            Section {
                if viewModel.isGeneratingAI {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(PremiumTheme.emerald)
                        Text("Generating AI report draft…")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(PremiumTheme.textSecondary)
                    }
                    .accessibilityIdentifier(AccessibilityID.aiGeneratingIndicator)
                }

                Button {
                    Task {
                        viewModel.currentAssessment = viewModel.assessment(id: assessmentID)
                        await viewModel.generateAIDraft()
                    }
                } label: {
                    Label(
                        viewModel.isGeneratingAI ? "Generating…" : "Generate AI report draft",
                        systemImage: "sparkles"
                    )
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PremiumTheme.premiumGold)
                }
                .disabled(viewModel.isGeneratingAI)
                .accessibilityIdentifier(AccessibilityID.buttonGenerateAIDraft)
                .accessibilityHint("Creates a draft narrative from completed sections")

                if viewModel.aiDraftCount(for: assessmentID) > 0 {
                    LabeledContent("AI drafts saved", value: "\(viewModel.aiDraftCount(for: assessmentID))")
                        .foregroundStyle(PremiumTheme.emeraldLight)
                        .accessibilityIdentifier(AccessibilityID.aiDraftCountLabel)
                }

                if let error = viewModel.lastAIError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(PremiumTheme.danger)
                        .accessibilityIdentifier(AccessibilityID.aiErrorLabel)
                }
            } header: {
                Text("AI assistance")
            } footer: {
                Text("Review all AI-generated text before signing or exporting a report.")
                    .foregroundStyle(PremiumTheme.textTertiary)
            }
        }
        .psychosocialListChrome()
        .navigationTitle("Assessment")
        .psychosocialNavigationTitle(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(AppBrand.name)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppBrand.nameGradient)
                    Text("Assessment")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(PremiumTheme.textPrimary)
                }
            }
        }
        .toolbarBackground(PremiumTheme.surface.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .accessibilityIdentifier("screen_assessment_detail")
        .psychosocialScreen()
    }
}
