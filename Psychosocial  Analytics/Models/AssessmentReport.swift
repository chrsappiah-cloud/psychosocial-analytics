//
//  AssessmentReport.swift
//  Psychosocial  Analytics
//

import Foundation

struct AssessmentReport: Codable, Hashable, Identifiable {
    let id: UUID
    var generatedAt: Date
    var clientName: String
    var clinicianName: String
    var modelIdentifier: String
    var requiresHumanReview: Bool

    // Three-part information architecture from the source document.
    var basicInformationNarrative: String
    var backgroundAndFunctioningNarrative: String

    // The five elements named in the source document's definition of a
    // psychosocial assessment.
    var problems: String
    var contributingFactors: String
    var assetsAndResources: String
    var prognosis: String
    var planForIntervention: String

    var diagnosticImpressions: String?
    var goals: ReportGoalsBlock

    // Per-section draft narratives keyed by AssessmentSection.rawValue.
    var sectionDrafts: [String: String]

    var missingInformation: [String]
    var riskNotes: [RiskNote]

    init(
        id: UUID = UUID(),
        generatedAt: Date = .now,
        clientName: String,
        clinicianName: String = "Unsigned",
        modelIdentifier: String,
        requiresHumanReview: Bool = true,
        basicInformationNarrative: String,
        backgroundAndFunctioningNarrative: String,
        problems: String,
        contributingFactors: String,
        assetsAndResources: String,
        prognosis: String,
        planForIntervention: String,
        diagnosticImpressions: String? = nil,
        goals: ReportGoalsBlock,
        sectionDrafts: [String: String] = [:],
        missingInformation: [String] = [],
        riskNotes: [RiskNote] = []
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.clientName = clientName
        self.clinicianName = clinicianName
        self.modelIdentifier = modelIdentifier
        self.requiresHumanReview = requiresHumanReview
        self.basicInformationNarrative = basicInformationNarrative
        self.backgroundAndFunctioningNarrative = backgroundAndFunctioningNarrative
        self.problems = problems
        self.contributingFactors = contributingFactors
        self.assetsAndResources = assetsAndResources
        self.prognosis = prognosis
        self.planForIntervention = planForIntervention
        self.diagnosticImpressions = diagnosticImpressions
        self.goals = goals
        self.sectionDrafts = sectionDrafts
        self.missingInformation = missingInformation
        self.riskNotes = riskNotes
    }
}

struct ReportGoalsBlock: Codable, Hashable {
    var shortTerm: [String]
    var longTerm: [String]
    var recommendedInterventions: [String]
    var followUpPlan: String
}

struct RiskNote: Codable, Hashable, Identifiable {
    let id: UUID
    var category: String
    var severity: String
    var sourceSection: String
    var excerpt: String

    init(id: UUID = UUID(), category: String, severity: String, sourceSection: String, excerpt: String) {
        self.id = id
        self.category = category
        self.severity = severity
        self.sourceSection = sourceSection
        self.excerpt = excerpt
    }
}
