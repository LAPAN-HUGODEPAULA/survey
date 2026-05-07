"""Model router with primary/fallback handling for LLM generation."""

from __future__ import annotations

import logging
from typing import Optional

from openai import OpenAI
from .agent_config import AgentConfig

logger = logging.getLogger("clinical_writer.model_router")


class ModelResponse:
    """Minimal wrapper to mimic LangChain message response."""

    def __init__(self, content: str):
        self.content = content


class GLMClient:
    """Lightweight GLM client using OpenAI SDK."""

    def __init__(
        self,
        *,
        model: str,
        api_key: Optional[str] = None,
        base_url: Optional[str] = None,
        temperature: Optional[float] = None,
        do_sample: Optional[bool] = None,
        thinking_mode: Optional[str] = None,
    ):
        self.model = model
        self._api_key = api_key or AgentConfig.GLM_API_KEY
        self._base_url = base_url or AgentConfig.GLM_BASE_URL
        self._temperature = temperature if temperature is not None else AgentConfig.LLM_TEMPERATURE
        self._do_sample = do_sample if do_sample is not None else AgentConfig.LLM_DO_SAMPLE
        self._thinking_mode = thinking_mode or AgentConfig.LLM_THINKING_MODE
        self._client = OpenAI(
            api_key=self._api_key,
            base_url=self._base_url,
            timeout=120.0,
        )

    def invoke(self, prompt: str) -> ModelResponse:
        """Execute chat completion via Zhipu AI / GLM."""
        # Map thinking_mode to GLM's expected structure.
        # Only models like glm-4-plus or specific reasoning models support "enabled".
        # Flash models usually require "disabled".
        if self._thinking_mode in {"medium", "high"}:
            thinking_config = {"type": "enabled", "effort": self._thinking_mode}
        else:
            thinking_config = {"type": "disabled"}

        logger.info("Invoking GLM model=%s thinking_mode=%s", self.model, self._thinking_mode)
        try:
            response = self._client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=self._temperature,
                extra_body={"thinking": thinking_config},
            )
            content = response.choices[0].message.content or ""
            logger.info("GLM invocation successful response_length=%d", len(content))
            return ModelResponse(content)
        except Exception as exc:
            logger.error("GLM invocation failed: %s", exc)
            raise


class ModelRouter:
    """Route a single generation call to primary or fallback LLM."""

    def __init__(
        self,
        *,
        primary_model: str,
        fallback_model: Optional[str] = None,
        primary_provider: str = "glm",
        fallback_provider: str = "gemini",
        api_key: Optional[str] = None,
        temperature: Optional[float] = None,
        do_sample: Optional[bool] = None,
        thinking_mode: Optional[str] = None,
        enable_caching: Optional[bool] = None,
    ):
        self._primary_model = primary_model
        self._fallback_model = fallback_model
        self._primary_provider = primary_provider
        self._fallback_provider = fallback_provider
        self._api_key = api_key
        self._temperature = temperature if temperature is not None else AgentConfig.LLM_TEMPERATURE
        self._do_sample = do_sample if do_sample is not None else AgentConfig.LLM_DO_SAMPLE
        self._thinking_mode = thinking_mode or AgentConfig.LLM_THINKING_MODE
        self._enable_caching = enable_caching if enable_caching is not None else AgentConfig.LLM_ENABLE_CACHING
        self._primary_llm = None
        self._fallback_llm = None
        self.model_version: Optional[str] = None

    @classmethod
    def from_env(cls) -> "ModelRouter":
        return cls(
            primary_model=AgentConfig.PRIMARY_MODEL,
            fallback_model=AgentConfig.FALLBACK_MODEL,
            temperature=AgentConfig.LLM_TEMPERATURE,
        )

    def invoke(self, prompt: str):
        try:
            logger.info("Attempting primary LLM: %s (%s)", self._primary_model, self._primary_provider)
            response = self._get_primary_llm().invoke(prompt)
            self.model_version = f"{self._primary_provider}:{self._primary_model}"
            logger.info(
                "Primary LLM succeeded: provider=%s model=%s",
                self._primary_provider,
                self._primary_model,
            )
            return response
        except Exception as exc:  # pylint: disable=broad-exception-caught
            if not self._fallback_model:
                logger.error("Primary LLM failed and no fallback configured: %s", exc)
                raise
            
            logger.warning(
                "Primary LLM failed, attempting fallback: primary_provider=%s primary_model=%s fallback_provider=%s fallback_model=%s error_type=%s error=%s",
                self._primary_provider,
                self._primary_model,
                self._fallback_provider,
                self._fallback_model,
                type(exc).__name__,
                exc,
            )
            try:
                response = self._get_fallback_llm().invoke(prompt)
                self.model_version = f"{self._fallback_provider}:{self._fallback_model}"
                logger.info(
                    "Fallback LLM succeeded: provider=%s model=%s",
                    self._fallback_provider,
                    self._fallback_model,
                )
                return response
            except Exception as fallback_exc:
                logger.error(
                    "Fallback LLM also failed: fallback_provider=%s fallback_model=%s error_type=%s error=%s",
                    self._fallback_provider,
                    self._fallback_model,
                    type(fallback_exc).__name__,
                    fallback_exc,
                )
                raise fallback_exc from exc

    def _get_primary_llm(self):
        if self._primary_llm is None:
            self._primary_llm = self._create_client(
                provider=self._primary_provider,
                model=self._primary_model,
                api_key=self._api_key,
                temperature=self._temperature,
                do_sample=self._do_sample,
                thinking_mode=self._thinking_mode,
            )
        return self._primary_llm

    def _get_fallback_llm(self):
        if self._fallback_llm is None:
            self._fallback_llm = self._create_client(
                provider=self._fallback_provider,
                model=self._fallback_model,
                api_key=self._api_key,
                temperature=self._temperature,
                do_sample=self._do_sample,
                thinking_mode=self._thinking_mode,
            )
        return self._fallback_llm

    def _create_client(
        self,
        provider: str,
        model: str,
        api_key: Optional[str],
        temperature: Optional[float],
        do_sample: Optional[bool] = None,
        thinking_mode: Optional[str] = None,
    ):
        if provider == "glm":
            return GLMClient(
                model=model,
                api_key=api_key,
                temperature=temperature,
                do_sample=do_sample,
                thinking_mode=thinking_mode,
            )
        # Default to Gemini
        return AgentConfig.create_llm_instance(
            api_key=api_key,
            model=model,
            temperature=temperature,
        )
