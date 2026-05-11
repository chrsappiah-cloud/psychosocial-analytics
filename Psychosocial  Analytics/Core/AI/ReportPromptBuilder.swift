//
//  ReportPromptBuilder.swift
//  Psychosocial  Analytics
//

import Foundation

enum ReportPromptBuilder {
    struct Prompt {
        let system: String
        let user: String
        let jsonSchema: String
    }

    static let systemPrompt: String = """
    You are an assistant supporting licensed social workers in drafting psychosocial \
    assessments. A psychosocial assessment is a written summary of a client's problems, \
    contributing factors, assets and resources, prognosis, and plan for intervention.

    Reproduce the source document's information architecture exactly:
    1) Basic Information: Identifying Information, Referral, Presenting Problem, \
    Sources of Data, General Description of Client.
    2) Background and Current Functioning: Family Composition, Educational Background, \
    Employment and Vocational Skills, Religious and Spiritual Involvement, Physical \
    Functioning, Psychological and Psychiatric Functioning, Social/Community/Recreational \
    Activities, Basic Life Necessities, Legal Concerns, Other Environmental or \
    Psychosocial Factors, Client Strengths and Resources.
    3) Impressions and Recommendations: Clinical Summary, Goals and Recommendations.

    Rules:
    - Use only information present in the supplied answers. Do not fabricate facts.
    - Mark every section that lacks data with a clear "Insufficient information" note.
    - Surface safeguarding concerns (self-harm, abuse, violence, relapse, housing) explicitly.
    - Output strictly valid JSON conforming to the supplied schema. Do not include any \
    text outside the JSON.
    - All output is a draft requiring clinician review and signature before any use.
    """

    static func build(for assessment: Assessment, modelIdentifier: String) -> Prompt {
        let user = userPrompt(for: assessment)
        return Prompt(system: systemPrompt, user: user, jsonSchema: jsonSchema)
    }

    static func userPrompt(for assessment: Assessment) -> String {
        var lines: [String] = []
        lines.append("Client identifier: \(assessment.clientID.uuidString)")
        lines.append("Created at: \(assessment.createdAt.ISO8601Format())")
        lines.append("")
        lines.append("Section answers:")
        for payload in assessment.sections {
            lines.append("")
            lines.append("## \(payload.section.title)")
            for answer in payload.answers {
                let value = answer.value.isEmpty ? "[blank]" : answer.value
                lines.append("- \(answer.label): \(value)")
            }
        }
        lines.append("")
        lines.append("Produce a draft assessment report as JSON conforming to the schema.")
        return lines.joined(separator: "\n")
    }

    static let jsonSchema: String = """
    {
      "type": "object",
      "required": [
        "basicInformationNarrative", "backgroundAndFunctioningNarrative",
        "problems", "contributingFactors", "assetsAndResources",
        "prognosis", "planForIntervention", "goals", "missingInformation"
      ],
      "properties": {
        "basicInformationNarrative": {"type": "string"},
        "backgroundAndFunctioningNarrative": {"type": "string"},
        "problems": {"type": "string"},
        "contributingFactors": {"type": "string"},
        "assetsAndResources": {"type": "string"},
        "diagnosticImpressions": {"type": "string"},
        "prognosis": {"type": "string"},
        "planForIntervention": {"type": "string"},
        "goals": {
          "type": "object",
          "required": ["shortTerm", "longTerm", "recommendedInterventions", "followUpPlan"],
          "properties": {
            "shortTerm": {"type": "array", "items": {"type": "string"}},
            "longTerm": {"type": "array", "items": {"type": "string"}},
            "recommendedInterventions": {"type": "array", "items": {"type": "string"}},
            "followUpPlan": {"type": "string"}
          }
        },
        "sectionDrafts": {
          "type": "object",
          "additionalProperties": {"type": "string"}
        },
        "missingInformation": {"type": "array", "items": {"type": "string"}}
      }
    }
    """
}
