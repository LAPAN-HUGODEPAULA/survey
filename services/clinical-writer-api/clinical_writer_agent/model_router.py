"""Model router with primary/fallback handling for LLM generation."""

from __future__ import annotations

from typing import Optional

from .agent_config import AgentConfig

try:  # Best-effort imports for API retry classification.
    from google.api_core.exceptions import (
        GoogleAPICallError,
        RetryError,
        DeadlineExceeded,
        ServiceUnavailable,
        InternalServerError,
    )
except Exception:  # pragma: no cover - optional dependency
    GoogleAPICallError = RetryError = DeadlineExceeded = ServiceUnavailable = InternalServerError = ()  # type: ignore


class ModelRouter:
    """Route a single generation call to primary or fallback LLM."""

    def __init__(
        self,
        *,
        primary_model: str,
        fallback_model: Optional[str] = None,
        api_key: Optional[str] = None,
        temperature: Optional[float] = None,
    ):
        self._primary_model = primary_model
        self._fallback_model = fallback_model
        self._api_key = api_key
        self._temperature = temperature
        self._primary_llm = None
        self._fallback_llm = None
        self.model_version: Optional[str] = None

    @classmethod
    def from_env(cls) -> "ModelRouter":
        return cls(
            primary_model=AgentConfig.PRIMARY_MODEL,
            fallback_model=AgentConfig.FALLBACK_MODEL,
            api_key=AgentConfig.GEMINI_API_KEY,
            temperature=AgentConfig.LLM_TEMPERATURE,
        )

    def invoke(self, prompt: str):
        try:
            response = self._get_primary_llm().invoke(prompt)
            self.model_version = self._primary_model
            return response
        except Exception as exc:  # pylint: disable=broad-exception-caught
            if not self._fallback_model or not self._is_retryable(exc):
                raise

        response = self._get_fallback_llm().invoke(prompt)
        self.model_version = self._fallback_model
        return response

    def _get_primary_llm(self):
        if self._primary_llm is None:
            self._primary_llm = AgentConfig.create_llm_instance(
                api_key=self._api_key,
                model=self._primary_model,
                temperature=self._temperature,
            )
        return self._primary_llm

    def _get_fallback_llm(self):
        if self._fallback_llm is None:
            self._fallback_llm = AgentConfig.create_llm_instance(
                api_key=self._api_key,
                model=self._fallback_model,
                temperature=self._temperature,
            )
        return self._fallback_llm

    @staticmethod
    def _is_retryable(error: Exception) -> bool:
        return isinstance(
            error,
            (
                TimeoutError,
                ConnectionError,
                OSError,
                GoogleAPICallError,
                RetryError,
                DeadlineExceeded,
                ServiceUnavailable,
                InternalServerError,
            ),
        )
