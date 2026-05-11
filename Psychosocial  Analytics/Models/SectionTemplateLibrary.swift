//
//  SectionTemplateLibrary.swift
//  Psychosocial  Analytics
//

import Foundation

enum SectionTemplateLibrary {
    static let all: [AssessmentSection: SectionTemplate] = {
        var d: [AssessmentSection: SectionTemplate] = [:]
        let pairs: [(AssessmentSection, [SectionFieldDefinition])] = [
            (.identifyingInformation, BasicInformationFields.identifyingInformation),
            (.referral, BasicInformationFields.referral),
            (.presentingProblem, BasicInformationFields.presentingProblem),
            (.sourcesOfData, BasicInformationFields.sourcesOfData),
            (.generalDescription, BasicInformationFields.generalDescription),
            (.familyComposition, BackgroundFunctioningFields.familyComposition),
            (.educationalBackground, BackgroundFunctioningFields.educationalBackground),
            (.employmentVocational, BackgroundFunctioningFields.employmentVocational),
            (.religiousSpiritual, BackgroundFunctioningFields.religiousSpiritual),
            (.physicalHealth, BackgroundFunctioningFields.physicalHealth),
            (.psychologicalPsychiatric, BackgroundFunctioningFields.psychologicalPsychiatric),
            (.socialCommunityRecreational, BackgroundFunctioningFields.socialCommunityRecreational),
            (.basicLifeNecessities, BackgroundFunctioningFields.basicLifeNecessities),
            (.legalConcerns, BackgroundFunctioningFields.legalConcerns),
            (.otherPsychosocialFactors, BackgroundFunctioningFields.otherPsychosocialFactors),
            (.strengthsCapacitiesResources, BackgroundFunctioningFields.strengthsCapacitiesResources),
            (.clinicalSummary, ImpressionsRecommendationsFields.clinicalSummary),
            (.goalsRecommendations, ImpressionsRecommendationsFields.goalsRecommendations)
        ]
        for (section, defs) in pairs {
            d[section] = SectionTemplate(section: section, definitions: defs)
        }
        return d
    }()

    static func template(for section: AssessmentSection) -> SectionTemplate {
        all[section] ?? SectionTemplate(section: section, definitions: [])
    }

    static func emptyAnswers(for section: AssessmentSection) -> [FieldAnswer] {
        template(for: section).definitions.map {
            FieldAnswer(id: UUID(), key: $0.key, label: $0.label, value: "", sourceType: "self_report")
        }
    }

    static func merged(existing: [FieldAnswer], section: AssessmentSection) -> [FieldAnswer] {
        let defs = template(for: section).definitions
        let byKey = Dictionary(uniqueKeysWithValues: existing.map { ($0.key, $0) })
        return defs.map { def in
            byKey[def.key] ?? FieldAnswer(
                id: UUID(), key: def.key, label: def.label, value: "", sourceType: "self_report"
            )
        }
    }
}
