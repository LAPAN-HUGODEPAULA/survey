import json
import os
import time
from dataclasses import dataclass
from typing import Dict, Optional, Tuple

from google.oauth2 import service_account
from googleapiclient.discovery import build

from .prompts import ConversationPrompts, JsonPrompts


class PromptNotFoundError(RuntimeError):
    pass


class PromptRegistry:
    def get_prompt(self, prompt_key: str) -> Tuple[str, str]:
        raise NotImplementedError


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

        credentials = None
        if credentials_path:
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
            fields="id, name, modifiedTime, etag",
        ).execute()
        version = meta.get("etag") or meta.get("modifiedTime") or "unknown"
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
    if provider == "google_drive":
        folder_id = os.getenv("GOOGLE_DRIVE_FOLDER_ID")
        prompt_doc_map = _load_prompt_doc_map()
        credentials_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        cache_ttl = int(os.getenv("PROMPT_CACHE_TTL_SECONDS", "60"))
        return GoogleDrivePromptProvider(
            folder_id=folder_id,
            prompt_doc_map=prompt_doc_map,
            credentials_path=credentials_path,
            cache_ttl_seconds=cache_ttl,
        )
    return LocalPromptProvider()
