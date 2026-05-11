"""Thin OpenAI-compatible chat completions client."""

from __future__ import annotations

import json
from typing import Any

import httpx

from .config import Settings
from .prompts import build_system_prompt, build_user_prompt
from .schemas import Assessment, AssessmentReport


class AIClientError(RuntimeError):
    pass


async def generate_report(
    assessment: Assessment,
    settings: Settings,
    model_override: str | None = None,
    temperature_override: float | None = None,
) -> tuple[AssessmentReport, str, dict[str, Any]]:
    """POST the structured prompt to an OpenAI-compatible /chat/completions
    endpoint and parse the JSON response into an AssessmentReport.
    """

    if not settings.ai_api_key:
        raise AIClientError(
            "PSA_AI_API_KEY is not configured. Set it via .env or environment."
        )

    base = settings.ai_base_url.rstrip("/")
    endpoint = f"{base}/chat/completions"
    model = model_override or settings.ai_model
    temperature = (
        temperature_override if temperature_override is not None else settings.ai_temperature
    )

    payload: dict[str, Any] = {
        "model": model,
        "temperature": temperature,
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": build_system_prompt()},
            {"role": "user", "content": build_user_prompt(assessment)},
        ],
    }
    headers = {
        "Authorization": f"Bearer {settings.ai_api_key}",
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=settings.ai_request_timeout_seconds) as client:
        response = await client.post(endpoint, headers=headers, json=payload)

    if response.status_code >= 400:
        raise AIClientError(
            f"AI provider returned HTTP {response.status_code}: {response.text[:400]}"
        )

    raw = response.json()
    try:
        content = raw["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as exc:
        raise AIClientError(f"Unexpected response shape: {exc!r}") from exc

    try:
        report_dict = json.loads(content)
    except json.JSONDecodeError as exc:
        raise AIClientError(f"Model did not return valid JSON: {exc}") from exc

    try:
        report = AssessmentReport.model_validate(report_dict)
    except Exception as exc:  # pydantic.ValidationError
        raise AIClientError(f"Model JSON did not match schema: {exc}") from exc

    return report, model, raw
