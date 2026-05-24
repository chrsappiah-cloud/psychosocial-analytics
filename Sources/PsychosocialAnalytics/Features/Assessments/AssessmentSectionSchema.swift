import Foundation

/// Describes a single field that the worker fills in within an assessment section.
public struct SectionFieldSpec: Identifiable, Hashable {
    public enum Kind: String, Hashable {
        case shortText
        case longText
        case toggle
        case integer
    }
    public let id: String          // stable key, used as FieldAnswer.key
    public let label: String       // human label
    public let kind: Kind
    public let placeholder: String?

    public init(id: String, label: String, kind: Kind, placeholder: String? = nil) {
        self.id = id
        self.label = label
        self.kind = kind
        self.placeholder = placeholder
    }
}

/// Human-readable titles + schemas for every psychosocial section in the infosheet.
public enum AssessmentSectionSchema {

    public static func title(for section: AssessmentSection) -> String {
        switch section {
        case .identifyingInformation:       return "Identifying Information"
        case .referral:                     return "Referral"
        case .presentingProblem:            return "Presenting Problem"
        case .sourcesOfData:                return "Sources of Data"
        case .generalDescription:           return "General Description"
        case .familyComposition:            return "Family Composition & Background"
        case .educationalBackground:        return "Educational Background"
        case .employmentVocational:         return "Employment & Vocational"
        case .religiousSpiritual:           return "Religious & Spiritual"
        case .physicalHealth:               return "Physical Health"
        case .psychologicalPsychiatric:     return "Psychological & Psychiatric"
        case .socialCommunityRecreational:  return "Social, Community & Recreational"
        case .basicLifeNecessities:         return "Basic Life Necessities"
        case .legalConcerns:                return "Legal Concerns"
        case .otherPsychosocialFactors:     return "Other Psychosocial Factors"
        case .strengthsCapacitiesResources: return "Client Strengths, Capacities & Resources"
        case .clinicalSummary:              return "Clinical Summary & Impressions"
        case .goalsRecommendations:         return "Goals & Recommendations"
        }
    }

