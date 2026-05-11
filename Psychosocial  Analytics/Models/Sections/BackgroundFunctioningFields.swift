//
//  BackgroundFunctioningFields.swift
//  Psychosocial  Analytics
//

import Foundation

enum BackgroundFunctioningFields {
    static let familyComposition: [SectionFieldDefinition] = [
        .init(key: "household", label: "Household",
              prompt: "Current household members and roles.",
              kind: .longText, isRequired: true),
        .init(key: "family_of_origin", label: "Family of Origin",
              prompt: "Parents, siblings, caregivers, and significant childhood relationships.",
              kind: .longText, isRequired: false),
        .init(key: "significant_relationships", label: "Significant Relationships",
              prompt: "Partners, children, and other close relationships.",
              kind: .longText, isRequired: false),
        .init(key: "family_strengths_and_stressors", label: "Family Strengths and Stressors",
              prompt: "Sources of family support and ongoing stressors.",
              kind: .longText, isRequired: false)
    ]

    static let educationalBackground: [SectionFieldDefinition] = [
        .init(key: "educational_attainment", label: "Educational Attainment",
              prompt: "Highest level of education completed and certifications.",
              kind: .longText, isRequired: false),
        .init(key: "academic_performance", label: "Academic Performance",
              prompt: "Past and current academic performance and engagement.",
              kind: .longText, isRequired: false),
        .init(key: "learning_or_special_education", label: "Learning Needs or Special Education",
              prompt: "Documented learning needs, accommodations, or special education history.",
              kind: .longText, isRequired: false)
    ]

    static let employmentVocational: [SectionFieldDefinition] = [
        .init(key: "employment_status", label: "Employment Status",
              prompt: "Current employment status and role.",
              kind: .longText, isRequired: false),
        .init(key: "work_history", label: "Work History",
              prompt: "Notable work history and patterns.",
              kind: .longText, isRequired: false),
        .init(key: "vocational_skills", label: "Vocational Skills",
              prompt: "Skills, training, and vocational interests.",
              kind: .longText, isRequired: false),
        .init(key: "income_sources", label: "Income Sources",
              prompt: "Sources of income and financial stability.",
              kind: .longText, isRequired: false)
    ]

    static let religiousSpiritual: [SectionFieldDefinition] = [
        .init(key: "affiliation_and_practices", label: "Affiliation and Practices",
              prompt: "Religious or spiritual affiliation and current practices.",
              kind: .longText, isRequired: false),
        .init(key: "importance_to_client", label: "Importance to Client",
              prompt: "How important religion or spirituality is to the client.",
              kind: .longText, isRequired: false),
        .init(key: "supportive_community", label: "Supportive Community",
              prompt: "Faith- or spirituality-based community support available to the client.",
              kind: .longText, isRequired: false)
    ]

    static let physicalHealth: [SectionFieldDefinition] = [
        .init(key: "general_health_status", label: "General Health Status",
              prompt: "Client's overall physical health and self-reported wellbeing.",
              kind: .longText, isRequired: false),
        .init(key: "chronic_conditions", label: "Chronic Conditions",
              prompt: "Chronic medical conditions, allergies, and disabilities.",
              kind: .longText, isRequired: false),
        .init(key: "medications", label: "Medications",
              prompt: "Current prescribed and over-the-counter medications.",
              kind: .longText, isRequired: false),
        .init(key: "providers_and_treatment", label: "Providers and Treatment",
              prompt: "Treating physicians, dates of last visits, and adherence.",
              kind: .longText, isRequired: false),
        .init(key: "substance_use", label: "Substance Use",
              prompt: "Use of alcohol, tobacco, prescription, and other substances.",
              kind: .longText, isRequired: false)
    ]

