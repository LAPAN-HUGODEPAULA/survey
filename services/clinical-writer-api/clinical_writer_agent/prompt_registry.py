import json
import logging
import os
import time
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Optional, Tuple

from .prompts import ConversationPrompts, JsonPrompts

logger = logging.getLogger("clinical_writer.prompt_registry")

SURVEY_INPUT_TYPES = {"survey7", "full_intake"}
DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE = {
    "survey7": "patient_condition_overview",
    "full_intake": "clinical_diagnostic_report",
}
DEFAULT_PERSONA_KEY_BY_OUTPUT_PROFILE = {
    "patient_condition_overview": "patient_condition_overview",
    "clinical_diagnostic_report": "clinical_diagnostic_report",
    "clinical_referral_letter": "clinical_referral_letter",
    "parental_guidance": "parental_guidance",
    "educational_support_summary": "school_report",
    "school_report": "school_report",
}


class PromptNotFoundError(RuntimeError):
    pass


@dataclass(frozen=True)
class ResolvedPrompt:
    prompt_text: str
    prompt_version: str
    interpretation_prompt: str | None = None
    persona_prompt: str | None = None
    questionnaire_prompt_version: str | None = None
    persona_skill_version: str | None = None
    persona_skill_key: str | None = None
    output_profile: str | None = None


class PromptRegistry:
    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        raise NotImplementedError

    def resolve_process_prompt(
        self,
        *,
        input_type: str,
        prompt_key: str,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
    ) -> ResolvedPrompt:
        prompt_text, prompt_version = self.get_prompt(prompt_key)
        return ResolvedPrompt(
            prompt_text=prompt_text,
            prompt_version=prompt_version,
            interpretation_prompt=prompt_text,
            persona_prompt=prompt_text,
        )


class CompositePromptProvider(PromptRegistry):
    def __init__(self, providers: list[PromptRegistry]):
        self._providers = providers

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        last_error: PromptNotFoundError | None = None
        for provider in self._providers:
            try:
                return provider.get_prompt(prompt_key)
            except PromptNotFoundError as exc:
                last_error = exc
                continue
            except RuntimeError as exc:
                logger.warning("Prompt provider unavailable for key=%s: %s", prompt_key, exc)
                continue
        if last_error is not None:
            raise last_error
        raise PromptNotFoundError(f"Prompt '{prompt_key}' could not be resolved.")


class LocalPromptProvider(PromptRegistry):
    def __init__(self):
        self._prompt_map = {
            "default": ConversationPrompts.MEDICAL_RECORD_PROMPT,
            "consult": ConversationPrompts.MEDICAL_RECORD_PROMPT,
            "survey7": JsonPrompts.MEDICAL_RECORD_PROMPT,
            "full_intake": JsonPrompts.MEDICAL_RECORD_PROMPT,
        }

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        prompt = self._prompt_map.get(prompt_key)
        if not prompt:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' not found in local registry.")
        return prompt, f"local:{prompt_key}"


@dataclass
class _CachedPrompt:
    prompt_text: str
    version: str
    expires_at: float


class MongoPromptProvider(PromptRegistry):
    def __init__(
        self,
        mongo_uri: str,
        db_name: str,
        collection_name: str = "survey_prompts",
        cache_ttl_seconds: int = 60,
        server_selection_timeout_ms: int = 500,
    ):
        from pymongo import MongoClient

        self._cache_ttl_seconds = cache_ttl_seconds
        self._cache: Dict[str, _CachedPrompt] = {}
        self._client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=server_selection_timeout_ms,
        )
        self._collection = self._client[db_name][collection_name]

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        cached = self._cache.get(prompt_key)
        now = time.monotonic()
        if cached and cached.expires_at > now:
            return cached.prompt_text, cached.version

        try:
            document = self._collection.find_one({"promptKey": prompt_key})
        except Exception as exc:
            raise RuntimeError("Mongo prompt lookup unavailable.") from exc

        if not document:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' not found in MongoDB.")

        prompt_text = str(document.get("promptText") or "").strip()
        if not prompt_text:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' is empty in MongoDB.")

        version = self._build_version(document)
        self._cache[prompt_key] = _CachedPrompt(
            prompt_text=prompt_text,
            version=version,
            expires_at=now + self._cache_ttl_seconds,
        )
        return prompt_text, version

    def _build_version(self, document: dict) -> str:
        modified_at = document.get("modifiedAt") or document.get("createdAt")
        if isinstance(modified_at, datetime):
            return f"mongo_modifiedAt:{modified_at.isoformat()}"
        if modified_at:
            return f"mongo_modifiedAt:{modified_at}"
        return "mongo_modifiedAt:unknown"


