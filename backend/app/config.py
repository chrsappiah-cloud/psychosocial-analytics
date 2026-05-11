"""Runtime configuration for the Psychosocial Analytics backend."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="PSA_", extra="ignore")

    ai_base_url: str = "https://api.openai.com/v1"
    ai_model: str = "gpt-4o-mini"
    ai_api_key: str | None = None
    ai_temperature: float = 0.2
    ai_request_timeout_seconds: float = 60.0


@lru_cache
def get_settings() -> Settings:
    return Settings()
