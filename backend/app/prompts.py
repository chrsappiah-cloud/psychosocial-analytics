"""Prompt construction. Mirrors iOS ReportPromptBuilder so the same prompt is
used regardless of whether iOS calls an OpenAI-compatible endpoint directly or
goes through this backend proxy.
"""

from __future__ import annotations

from .schemas import Assessment

SYSTEM_PROMPT = """\
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

JSON_SCHEMA = """\
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

# Section title lookup keyed by AssessmentSection.rawValue (kept in sync with the
# Swift enum in Psychosocial  Analytics/Models/AssessmentSection.swift).
SECTION_TITLES: dict[str, str] = {
    "identifyingInformation": "Identifying Information",
    "referral": "Referral",
    "presentingProblem": "Presenting Problem",
    "sourcesOfData": "Sources of Data",
    "generalDescription": "General Description of Client",
    "familyComposition": "Family Composition and Background",
    "educationalBackground": "Educational Background",
    "employmentVocational": "Employment and Vocational Skills",
    "religiousSpiritual": "Religious and Spiritual Involvement",
    "physicalHealth": "Physical Functioning, Health, and Medical Background",
    "psychologicalPsychiatric": "Psychological and Psychiatric Functioning",
    "socialCommunityRecreational": "Social, Community, and Recreational Activities",
    "basicLifeNecessities": "Basic Life Necessities",
    "legalConcerns": "Legal Concerns",
    "otherPsychosocialFactors": "Other Environmental or Psychosocial Factors",
    "strengthsCapacitiesResources": "Client Strengths, Capacities, and Resources",
    "clinicalSummary": "Clinical Summary, Impressions, and Assessment",
    "goalsRecommendations": "Goals and Recommendations",
}


def build_user_prompt(assessment: Assessment) -> str:
    lines: list[str] = []
    lines.append(f"Client identifier: {assessment.clientID}")
    lines.append(f"Created at: {assessment.createdAt}")
    lines.append("")
    lines.append("Section answers:")
    for payload in assessment.sections:
        title = SECTION_TITLES.get(payload.section, payload.section)
        lines.append("")
        lines.append(f"## {title}")
        for answer in payload.answers:
            value = answer.value if answer.value else "[blank]"
            lines.append(f"- {answer.label}: {value}")
    lines.append("")
    lines.append("Produce a draft assessment report as JSON conforming to the schema.")
    return "\n".join(lines)


def build_system_prompt() -> str:
    return (
        SYSTEM_PROMPT
        + "\n\nReturn ONLY a JSON object matching the following schema. No prose.\nSchema:\n"
        + JSON_SCHEMA
    )