class QuestionnairePromptProvider:
    """Loads questionnaire clinical logic from canonical and legacy Mongo collections."""

    def __init__(
        self,
        mongo_uri: str,
        db_name: str,
        *,
        collection_name: str = "QuestionnairePrompts",
        legacy_collection_name: str = "survey_prompts",
        server_selection_timeout_ms: int = 500,
    ):
        from pymongo import MongoClient

        self._client = MongoClient(
            mongo_uri,
            serverSelectionTimeoutMS=server_selection_timeout_ms,
        )
        db = self._client[db_name]
        self._collection = db[collection_name]
        self._legacy_collection = db[legacy_collection_name]

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        document = self._find_document(prompt_key)
        prompt_text = str(document.get("promptText") or "").strip()
        if not prompt_text:
            raise PromptNotFoundError(f"Questionnaire prompt '{prompt_key}' is empty in MongoDB.")
        return prompt_text, self._build_version(document)

    def _find_document(self, prompt_key: str) -> dict:
        try:
            document = self._collection.find_one({"promptKey": prompt_key})
            if document:
                return document
            legacy_document = self._legacy_collection.find_one({"promptKey": prompt_key})
            if legacy_document:
                return legacy_document
        except Exception as exc:
            raise RuntimeError("Questionnaire prompt lookup unavailable.") from exc
        raise PromptNotFoundError(f"Questionnaire prompt '{prompt_key}' not found in MongoDB.")

    @staticmethod
    def _build_version(document: dict) -> str:
        modified_at = document.get("modifiedAt") or document.get("createdAt")
        if isinstance(modified_at, datetime):
            return f"questionnaire_modifiedAt:{modified_at.isoformat()}"
        if modified_at:
            return f"questionnaire_modifiedAt:{modified_at}"
        return "questionnaire_modifiedAt:unknown"


class PersonaSkillProvider:
    """Loads persona instructions by runtime key or output profile."""

    def __init__(
        self,
        mongo_uri: str,
        db_name: str,
        *,
        collection_name: str = "PersonaSkills",
        server_selection_timeout_ms: int = 500,
    ):
        from pymongo import MongoClient

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
        try:
            document = None
            if persona_skill_key:
                document = self._collection.find_one({"personaSkillKey": persona_skill_key})
            if document is None and output_profile:
                document = self._collection.find_one({"outputProfile": output_profile})
        except Exception as exc:
            raise RuntimeError("Persona skill lookup unavailable.") from exc

        if not document:
            missing = persona_skill_key or output_profile or "default"
            raise PromptNotFoundError(f"Persona skill '{missing}' not found in MongoDB.")

        instructions = str(document.get("instructions") or "").strip()
        if not instructions:
            key = document.get("personaSkillKey") or persona_skill_key or output_profile or "unknown"
            raise PromptNotFoundError(f"Persona skill '{key}' is empty in MongoDB.")

        resolved_key = str(document.get("personaSkillKey") or persona_skill_key or "").strip() or None
        resolved_output_profile = (
            str(document.get("outputProfile") or output_profile or "").strip() or None
        )
        return instructions, self._build_version(document), resolved_key or "", resolved_output_profile

    @staticmethod
    def _build_version(document: dict) -> str:
        modified_at = document.get("modifiedAt") or document.get("createdAt")
        if isinstance(modified_at, datetime):
            return f"persona_modifiedAt:{modified_at.isoformat()}"
        if modified_at:
            return f"persona_modifiedAt:{modified_at}"
        return "persona_modifiedAt:unknown"