    static let psychologicalPsychiatric: [SectionFieldDefinition] = [
        .init(key: "mental_health_history", label: "Mental Health History",
              prompt: "History of mental health treatment, hospitalizations, and outcomes.",
              kind: .longText, isRequired: false),
        .init(key: "current_diagnoses", label: "Current Diagnoses",
              prompt: "Current psychiatric diagnoses and treating providers.",
              kind: .longText, isRequired: false),
        .init(key: "psychiatric_medications", label: "Psychiatric Medications",
              prompt: "Current psychiatric medications and adherence.",
              kind: .longText, isRequired: false),
        .init(key: "safety_concerns", label: "Safety Concerns",
              prompt: "Suicidal or homicidal ideation, self-harm, or other safety concerns.",
              kind: .longText, isRequired: true),
        .init(key: "trauma_history", label: "Trauma History",
              prompt: "Trauma history that the client has chosen to share.",
              kind: .longText, isRequired: false)
    ]

    static let socialCommunityRecreational: [SectionFieldDefinition] = [
        .init(key: "social_supports", label: "Social Supports",
              prompt: "Friends, mentors, and peer supports the client can rely on.",
              kind: .longText, isRequired: false),
        .init(key: "community_involvement", label: "Community Involvement",
              prompt: "Community activities, civic engagement, and group memberships.",
              kind: .longText, isRequired: false),
        .init(key: "recreational_activities", label: "Recreational Activities",
              prompt: "Recreational and leisure activities the client enjoys.",
              kind: .longText, isRequired: false)
    ]

    static let basicLifeNecessities: [SectionFieldDefinition] = [
        .init(key: "housing_stability", label: "Housing Stability",
              prompt: "Current housing situation and stability.",
              kind: .longText, isRequired: true),
        .init(key: "food_security", label: "Food Security",
              prompt: "Access to consistent and adequate food.",
              kind: .longText, isRequired: false),
        .init(key: "transportation", label: "Transportation",
              prompt: "Access to transportation for work, healthcare, and daily life.",
              kind: .longText, isRequired: false),
        .init(key: "safety_at_home", label: "Safety at Home",
              prompt: "Safety in current living environment, including any abuse or violence concerns.",
              kind: .longText, isRequired: true)
    ]

    static let legalConcerns: [SectionFieldDefinition] = [
        .init(key: "current_legal_matters", label: "Current Legal Matters",
              prompt: "Active legal cases, court orders, or compliance requirements.",
              kind: .longText, isRequired: false),
        .init(key: "legal_history", label: "Legal History",
              prompt: "Notable past legal involvement.",
              kind: .longText, isRequired: false),
        .init(key: "probation_parole_immigration", label: "Probation, Parole, or Immigration",
              prompt: "Probation, parole, or immigration status that affects the client.",
              kind: .longText, isRequired: false)
    ]

    static let otherPsychosocialFactors: [SectionFieldDefinition] = [
        .init(key: "environmental_stressors", label: "Environmental Stressors",
              prompt: "Neighborhood, environmental, or systemic stressors.",
              kind: .longText, isRequired: false),
        .init(key: "discrimination_or_oppression", label: "Discrimination or Oppression",
              prompt: "Experiences of discrimination, oppression, or marginalization.",
              kind: .longText, isRequired: false),
        .init(key: "recent_life_events", label: "Recent Life Events",
              prompt: "Significant recent life events or transitions.",
              kind: .longText, isRequired: false)
    ]

    static let strengthsCapacitiesResources: [SectionFieldDefinition] = [
        .init(key: "personal_strengths", label: "Personal Strengths",
              prompt: "Personal strengths and capacities the client brings.",
              kind: .longText, isRequired: true),
        .init(key: "coping_skills", label: "Coping Skills",
              prompt: "Coping strategies the client uses effectively.",
              kind: .longText, isRequired: false),
        .init(key: "existing_supports", label: "Existing Supports",
              prompt: "Formal and informal supports already in place.",
              kind: .longText, isRequired: false),
        .init(key: "motivation_for_change", label: "Motivation for Change",
              prompt: "Stated motivation for change and engagement.",
              kind: .longText, isRequired: false)
    ]
}
