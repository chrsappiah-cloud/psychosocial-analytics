//
//  SectionFieldDefinition.swift
//  Psychosocial  Analytics
//

import Foundation

enum SectionFieldKind: Codable, Hashable {
    case shortText
    case longText
    case date
    case number
    case choice([String])
}

struct SectionFieldDefinition: Identifiable, Hashable {
    let key: String
    let label: String
    let prompt: String
    let kind: SectionFieldKind
    let isRequired: Bool

    var id: String { key }
}

struct SectionTemplate: Identifiable, Hashable {
    let section: AssessmentSection
    let definitions: [SectionFieldDefinition]

    var id: AssessmentSection { section }

    var requiredCount: Int { definitions.filter(\.isRequired).count }
}
