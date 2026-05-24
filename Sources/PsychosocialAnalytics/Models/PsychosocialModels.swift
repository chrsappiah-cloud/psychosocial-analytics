import Foundation

public enum UserRole: String, Codable {
    case socialWorker
    case client
    case admin
}

public enum AssessmentSection: String, Codable, CaseIterable {
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
}

public struct Assessment: Identifiable, Codable {
    public let id: UUID
    public var organizationID: UUID
    public var createdByUserID: UUID
    public var clientID: UUID
    public var status: AssessmentStatus
    public var sections: [AssessmentSectionPayload]
    public var riskFlags: [RiskFlag]
    public var aiDrafts: [AIDraft]
    public var signatures: [SignatureRecord]
    public var createdAt: Date
    public var updatedAt: Date
}

public enum AssessmentStatus: String, Codable {
    case draft
    case inReview
    case signed
    case exported
}

public struct AssessmentSectionPayload: Codable, Identifiable {
    public let id: UUID
    public let section: AssessmentSection
    public var answers: [FieldAnswer]
    public var completionScore: Double
    public var lastEditedAt: Date
}

public struct FieldAnswer: Codable, Identifiable {
    public let id: UUID
    public var key: String
    public var label: String
    public var value: String
}

public struct RiskFlag: Codable, Identifiable {
    public let id: UUID
    public var type: String
    public var severity: Int
    public var description: String
}

public struct AIDraft: Codable, Identifiable {
    public let id: UUID
    public var section: AssessmentSection
    public var content: String
    public var confidence: Double
}

public struct SignatureRecord: Codable, Identifiable {
    public let id: UUID
    public var userID: UUID
    public var timestamp: Date
    public var signatureData: Data?
}
