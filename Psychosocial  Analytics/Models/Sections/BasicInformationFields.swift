//
//  BasicInformationFields.swift
//  Psychosocial  Analytics
//

import Foundation

enum BasicInformationFields {
    static let identifyingInformation: [SectionFieldDefinition] = [
        .init(key: "full_name", label: "Full Name",
              prompt: "Client's full legal name.",
              kind: .shortText, isRequired: true),
        .init(key: "date_of_birth", label: "Date of Birth",
              prompt: "Client's date of birth.",
              kind: .date, isRequired: true),
        .init(key: "gender_identity", label: "Gender Identity & Pronouns",
              prompt: "Self-identified gender and pronouns.",
              kind: .shortText, isRequired: false),
        .init(key: "contact_information", label: "Contact Information",
              prompt: "Address, phone, and email used to reach the client.",
              kind: .longText, isRequired: false),
        .init(key: "household_composition", label: "Household Composition",
              prompt: "Members of the current household and their relationship to the client.",
              kind: .longText, isRequired: false)
    ]

    static let referral: [SectionFieldDefinition] = [
        .init(key: "referred_by", label: "Referred By",
              prompt: "Person, agency, or system that initiated the referral.",
              kind: .shortText, isRequired: true),
        .init(key: "referral_date", label: "Referral Date",
              prompt: "Date the referral was received.",
              kind: .date, isRequired: false),
        .init(key: "reason_for_referral", label: "Reason for Referral",
              prompt: "Concerns and goals stated at the time of referral.",
              kind: .longText, isRequired: true),
        .init(key: "prior_services", label: "Prior Services",
              prompt: "Services the client has already received related to the referral concern.",
              kind: .longText, isRequired: false)
    ]

    static let presentingProblem: [SectionFieldDefinition] = [
        .init(key: "problem_description", label: "Problem Description",
              prompt: "How the client describes the presenting problem in their own words.",
              kind: .longText, isRequired: true),
        .init(key: "onset_and_duration", label: "Onset and Duration",
              prompt: "When the problem began, frequency, and how long it has persisted.",
              kind: .longText, isRequired: false),
        .init(key: "impact_on_functioning", label: "Impact on Functioning",
              prompt: "Effect on daily life, relationships, work, school, and health.",
              kind: .longText, isRequired: true),
        .init(key: "prior_attempts", label: "Prior Attempts to Address",
              prompt: "Strategies the client has already tried, and what helped or did not help.",
              kind: .longText, isRequired: false)
    ]

    static let sourcesOfData: [SectionFieldDefinition] = [
        .init(key: "interviews_conducted", label: "Interviews Conducted",
              prompt: "Who was interviewed (client, family, providers) and when.",
              kind: .longText, isRequired: true),
        .init(key: "documents_reviewed", label: "Documents Reviewed",
              prompt: "Records and documents reviewed during this assessment.",
              kind: .longText, isRequired: false),
        .init(key: "collateral_contacts", label: "Collateral Contacts",
              prompt: "Collateral contacts consulted with consent.",
              kind: .longText, isRequired: false)
    ]

    static let generalDescription: [SectionFieldDefinition] = [
        .init(key: "appearance_and_behavior", label: "Appearance and Behavior",
              prompt: "Observed appearance, hygiene, and behavior during contact.",
              kind: .longText, isRequired: true),
        .init(key: "mood_and_affect", label: "Mood and Affect",
              prompt: "Reported mood and observed affect.",
              kind: .longText, isRequired: false),
        .init(key: "speech_and_thought", label: "Speech and Thought",
              prompt: "Speech rate and content; thought process and content.",
              kind: .longText, isRequired: false),
        .init(key: "orientation_and_insight", label: "Orientation, Insight, and Judgment",
              prompt: "Orientation to person/place/time; insight and judgment as observed.",
              kind: .longText, isRequired: false)
    ]
}
