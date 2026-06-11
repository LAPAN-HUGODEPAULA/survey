"""Shared AI agent catalog seed data for Mongo migrations."""

from __future__ import annotations

import os
from datetime import datetime, timezone


AI_AGENT_SEED_SOURCE = "default_ai_agents_v1"


def _local_qwen_base_url() -> str:
    host = os.getenv("AI_API_HOST", "lapan-ai.tailf9eac9.ts.net")
    port = os.getenv("AI_API_PORT")
    if port:
        return f"https://{host}:{port}/v1"
    return f"https://{host}/v1"


def build_ai_agent_documents(
    source_tag: str,
    *,
    timestamp: datetime | None = None,
) -> list[dict]:
    """Return default AI agent catalog documents."""
    resolved_timestamp = timestamp or datetime.now(timezone.utc)
    documents = [
        {
            "agentKey": "local_qwen",
            "name": "Local Qwen Coder",
            "providerType": "openai_compatible",
            "baseUrl": _local_qwen_base_url(),
            "apiKeyEnvVar": "AI_API_KEY",
            "defaultModel": "qwen2.5-coder:7b",
            "enabled": True,
            "supportsOpenAIChatCompletions": True,
            "supportsResponseFormat": True,
            "supportsRag": True,
            "notes": "Local Tailscale OpenAI-compatible gateway.",
        },
        {
            "agentKey": "glm",
            "name": "Zhipu AI GLM",
            "providerType": "glm",
            "baseUrl": os.getenv("GLM_BASE_URL", "https://api.z.ai/api/paas/v4/"),
            "apiKeyEnvVar": "GLM_API_KEY",
            "defaultModel": os.getenv("GLM_MODEL", "glm-4.5-flash"),
            "enabled": bool(os.getenv("GLM_API_KEY")),
            "supportsOpenAIChatCompletions": True,
            "supportsResponseFormat": False,
            "supportsRag": False,
            "notes": "Legacy GLM provider.",
        },
        {
            "agentKey": "gemini",
            "name": "Google Gemini",
            "providerType": "gemini",
            "baseUrl": None,
            "apiKeyEnvVar": "GEMINI_API_KEY",
            "defaultModel": os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
            "enabled": bool(os.getenv("GEMINI_API_KEY")),
            "supportsOpenAIChatCompletions": False,
            "supportsResponseFormat": False,
            "supportsRag": False,
            "notes": "Legacy Gemini fallback provider.",
        },
    ]
    return [
        {
            **document,
            "createdAt": resolved_timestamp,
            "modifiedAt": resolved_timestamp,
            "seedSource": AI_AGENT_SEED_SOURCE,
            "seedAppliedBy": source_tag,
        }
        for document in documents
    ]
