//
//  ReportGenerator.swift
//  Psychosocial  Analytics
//

import Foundation

protocol ReportGenerator {
    var modelIdentifier: String { get }
    func generate(from draft: AssessmentDraft) async throws -> AssessmentReport
}

struct LocalDeterministicReportGenerator: ReportGenerator {
    let modelIdentifier: String = "local.deterministic-v1"

    func generate(from draft: AssessmentDraft) async throws -> AssessmentReport {
        let payload = draft.assessmentPayload

        let basicGroups: [AssessmentSection] = AssessmentSectionGroup.basicInformation.sections
        let backgroundGroups: [AssessmentSection] = AssessmentSectionGroup.backgroundAndFunctioning.sections

        let basicNarrative = narrative(for: basicGroups, in: payload)
        let backgroundNarrative = narrative(for: backgroundGroups, in: payload)

        let clinical = answersDictionary(for: .clinicalSummary, in: payload)
        let recs = answersDictionary(for: .goalsRecommendations, in: payload)

        let problems = nonEmpty(clinical["problems_summary"]) ?? synthesizedProblems(from: payload)
        let contributing = nonEmpty(clinical["contributing_factors"]) ?? "Insufficient information."
        let assets = nonEmpty(clinical["assets_and_resources"]) ?? synthesizedStrengths(from: payload)
        let prognosis = nonEmpty(clinical["prognosis"]) ?? "Prognosis pending clinician judgment."
        let plan = nonEmpty(recs["follow_up_plan"]) ?? "Follow-up plan to be determined with the client."
        let diagnostic = nonEmpty(clinical["diagnostic_impressions"])

        let goals = ReportGoalsBlock(
            shortTerm: bullets(nonEmpty(recs["short_term_goals"])),
            longTerm: bullets(nonEmpty(recs["long_term_goals"])),
            recommendedInterventions: bullets(nonEmpty(recs["recommended_interventions"])),
            followUpPlan: plan
        )

        let drafts = perSectionDrafts(payload: payload)
        let missing = missingInformation(payload: payload)
        let risks = RiskDetector.scan(payload: payload)

        return AssessmentReport(
            clientName: draft.clientName,
            modelIdentifier: modelIdentifier,
            basicInformationNarrative: basicNarrative,
            backgroundAndFunctioningNarrative: backgroundNarrative,
            problems: problems,
            contributingFactors: contributing,
            assetsAndResources: assets,
            prognosis: prognosis,
            planForIntervention: plan,
            diagnosticImpressions: diagnostic,
            goals: goals,
            sectionDrafts: drafts,
            missingInformation: missing,
            riskNotes: risks
        )
    }

    private func answersDictionary(for section: AssessmentSection, in payload: AssessmentPayload) -> [String: String] {
        Dictionary(uniqueKeysWithValues: payload.answers(for: section).map { ($0.key, $0.value) })
    }

    private func nonEmpty(_ value: String?) -> String? {
        guard let v = value?.trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty else { return nil }
        return v
    }

    private func bullets(_ value: String?) -> [String] {
        guard let v = value else { return [] }
        return v
            .components(separatedBy: CharacterSet(charactersIn: "\n;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func narrative(for sections: [AssessmentSection], in payload: AssessmentPayload) -> String {
        var paragraphs: [String] = []
        for section in sections {
            let answered = payload.answers(for: section).filter { !$0.value.isEmpty }
            guard !answered.isEmpty else { continue }
            let body = answered.map { "\($0.label): \($0.value)" }.joined(separator: " ")
            paragraphs.append("\(section.title). \(body)")
        }
        return paragraphs.isEmpty ? "Insufficient information recorded." : paragraphs.joined(separator: "\n\n")
    }

    private func perSectionDrafts(payload: AssessmentPayload) -> [String: String] {
        var result: [String: String] = [:]
        for section in AssessmentSection.allCases {
            let answered = payload.answers(for: section).filter { !$0.value.isEmpty }
            guard !answered.isEmpty else { continue }
            result[section.rawValue] = answered.map { "\($0.label): \($0.value)" }
                .joined(separator: "\n")
        }
        return result
    }

    private func missingInformation(payload: AssessmentPayload) -> [String] {
        var missing: [String] = []
        for section in AssessmentSection.allCases {
            let template = SectionTemplateLibrary.template(for: section)
            let answers = Dictionary(uniqueKeysWithValues: payload.answers(for: section).map { ($0.key, $0.value) })
            for def in template.definitions where def.isRequired {
                let value = answers[def.key] ?? ""
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    missing.append("\(section.title) — \(def.label)")
                }
            }
        }
        return missing
    }

    private func synthesizedProblems(from payload: AssessmentPayload) -> String {
        let presenting = payload.answers(for: .presentingProblem)
            .first(where: { $0.key == "problem_description" })?.value ?? ""
        return presenting.isEmpty ? "Problem statement not yet documented." : presenting
    }

    private func synthesizedStrengths(from payload: AssessmentPayload) -> String {
        let strengths = payload.answers(for: .strengthsCapacitiesResources)
            .filter { !$0.value.isEmpty }
            .map { "\($0.label): \($0.value)" }
            .joined(separator: " ")
        return strengths.isEmpty ? "Strengths and resources have not yet been documented." : strengths
    }
}
