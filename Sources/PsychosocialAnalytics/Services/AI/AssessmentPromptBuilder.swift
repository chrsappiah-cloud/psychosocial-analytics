import Foundation

/// Builds structured prompts from assessment section answers for AI generation.
public struct AssessmentPromptBuilder: Sendable {
    public init() {}

    public func buildPrompt(for assessment: Assessment) -> String {
        var lines: [String] = [
            "Generate a psychosocial clinical report draft.",
            "Assessment ID: \(assessment.id.uuidString)",
            "Status: \(assessment.status.rawValue)"
        ]
        for payload in assessment.sections.sorted(by: { $0.section.rawValue < $1.section.rawValue }) {
            let title = AssessmentSectionSchema.title(for: payload.section)
            let answers = payload.answers.filter { !$0.value.isEmpty && $0.value != "false" }
            guard !answers.isEmpty else { continue }
            lines.append("\n## \(title)")
            for answer in answers {
                lines.append("- \(answer.label): \(answer.value)")
            }
        }
        if lines.count <= 3 {
            lines.append("\n(No section answers provided — produce a template draft.)")
        }
        return lines.joined(separator: "\n")
    }
}
