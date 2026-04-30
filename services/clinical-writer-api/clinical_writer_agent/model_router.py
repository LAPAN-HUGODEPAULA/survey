"""Model router with primary/fallback handling for LLM generation."""

from __future__ import annotations

import logging
from typing import Optional, Any
import asyncio

from openai import AsyncOpenAI
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
    ):
        self.model = model
        self._api_key = api_key or AgentConfig.GLM_API_KEY
        self._base_url = base_url or AgentConfig.GLM_BASE_URL
        self._temperature = temperature if temperature is not None else AgentConfig.LLM_TEMPERATURE
        self._client = AsyncOpenAI(api_key=self._api_key, base_url=self._base_url)

    def invoke(self, prompt: str) -> ModelResponse:
        """Synchronous wrapper for async completion call."""
        return asyncio.run(self._ainvoke(prompt))

    async def _ainvoke(self, prompt: str) -> ModelResponse:
        """Execute chat completion via Zhipu AI / GLM."""
        response = await self._client.chat.completions.create(
            model=self.model,
            messages=[{"role": "user", "content": prompt}],
            temperature=self._temperature,
        )
        content = response.choices[0].message.content or ""
        return ModelResponse(content)


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
    ):
        self._primary_model = primary_model
        self._fallback_model = fallback_model
        self._primary_provider = primary_provider
        self._fallback_provider = fallback_provider
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
            temperature=AgentConfig.LLM_TEMPERATURE,
        )

    def invoke(self, prompt: str):
        try:
            logger.info("Attempting primary LLM: %s (%s)", self._primary_model, self._primary_provider)
            response = self._get_primary_llm().invoke(prompt)
            self.model_version = f"{self._primary_provider}:{self._primary_model}"
            return response
        except Exception as exc:  # pylint: disable=broad-exception-caught
            if not self._fallback_model:
                logger.error("Primary LLM failed and no fallback configured: %s", exc)
                raise
            
            logger.warning("Primary LLM failed, attempting fallback: %s. Error: %s", self._fallback_model, exc)
            try:
                response = self._get_fallback_llm().invoke(prompt)
                self.model_version = f"{self._fallback_provider}:{self._fallback_model}"
                return response
            except Exception as fallback_exc:
                logger.error("Fallback LLM also failed: %s", fallback_exc)
                raise fallback_exc from exc

    def _get_primary_llm(self):
        if self._primary_llm is None:
            self._primary_llm = self._create_client(
                provider=self._primary_provider,
                model=self._primary_model,
                api_key=self._api_key,
                temperature=self._temperature,
            )
        return self._primary_llm

    def _get_fallback_llm(self):
        if self._fallback_llm is None:
            self._fallback_llm = self._create_client(
                provider=self._fallback_provider,
                model=self._fallback_model,
                api_key=self._api_key,
                temperature=self._temperature,
            )
        return self._fallback_llm

    def _create_client(self, provider: str, model: str, api_key: Optional[str], temperature: Optional[float]):
        if provider == "glm":
            return GLMClient(
                model=model,
                api_key=api_key,
                temperature=temperature,
            )
        # Default to Gemini
        return AgentConfig.create_llm_instance(
            api_key=api_key,
            model=model,
            temperature=temperature,
        )
