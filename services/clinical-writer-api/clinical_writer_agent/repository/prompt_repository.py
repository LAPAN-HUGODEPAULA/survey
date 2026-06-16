"""Prompt and persona repositories used by the clinical writer registry."""

from __future__ import annotations

import time
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Protocol

from pymongo import MongoClient

from ..prompts import ConversationPrompts, JsonPrompts


class PromptNotFoundError(RuntimeError):
    """Raised when a required prompt or persona cannot be resolved."""


class PromptRepository(Protocol):
    """Resolve a prompt text and version by runtime key."""

    def get_prompt(self, prompt_key: str) -> tuple[str, str]:
        """Return the prompt text and version."""


class PersonaRepository(Protocol):
    """Resolve persona instructions from runtime keys or output profiles."""

    def get_persona(
        self,
        *,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
    ) -> tuple[str, str, str, str | None]:
        """Return instructions, version, resolved key, and resolved output profile."""


@dataclass
class _CachedValue:
    value: Any
    expires_at: float


def _cache_lookup(cache: dict[str, _CachedValue], key: str) -> Any | None:
    cached = cache.get(key)
    now = time.monotonic()
    if cached and cached.expires_at > now:
        return cached.value
    if cached:
        cache.pop(key, None)
    return None


def _cache_store(
    cache: dict[str, _CachedValue],
    key: str,
    value: Any,
    cache_ttl_seconds: int,
) -> None:
    cache[key] = _CachedValue(
        value=value,
        expires_at=time.monotonic() + cache_ttl_seconds,
    )


def _build_version(document: dict[str, Any], prefix: str) -> str:
    modified_at = document.get("modifiedAt") or document.get("createdAt")
    if isinstance(modified_at, datetime):
        return f"{prefix}:{modified_at.isoformat()}"
    if modified_at:
        return f"{prefix}:{modified_at}"
    return f"{prefix}:unknown"


class LocalPromptRepository:
    """Local prompt fallback for offline and test execution."""

    def __init__(self) -> None:
        self._prompt_map = {
            "default": ConversationPrompts.MEDICAL_RECORD_PROMPT,
            "consult": ConversationPrompts.MEDICAL_RECORD_PROMPT,
            "survey7": JsonPrompts.MEDICAL_RECORD_PROMPT,
            "full_intake": JsonPrompts.MEDICAL_RECORD_PROMPT,
        }

    def get_prompt(self, prompt_key: str) -> tuple[str, str]:
        prompt = self._prompt_map.get(prompt_key)
        if not prompt:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' not found in local registry.")
        return prompt, f"local:{prompt_key}"


class MongoPromptRepository:
    """Mongo-backed prompt repository with TTL caching."""

    def __init__(
        self,
        *,
        mongo_uri: str | None = None,
        db_name: str | None = None,
        collection_name: str = "survey_prompts",
        cache_ttl_seconds: int = 60,
        server_selection_timeout_ms: int = 500,
        collection: Any | None = None,
    ) -> None:
        self._cache_ttl_seconds = cache_ttl_seconds
        self._cache: dict[str, _CachedValue] = {}
        self._client = None
        if collection is not None:
            self._collection = collection
            return
        if not mongo_uri or not db_name:
            raise ValueError("MongoPromptRepository requires mongo_uri and db_name.")
        self._client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=server_selection_timeout_ms,
        )
        self._collection = self._client[db_name][collection_name]

    def get_prompt(self, prompt_key: str) -> tuple[str, str]:
        cached = _cache_lookup(self._cache, prompt_key)
        if cached is not None:
            return cached

        try:
            document = self._collection.find_one({"promptKey": prompt_key})
        except Exception as exc:
            raise RuntimeError("Mongo prompt lookup unavailable.") from exc

        if not document:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' not found in MongoDB.")

        prompt_text = str(document.get("promptText") or "").strip()
        if not prompt_text:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' is empty in MongoDB.")

        resolved = (
            prompt_text,
            _build_version(document, "mongo_modifiedAt"),
        )
        _cache_store(self._cache, prompt_key, resolved, self._cache_ttl_seconds)
        return resolved


