//
//  ImpressionsRecommendationsFields.swift
//  Psychosocial  Analytics
//

import Foundation

enum ImpressionsRecommendationsFields {
    static let clinicalSummary: [SectionFieldDefinition] = [
        .init(key: "problems_summary", label: "Problems",
              prompt: "Summary of the client's primary problems and concerns.",
              kind: .longText, isRequired: true),
        .init(key: "contributing_factors", label: "Contributing Factors",
              prompt: "Factors contributing to the presenting concerns, including environmental and psychosocial.",
              kind: .longText, isRequired: true),
        .init(key: "assets_and_resources", label: "Assets and Resources",
              prompt: "Strengths, supports, and resources available to support intervention.",
              kind: .longText, isRequired: true),
        .init(key: "diagnostic_impressions", label: "Diagnostic Impressions",
              prompt: "Diagnostic impressions; clinician-reviewed only and policy-constrained.",
              kind: .longText, isRequired: false),
        .init(key: "prognosis", label: "Prognosis",
              prompt: "Clinician's prognosis based on current presentation and supports.",
              kind: .longText, isRequired: true)
    ]

    static let goalsRecommendations: [SectionFieldDefinition] = [
        .init(key: "short_term_goals", label: "Short-Term Goals",
              prompt: "Goals to be achieved in the next 30 to 90 days.",
              kind: .longText, isRequired: true),
        .init(key: "long_term_goals", label: "Long-Term Goals",
              prompt: "Goals to be achieved over the longer course of intervention.",
              kind: .longText, isRequired: false),
        .init(key: "recommended_interventions", label: "Recommended Interventions",
              prompt: "Recommended interventions, services, and supports.",
              kind: .longText, isRequired: true),
        .init(key: "referrals", label: "Referrals",
              prompt: "Referrals to be initiated as part of the plan.",
              kind: .longText, isRequired: false),
        .init(key: "follow_up_plan", label: "Follow-Up Plan",
              prompt: "Follow-up cadence, review milestones, and accountability.",
              kind: .longText, isRequired: true)
    ]
}
