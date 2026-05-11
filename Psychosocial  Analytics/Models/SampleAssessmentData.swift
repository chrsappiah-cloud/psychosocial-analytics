//
//  SampleAssessmentData.swift
//  Psychosocial  Analytics
//

import Foundation

enum SampleAssessmentData {
    static func seededDraft() -> AssessmentDraft {
        let draft = AssessmentDraft(clientName: "J. Rivera (Sample)")
        var payload = AssessmentPayload()
        for (section, raw) in samples {
            let defs = SectionTemplateLibrary.template(for: section).definitions
            let answers = defs.map { def in
                FieldAnswer(
                    id: UUID(),
                    key: def.key,
                    label: def.label,
                    value: raw[def.key] ?? "",
                    sourceType: "self_report"
                )
            }
            payload.setAnswers(answers, for: section)
        }
        draft.assessmentPayload = payload
        return draft
    }

    private static let samples: [AssessmentSection: [String: String]] = [
        .identifyingInformation: [
            "full_name": "Jordan Rivera",
            "date_of_birth": "1989-03-14",
            "gender_identity": "Nonbinary, they/them",
            "contact_information": "421 Pine St, Apt 6B; (555) 010-2233; jordan@example.com",
            "household_composition": "Lives with one roommate and a service dog."
        ],
        .referral: [
            "referred_by": "Dr. P. Han, primary care physician",
            "referral_date": "2026-04-22",
            "reason_for_referral": "Persistent low mood, sleep disruption, and difficulty maintaining employment after a recent job loss.",
            "prior_services": "Brief CBT-based counseling in 2023, six sessions, self-discontinued."
        ],
        .presentingProblem: [
            "problem_description": "Client reports feeling 'flat and exhausted' for the past four months, with intermittent anxiety in social settings.",
            "onset_and_duration": "Symptoms intensified after a layoff in January and have continued daily since.",
            "impact_on_functioning": "Reduced engagement at home, missed two interviews, isolating from friends.",
            "prior_attempts": "Tried journaling and increased exercise; reports temporary relief only."
        ],
        .sourcesOfData: [
            "interviews_conducted": "Two clinical interviews with the client (May 2 and May 9, 2026).",
            "documents_reviewed": "PHQ-9 and GAD-7 self-report screeners; primary care referral note.",
            "collateral_contacts": "Roommate consulted with consent; confirmed sleep and appetite changes."
        ],
        .generalDescription: [
            "appearance_and_behavior": "Casually dressed, well groomed, cooperative throughout interview.",
            "mood_and_affect": "Mood reported as 'tired'; affect constricted but congruent.",
            "speech_and_thought": "Speech normal rate; thought process linear, no perceptual disturbances reported.",
            "orientation_and_insight": "Alert and oriented x4; insight fair, judgment intact."
        ],
        .familyComposition: [
            "household": "Two-person household with roommate of three years.",
            "family_of_origin": "Raised by single mother in Phoenix; one younger sibling.",
            "significant_relationships": "Close to sibling; limited recent contact with mother due to distance.",
            "family_strengths_and_stressors": "Sibling provides emotional support; mother's recent illness is a stressor."
        ],
        .educationalBackground: [
            "educational_attainment": "Bachelor's degree in Graphic Design (2012).",
            "academic_performance": "Above-average academic performance; reports enjoying coursework.",
            "learning_or_special_education": "No documented learning needs."
        ],
        .employmentVocational: [
            "employment_status": "Currently unemployed; actively seeking design contracts.",
            "work_history": "Eight years in editorial design; laid off in January 2026.",
            "vocational_skills": "Strong skills in visual design, typography, brand systems.",
            "income_sources": "Relying on savings and small freelance work."
        ],
        .religiousSpiritual: [
            "affiliation_and_practices": "Identifies as spiritual but not affiliated with a tradition.",
            "importance_to_client": "Moderate; meditation is part of a daily routine.",
            "supportive_community": "Online meditation group provides occasional support."
        ],
        .physicalHealth: [
            "general_health_status": "Generally good; recent fatigue and disrupted sleep.",
            "chronic_conditions": "Mild seasonal asthma; well controlled.",
            "medications": "Albuterol inhaler as needed.",
            "providers_and_treatment": "Sees PCP annually; last visit April 2026.",
            "substance_use": "Occasional alcohol; reports no substance misuse."
        ],
        .psychologicalPsychiatric: [
            "mental_health_history": "Brief therapy in 2023 for adjustment difficulties.",
            "current_diagnoses": "No current diagnosis; pending evaluation.",
            "psychiatric_medications": "None currently.",
            "safety_concerns": "Denies current suicidal or homicidal ideation; passive thoughts of 'wanting to disappear' last month, no plan or intent.",
            "trauma_history": "Reports witnessing domestic violence in childhood; declined to elaborate at this time."
        ],
        .socialCommunityRecreational: [
            "social_supports": "Two close friends and sibling.",
            "community_involvement": "Volunteers monthly at a community design workshop.",
            "recreational_activities": "Cycling, illustration, hiking with service dog."
        ],
        .basicLifeNecessities: [
            "housing_stability": "Stable rental for past three years; able to make rent through July.",
            "food_security": "Adequate; budgeting carefully.",
            "transportation": "Reliable bicycle and public transit access.",
            "safety_at_home": "Reports feeling safe at home; no concerns of abuse or violence."
        ],
        .legalConcerns: [
            "current_legal_matters": "None reported.",
            "legal_history": "None reported.",
            "probation_parole_immigration": "Not applicable."
        ],
        .otherPsychosocialFactors: [
            "environmental_stressors": "Recent layoff; rising cost of living.",
            "discrimination_or_oppression": "Reports occasional workplace microaggressions related to gender identity.",
            "recent_life_events": "Job loss in January; mother's illness in March."
        ],
        .strengthsCapacitiesResources: [
            "personal_strengths": "Insightful, articulate, motivated to engage in change.",
            "coping_skills": "Daily meditation, journaling, exercise.",
            "existing_supports": "Roommate, sibling, online meditation group, PCP.",
            "motivation_for_change": "High; client is actively seeking treatment and structure."
        ],
        .clinicalSummary: [
            "problems_summary": "Persistent low mood, sleep disruption, and reduced occupational functioning following job loss.",
            "contributing_factors": "Recent layoff, financial pressure, family stressor, history of childhood adversity.",
            "assets_and_resources": "Strong insight, stable housing, supportive sibling and roommate, established PCP, daily coping practices.",
            "diagnostic_impressions": "Provisional adjustment disorder with depressed mood; rule out major depressive episode pending further evaluation.",
            "prognosis": "Favorable with timely intervention given strong supports and high motivation."
        ],
        .goalsRecommendations: [
            "short_term_goals": "Establish weekly therapy; restore consistent sleep within four weeks; complete two job applications per week.",
            "long_term_goals": "Return to stable employment within six months; sustain engagement in mental health treatment.",
            "recommended_interventions": "Weekly individual therapy (CBT-focused); psychiatric evaluation if symptoms persist; vocational counseling.",
            "referrals": "Community mental health clinic; vocational rehabilitation service.",
            "follow_up_plan": "Two-week follow-up to monitor sleep and engagement; coordinate with PCP every six weeks."
        ]
    ]
}