class MongoQuestionnairePromptRepository:
    """Mongo-backed questionnaire prompt repository with legacy fallback."""

    def __init__(
        self,
        *,
        mongo_uri: str | None = None,
        db_name: str | None = None,
        collection_name: str = "QuestionnairePrompts",
        legacy_collection_name: str = "survey_prompts",
        cache_ttl_seconds: int = 60,
        server_selection_timeout_ms: int = 500,
        collection: Any | None = None,
        legacy_collection: Any | None = None,
    ) -> None:
        self._cache_ttl_seconds = cache_ttl_seconds
        self._cache: dict[str, _CachedValue] = {}
        self._client = None
        if collection is not None and legacy_collection is not None:
            self._collection = collection
            self._legacy_collection = legacy_collection
            return
        if not mongo_uri or not db_name:
            raise ValueError(
                "MongoQuestionnairePromptRepository requires mongo_uri and db_name."
            )
        self._client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=server_selection_timeout_ms,
        )
        db = self._client[db_name]
        self._collection = db[collection_name]
        self._legacy_collection = db[legacy_collection_name]

    def get_prompt(self, prompt_key: str) -> tuple[str, str]:
        cached = _cache_lookup(self._cache, prompt_key)
        if cached is not None:
            return cached

        document = self._find_document(prompt_key)
        prompt_text = str(document.get("promptText") or "").strip()
        if not prompt_text:
            raise PromptNotFoundError(
                f"Questionnaire prompt '{prompt_key}' is empty in MongoDB."
            )
        resolved = (
            prompt_text,
            _build_version(document, "questionnaire_modifiedAt"),
        )
        _cache_store(self._cache, prompt_key, resolved, self._cache_ttl_seconds)
        return resolved

    def _find_document(self, prompt_key: str) -> dict[str, Any]:
        try:
            document = self._collection.find_one({"promptKey": prompt_key})
            if document:
                return document
            legacy_document = self._legacy_collection.find_one({"promptKey": prompt_key})
            if legacy_document:
                return legacy_document
        except Exception as exc:
            raise RuntimeError("Questionnaire prompt lookup unavailable.") from exc
        raise PromptNotFoundError(
            f"Questionnaire prompt '{prompt_key}' not found in MongoDB."
        )


class MongoPersonaRepository:
    """Mongo-backed persona repository with TTL caching."""

    def __init__(
        self,
        *,
        mongo_uri: str | None = None,
        db_name: str | None = None,
        collection_name: str = "PersonaSkills",
        cache_ttl_seconds: int = 60,
        server_selection_timeout_ms: int = 500,
        collection: Any | None = None,
    ) -> None:
        self._cache_ttl_seconds = cache_ttl_seconds
        self._cache: dict[str, _CachedValue] = {}
        self._client = None
        if collection is not None:
            self._collection = collection
            return
        if not mongo_uri or not db_name:
            raise ValueError("MongoPersonaRepository requires mongo_uri and db_name.")
        self._client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=server_selection_timeout_ms,
        )
        self._collection = self._client[db_name][collection_name]

    def get_persona(
        self,
        *,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
    ) -> tuple[str, str, str, str | None]:
        cache_key = f"{persona_skill_key or ''}|{output_profile or ''}"
        cached = _cache_lookup(self._cache, cache_key)
        if cached is not None:
            return cached

        try:
            document = None
            if persona_skill_key:
                document = self._collection.find_one(
                    {"personaSkillKey": persona_skill_key}
                )
            if document is None and output_profile:
                document = self._collection.find_one({"outputProfile": output_profile})
        except Exception as exc:
            raise RuntimeError("Persona skill lookup unavailable.") from exc

        if not document:
            missing = persona_skill_key or output_profile or "default"
            raise PromptNotFoundError(f"Persona skill '{missing}' not found in MongoDB.")

        instructions = str(document.get("instructions") or "").strip()
        if not instructions:
            key = (
                document.get("personaSkillKey")
                or persona_skill_key
                or output_profile
                or "unknown"
            )
            raise PromptNotFoundError(f"Persona skill '{key}' is empty in MongoDB.")

        resolved_key = (
            str(document.get("personaSkillKey") or persona_skill_key or "").strip()
            or ""
        )
        resolved_output_profile = (
            str(document.get("outputProfile") or output_profile or "").strip() or None
        )
        resolved = (
            instructions,
            _build_version(document, "persona_modifiedAt"),
            resolved_key,
            resolved_output_profile,
        )
        _cache_store(self._cache, cache_key, resolved, self._cache_ttl_seconds)
        return resolved