    public static func fields(for section: AssessmentSection) -> [SectionFieldSpec] {
        switch section {
        case .identifyingInformation:
            return [
                .init(id: "fullName", label: "Full Name", kind: .shortText),
                .init(id: "dateOfBirth", label: "Date of Birth", kind: .shortText, placeholder: "YYYY-MM-DD"),
                .init(id: "address", label: "Address", kind: .longText),
                .init(id: "contactNumber", label: "Contact Number", kind: .shortText),
                .init(id: "maritalStatus", label: "Marital Status", kind: .shortText)
            ]
        case .referral:
            return [
                .init(id: "referralSource", label: "Referral Source", kind: .shortText),
                .init(id: "referralReason", label: "Reason for Referral", kind: .longText),
                .init(id: "referralDate", label: "Referral Date", kind: .shortText)
            ]
        case .presentingProblem:
            return [
                .init(id: "clientDescription", label: "Client's Description of the Problem", kind: .longText),
                .init(id: "expectations", label: "Expectations of Service", kind: .longText),
                .init(id: "duration", label: "Duration of Problem", kind: .shortText),
                .init(id: "priorAttempts", label: "Prior Attempts to Resolve", kind: .longText),
                .init(id: "previousAgencies", label: "Previous Agency Involvement", kind: .longText),
                .init(id: "riskSuicide", label: "Suicide / Self-harm Risk", kind: .longText),
                .init(id: "riskAbuse", label: "Abuse / Neglect Risk", kind: .longText),
                .init(id: "riskViolence", label: "Violence Risk", kind: .longText),
                .init(id: "riskRelapse", label: "Substance Relapse Risk", kind: .longText)
            ]
        case .sourcesOfData:
            return [
                .init(id: "interviews", label: "Interviews", kind: .toggle),
                .init(id: "observations", label: "Observations", kind: .toggle),
                .init(id: "writtenMaterials", label: "Written Materials", kind: .toggle),
                .init(id: "collateralContacts", label: "Collateral Contacts", kind: .toggle),
                .init(id: "diagnosticTests", label: "Diagnostic Tests", kind: .toggle),
                .init(id: "interviewSchedule", label: "Interview Schedule", kind: .longText),
                .init(id: "timeSpan", label: "Time Span of Data Collection", kind: .shortText)
            ]
        case .generalDescription:
            return [
                .init(id: "appearance", label: "Appearance", kind: .longText),
                .init(id: "behavior", label: "Behavior", kind: .longText),
                .init(id: "speech", label: "Speech", kind: .longText),
                .init(id: "moodAffect", label: "Mood & Affect", kind: .longText)
            ]
        case .familyComposition:
            return [
                .init(id: "nuclearFamily", label: "Nuclear Family", kind: .longText),
                .init(id: "extendedFamily", label: "Extended Family", kind: .longText),
                .init(id: "relationships", label: "Family Relationships", kind: .longText),
                .init(id: "substanceHistory", label: "Family Substance Abuse History", kind: .longText),
                .init(id: "legalHistory", label: "Family Legal History", kind: .longText),
                .init(id: "psychiatricHistory", label: "Family Psychiatric History", kind: .longText)
            ]
        case .educationalBackground:
            return [
                .init(id: "highestLevel", label: "Highest Level Completed", kind: .shortText),
                .init(id: "schools", label: "Schools Attended", kind: .longText),
                .init(id: "achievements", label: "Achievements", kind: .longText),
                .init(id: "difficulties", label: "Learning Difficulties", kind: .longText)
            ]
        case .employmentVocational:
            return [
                .init(id: "currentEmployment", label: "Current Employment", kind: .shortText),
                .init(id: "employmentHistory", label: "Employment History", kind: .longText),
                .init(id: "vocationalSkills", label: "Vocational Skills", kind: .longText),
                .init(id: "income", label: "Income / Financial Status", kind: .longText)
            ]
        case .religiousSpiritual:
            return [
                .init(id: "affiliation", label: "Religious Affiliation", kind: .shortText),
                .init(id: "practices", label: "Spiritual Practices", kind: .longText),
                .init(id: "supports", label: "Faith-based Supports", kind: .longText)
            ]
        case .physicalHealth:
            return [
                .init(id: "currentHealth", label: "Current Health Status", kind: .longText),
                .init(id: "medications", label: "Current Medications", kind: .longText),
                .init(id: "medicalHistory", label: "Medical History", kind: .longText),
                .init(id: "providers", label: "Healthcare Providers", kind: .longText)
            ]
        case .psychologicalPsychiatric:
            return [
                .init(id: "diagnoses", label: "Current Diagnoses", kind: .longText),
                .init(id: "treatmentHistory", label: "Treatment History", kind: .longText),
                .init(id: "hospitalizations", label: "Hospitalizations", kind: .longText),
                .init(id: "medications", label: "Psychiatric Medications", kind: .longText)
            ]
        case .socialCommunityRecreational:
            return [
                .init(id: "friendships", label: "Friendships & Peers", kind: .longText),
                .init(id: "community", label: "Community Involvement", kind: .longText),
                .init(id: "recreation", label: "Recreational Activities", kind: .longText)
            ]
        case .basicLifeNecessities:
            return [
                .init(id: "housing", label: "Housing", kind: .longText),
                .init(id: "food", label: "Food Security", kind: .longText),
                .init(id: "transportation", label: "Transportation", kind: .longText),
                .init(id: "clothing", label: "Clothing", kind: .longText)
            ]
        case .legalConcerns:
            return [
                .init(id: "currentLegal", label: "Current Legal Issues", kind: .longText),
                .init(id: "legalHistory", label: "Legal History", kind: .longText),
                .init(id: "probation", label: "Probation / Parole Status", kind: .shortText)
            ]
        case .otherPsychosocialFactors:
            return [
                .init(id: "cultural", label: "Cultural Factors", kind: .longText),
                .init(id: "trauma", label: "Trauma History", kind: .longText),
                .init(id: "other", label: "Other Relevant Factors", kind: .longText)
            ]
        case .strengthsCapacitiesResources:
            return [
                .init(id: "copingMethods", label: "Coping Methods", kind: .longText),
                .init(id: "strengths", label: "Personal Strengths", kind: .longText),
                .init(id: "problemSolving", label: "Problem-Solving Abilities", kind: .longText),
                .init(id: "supports", label: "Support Systems", kind: .longText),
                .init(id: "limitations", label: "Limitations", kind: .longText)
            ]
        case .clinicalSummary:
            return [
                .init(id: "primaryProblem", label: "Primary Problem", kind: .longText),
                .init(id: "secondaryProblems", label: "Secondary Problems", kind: .longText),
                .init(id: "urgency", label: "Urgency Level", kind: .shortText),
                .init(id: "moodAffect", label: "Mood & Affect Summary", kind: .longText),
                .init(id: "workerRelationship", label: "Client–Worker Relationship", kind: .longText),
                .init(id: "narrative", label: "Worker's Clinical Narrative", kind: .longText)
            ]
        case .goalsRecommendations:
            return [
                .init(id: "goals", label: "Goals", kind: .longText),
                .init(id: "services", label: "Recommended Services / Resources", kind: .longText),
                .init(id: "modality", label: "Intervention Modality", kind: .shortText),
                .init(id: "timeFrame", label: "Time Frame", kind: .shortText),
                .init(id: "narrative", label: "Worker's Recommendations Narrative", kind: .longText)
            ]
        }
    }
}
