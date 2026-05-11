"""Psychosocial Analytics backend.

Currently exposes:
- GET  /health                           liveness check
- POST /api/ai/psychosocial-report       proxy to OpenAI-compatible chat completions

Future routes (auth, organizations, users, clients, assessments, reports CRUD)
should live under app/routers/. The schemas in app/schemas.py are the contract
between the iOS client and any future persistence layer.
"""

from __future__ import annotations

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .ai_client import AIClientError, generate_report
from .config import Settings, get_settings
from .schemas import GenerateReportRequest, GenerateReportResponse

app = FastAPI(
    title="Psychosocial Analytics API",
    version="0.1.0",
    description=(
        "Backend for the Psychosocial Analytics iOS app. Phase 1 only exposes the "
        "AI report-generation proxy. Persistence and auth follow."
    ),
)

# Permissive CORS for development; tighten before any non-localhost deployment.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/api/ai/psychosocial-report", response_model=GenerateReportResponse)
async def psychosocial_report(
    body: GenerateReportRequest,
    settings: Settings = Depends(get_settings),
) -> GenerateReportResponse:
    try:
        report, model, raw = await generate_report(
            assessment=body.assessment,
            settings=settings,
            model_override=body.model,
            temperature_override=body.temperature,
        )
    except AIClientError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    return GenerateReportResponse(report=report, model=model, raw=raw)