class GoogleDrivePromptProvider(PromptRegistry):
    def __init__(
        self,
        folder_id: Optional[str],
        prompt_doc_map: Dict[str, str],
        credentials_path: Optional[str],
        cache_ttl_seconds: int = 60,
    ):
        self._folder_id = folder_id
        self._prompt_doc_map = prompt_doc_map
        self._cache_ttl_seconds = cache_ttl_seconds
        self._cache: Dict[str, _CachedPrompt] = {}

        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        credentials = None
        if credentials_path:
            if not os.path.isabs(credentials_path):
                module_dir = os.path.dirname(os.path.abspath(__file__))
                credentials_path = os.path.normpath(
                    os.path.join(module_dir, credentials_path)
                )
            credentials = service_account.Credentials.from_service_account_file(
                credentials_path,
                scopes=["https://www.googleapis.com/auth/drive.readonly"],
            )

        self._drive = build("drive", "v3", credentials=credentials)

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        cached = self._cache.get(prompt_key)
        now = time.monotonic()
        if cached and cached.expires_at > now:
            return cached.prompt_text, cached.version

        file_id = self._prompt_doc_map.get(prompt_key)
        if not file_id and self._folder_id:
            file_id = self._find_doc_id_by_name(prompt_key)

        if not file_id:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' not found in Google Drive.")

        meta = self._drive.files().get(
            fileId=file_id,
            fields="id, name, modifiedTime",
        ).execute()
        modified_time = meta.get("modifiedTime")
        version = (
            f"gdrive_modifiedTime:{modified_time}"
            if modified_time
            else "gdrive_modifiedTime:unknown"
        )
        content_bytes = self._drive.files().export_media(
            fileId=file_id,
            mimeType="text/plain",
        ).execute()
        prompt_text = content_bytes.decode("utf-8").strip()
        if not prompt_text:
            raise PromptNotFoundError(f"Prompt '{prompt_key}' is empty in Google Drive.")

        self._cache[prompt_key] = _CachedPrompt(
            prompt_text=prompt_text,
            version=version,
            expires_at=now + self._cache_ttl_seconds,
        )
        return prompt_text, version

    def _find_doc_id_by_name(self, prompt_key: str) -> Optional[str]:
        query = (
            "mimeType='application/vnd.google-apps.document' "
            f"and '{self._folder_id}' in parents "
            "and trashed = false"
        )
        response = self._drive.files().list(
            q=query,
            fields="files(id, name)",
            pageSize=1000,
        ).execute()
        for item in response.get("files", []):
            if item.get("name") == prompt_key:
                return item.get("id")
        return None


class ClinicalPromptRegistry(PromptRegistry):
    """Resolves survey prompts from Mongo components with legacy fallback."""

    def __init__(
        self,
        *,
        fallback_provider: PromptRegistry,
        questionnaire_provider: QuestionnairePromptProvider | None = None,
        persona_provider: PersonaSkillProvider | None = None,
    ):
        self._fallback_provider = fallback_provider
        self._questionnaire_provider = questionnaire_provider
        self._persona_provider = persona_provider

    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        return self._fallback_provider.get_prompt(prompt_key)

    def resolve_process_prompt(
        self,
        *,
        input_type: str,
        prompt_key: str,
        persona_skill_key: str | None = None,
        output_profile: str | None = None,
    ) -> ResolvedPrompt:
        if input_type not in SURVEY_INPUT_TYPES:
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
            )

        if self._questionnaire_provider is None or self._persona_provider is None:
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
            )

        try:
            questionnaire_text, questionnaire_version = self._questionnaire_provider.get_prompt(
                prompt_key
            )
        except (PromptNotFoundError, RuntimeError):
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
            )

        resolved_output_profile = output_profile or DEFAULT_OUTPUT_PROFILE_BY_INPUT_TYPE.get(input_type)
        resolved_persona_skill_key = persona_skill_key
        if not resolved_persona_skill_key and resolved_output_profile:
            resolved_persona_skill_key = DEFAULT_PERSONA_KEY_BY_OUTPUT_PROFILE.get(
                resolved_output_profile,
                resolved_output_profile,
            )

        if not resolved_persona_skill_key and not resolved_output_profile:
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
            )

        try:
            persona_text, persona_version, resolved_persona_skill_key, resolved_output_profile = (
                self._persona_provider.get_persona(
                    persona_skill_key=resolved_persona_skill_key,
                    output_profile=resolved_output_profile,
                )
            )
        except PromptNotFoundError:
            if persona_skill_key or output_profile:
                raise
            return super().resolve_process_prompt(
                input_type=input_type,
                prompt_key=prompt_key,
                persona_skill_key=persona_skill_key,
                output_profile=output_profile,
            )

        prompt_text = _compose_prompt(questionnaire_text, persona_text)
        prompt_version = f"{questionnaire_version};{persona_version}"
        return ResolvedPrompt(
            prompt_text=prompt_text,
            prompt_version=prompt_version,
            interpretation_prompt=questionnaire_text,
            persona_prompt=persona_text,
            questionnaire_prompt_version=questionnaire_version,
            persona_skill_version=persona_version,
            persona_skill_key=resolved_persona_skill_key,
            output_profile=resolved_output_profile,
        )


