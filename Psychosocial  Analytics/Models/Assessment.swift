//
//  Assessment.swift
//  Psychosocial  Analytics
//

import Foundation

enum AssessmentStatus: String, Codable, CaseIterable {
    case draft
    case inReview
    case signed
    case exported

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .inReview: "In Review"
        case .signed: "Signed"
        case .exported: "Exported"
        }
    }
}

struct Assessment: Identifiable, Codable, Hashable {
    let id: UUID
    var organizationID: UUID
    var createdByUserID: UUID
    var clientID: UUID
    var status: AssessmentStatus
    var sections: [AssessmentSectionPayload]
    var riskFlags: [RiskFlag]
    var aiDrafts: [AIDraft]
    var signatures: [SignatureRecord]
    var createdAt: Date
    var updatedAt: Date

    var completionScore: Double {
        guard !sections.isEmpty else { return 0 }
        let total = sections.reduce(0.0) { $0 + $1.completionScore }
        return total / Double(sections.count)
    }
}

struct AssessmentSectionPayload: Codable, Identifiable, Hashable {
    let id: UUID
    let section: AssessmentSection
    var answers: [FieldAnswer]
    var completionScore: Double
    var lastEditedAt: Date
}

struct FieldAnswer: Codable, Identifiable, Hashable {
    let id: UUID
    var key: String
    var label: String
    var value: String
    var sourceType: String
}

struct RiskFlag: Codable, Identifiable, Hashable {
    let id: UUID
    var type: String
    var severity: String
    var note: String
}

struct AIDraft: Codable, Identifiable, Hashable {
    let id: UUID
    var type: String
    var content: String
    var model: String
    var createdAt: Date
    var requiresHumanReview: Bool
}

struct SignatureRecord: Codable, Identifiable, Hashable {
    let id: UUID
    var signedByUserID: UUID
    var role: UserRole
    var signedAt: Date
}
