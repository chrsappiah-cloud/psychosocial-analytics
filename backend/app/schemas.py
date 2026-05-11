"""Pydantic models that mirror the iOS Codable types in
Psychosocial  Analytics/Models/.

Field names are kept identical to the Swift CodingKeys so the iOS app can
post and decode without translation.
"""

from __future__ import annotations

from typing import Any
from uuid import UUID

from pydantic import BaseModel, Field


class FieldAnswer(BaseModel):
    id: UUID
    key: str
    label: str
    value: str
    sourceType: str = "self_report"


class AssessmentSectionPayload(BaseModel):
    id: UUID
    section: str  # AssessmentSection.rawValue
    answers: list[FieldAnswer]
    completionScore: float = 0.0
    lastEditedAt: str | None = None


class RiskFlag(BaseModel):
    id: UUID
    type: str
    severity: str
    note: str


class AIDraft(BaseModel):
    id: UUID
    type: str
    content: str
    model: str
    createdAt: str
    requiresHumanReview: bool = True


class SignatureRecord(BaseModel):
    id: UUID
    signedByUserID: UUID
    role: str
    signedAt: str


class Assessment(BaseModel):
    id: UUID
    organizationID: UUID
    createdByUserID: UUID
    clientID: UUID
    status: str
    sections: list[AssessmentSectionPayload]
    riskFlags: list[RiskFlag] = Field(default_factory=list)
    aiDrafts: list[AIDraft] = Field(default_factory=list)
    signatures: list[SignatureRecord] = Field(default_factory=list)
    createdAt: str
    updatedAt: str


class ReportGoalsBlock(BaseModel):
    shortTerm: list[str] = Field(default_factory=list)
    longTerm: list[str] = Field(default_factory=list)
    recommendedInterventions: list[str] = Field(default_factory=list)
    followUpPlan: str = ""


class RiskNote(BaseModel):
    id: UUID
    category: str
    severity: str
    sourceSection: str
    excerpt: str


class AssessmentReport(BaseModel):
    """Subset returned by the LLM. iOS adds id/generatedAt/modelIdentifier locally."""

    basicInformationNarrative: str
    backgroundAndFunctioningNarrative: str
    problems: str
    contributingFactors: str
    assetsAndResources: str
    diagnosticImpressions: str | None = None
    prognosis: str
    planForIntervention: str
    goals: ReportGoalsBlock
    sectionDrafts: dict[str, str] = Field(default_factory=dict)
    missingInformation: list[str] = Field(default_factory=list)


class GenerateReportRequest(BaseModel):
    """The shape iOS POSTs to /api/ai/psychosocial-report."""

    assessment: Assessment
    model: str | None = None
    temperature: float | None = None


class GenerateReportResponse(BaseModel):
    report: AssessmentReport
    model: str
    raw: dict[str, Any] | None = None