def _compose_prompt(questionnaire_prompt_text: str, persona_skill_text: str) -> str:
    return (
        "QUESTIONNAIRE CLINICAL LOGIC:\n"
        f"{questionnaire_prompt_text.strip()}\n\n"
        "PERSONA STYLE AND RESTRICTIONS:\n"
        f"{persona_skill_text.strip()}"
    )


def _load_prompt_doc_map() -> Dict[str, str]:
    raw = os.getenv("PROMPT_DOC_MAP_JSON", "")
    if not raw:
        return {}
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise RuntimeError("PROMPT_DOC_MAP_JSON is not valid JSON.") from exc
    if not isinstance(data, dict):
        raise RuntimeError("PROMPT_DOC_MAP_JSON must be a JSON object.")
    return {str(k): str(v) for k, v in data.items()}


def create_prompt_registry() -> PromptRegistry:
    provider = os.getenv("PROMPT_PROVIDER", "local")
    cache_ttl = int(os.getenv("PROMPT_CACHE_TTL_SECONDS", "60"))
    configured_providers: list[PromptRegistry] = []

    mongo_uri = os.getenv("PROMPT_MONGO_URI") or os.getenv("MONGO_URI")
    mongo_db_name = os.getenv("PROMPT_MONGO_DB_NAME") or os.getenv("MONGO_DB_NAME")
    questionnaire_provider: QuestionnairePromptProvider | None = None
    persona_provider: PersonaSkillProvider | None = None
    if mongo_uri and mongo_db_name:
        questionnaire_provider = QuestionnairePromptProvider(
            mongo_uri=mongo_uri,
            db_name=mongo_db_name,
        )
        persona_provider = PersonaSkillProvider(
            mongo_uri=mongo_uri,
            db_name=mongo_db_name,
        )
        configured_providers.append(
            MongoPromptProvider(
                mongo_uri=mongo_uri,
                db_name=mongo_db_name,
                cache_ttl_seconds=cache_ttl,
            )
        )

    if provider == "google_drive":
        try:
            folder_id = os.getenv("GOOGLE_DRIVE_FOLDER_ID")
            prompt_doc_map = _load_prompt_doc_map()
            credentials_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
            configured_providers.append(
                GoogleDrivePromptProvider(
                    folder_id=folder_id,
                    prompt_doc_map=prompt_doc_map,
                    credentials_path=credentials_path,
                    cache_ttl_seconds=cache_ttl,
                )
            )
        except (
            ModuleNotFoundError,
            FileNotFoundError,
            OSError,
            RuntimeError,
            ValueError,
        ) as exc:
            logger.warning(
                "Google Drive prompt provider unavailable, falling back to configured non-Google providers: %s",
                exc,
            )
            configured_providers.append(LocalPromptProvider())
    else:
        configured_providers.append(LocalPromptProvider())

    fallback_provider = (
        configured_providers[0]
        if len(configured_providers) == 1
        else CompositePromptProvider(configured_providers)
    )
    return ClinicalPromptRegistry(
        fallback_provider=fallback_provider,
        questionnaire_provider=questionnaire_provider,
        persona_provider=persona_provider,
    )
