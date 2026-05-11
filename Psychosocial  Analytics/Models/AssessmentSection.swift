//
//  AssessmentSection.swift
//  Psychosocial  Analytics
//

import Foundation

enum AssessmentSection: String, Codable, CaseIterable, Identifiable {
    case identifyingInformation
    case referral
    case presentingProblem
    case sourcesOfData
    case generalDescription
    case familyComposition
    case educationalBackground
    case employmentVocational
    case religiousSpiritual
    case physicalHealth
    case psychologicalPsychiatric
    case socialCommunityRecreational
    case basicLifeNecessities
    case legalConcerns
    case otherPsychosocialFactors
    case strengthsCapacitiesResources
    case clinicalSummary
    case goalsRecommendations

    var id: String { rawValue }

    var title: String {
        switch self {
        case .identifyingInformation: "Identifying Information"
        case .referral: "Referral"
        case .presentingProblem: "Presenting Problem"
        case .sourcesOfData: "Sources of Data"
        case .generalDescription: "General Description of Client"
        case .familyComposition: "Family Composition and Background"
        case .educationalBackground: "Educational Background"
        case .employmentVocational: "Employment and Vocational Skills"
        case .religiousSpiritual: "Religious and Spiritual Involvement"
        case .physicalHealth: "Physical Functioning, Health, and Medical Background"
        case .psychologicalPsychiatric: "Psychological and Psychiatric Functioning"
        case .socialCommunityRecreational: "Social, Community, and Recreational Activities"
        case .basicLifeNecessities: "Basic Life Necessities"
        case .legalConcerns: "Legal Concerns"
        case .otherPsychosocialFactors: "Other Environmental or Psychosocial Factors"
        case .strengthsCapacitiesResources: "Client Strengths, Capacities, and Resources"
        case .clinicalSummary: "Clinical Summary, Impressions, and Assessment"
        case .goalsRecommendations: "Goals and Recommendations"
        }
    }

    var group: AssessmentSectionGroup {
        switch self {
        case .identifyingInformation, .referral, .presentingProblem,
             .sourcesOfData, .generalDescription:
            return .basicInformation
        case .familyComposition, .educationalBackground, .employmentVocational,
             .religiousSpiritual, .physicalHealth, .psychologicalPsychiatric,
             .socialCommunityRecreational, .basicLifeNecessities, .legalConcerns,
             .otherPsychosocialFactors, .strengthsCapacitiesResources:
            return .backgroundAndFunctioning
        case .clinicalSummary, .goalsRecommendations:
            return .impressionsAndRecommendations
        }
    }
}

enum AssessmentSectionGroup: String, Codable, CaseIterable, Identifiable {
    case basicInformation
    case backgroundAndFunctioning
    case impressionsAndRecommendations

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basicInformation: "Basic Information"
        case .backgroundAndFunctioning: "Background and Current Functioning"
        case .impressionsAndRecommendations: "Impressions and Recommendations"
        }
    }

    var sections: [AssessmentSection] {
        AssessmentSection.allCases.filter { $0.group == self }
    }
}
