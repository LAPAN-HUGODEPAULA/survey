"""Background job that enriches survey responses using the Clinical Writer agent."""

from __future__ import annotations

import asyncio
import json
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional

import httpx
from bson import ObjectId
from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.database import Database

from app.config.settings import settings
from app.logging_config import logger


class ClinicalWriterJob:
    """Polls MongoDB for unprocessed survey responses and enriches them via the Clinical Writer agent."""

    COLLECTION_NAME = "survey_responses"

    def __init__(self, client: MongoClient | None = None):
        self._client = client
        self._http_client: httpx.AsyncClient | None = None

    def _get_client(self) -> MongoClient:
        if self._client is None:
            self._client = MongoClient(settings.mongo_uri)
        return self._client

    def _get_db(self) -> Database:
        return self._get_client()[settings.mongo_db_name]

    def _get_collection(self) -> Collection:
        return self._get_db()[self.COLLECTION_NAME]

    async def _get_http_client(self) -> httpx.AsyncClient:
        if self._http_client is None:
            self._http_client = httpx.AsyncClient(
                timeout=settings.http_timeout_seconds,
                headers=self._build_headers(),
            )
        return self._http_client

    def _build_headers(self) -> Dict[str, str]:
        headers: Dict[str, str] = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        if settings.clinical_writer_token:
            headers["Authorization"] = f"Bearer {settings.clinical_writer_token}"
        return headers

    async def run_once(self) -> None:
        """Process a batch of pending survey responses."""
        pending = self._get_pending_documents(limit=settings.batch_size)
        if not pending:
            logger.debug("No pending survey responses found.")
            return

        logger.info("Processing %d pending survey response(s).", len(pending))
        for doc in pending:
            await self._process_document(doc)

    def _get_pending_documents(self, *, limit: int) -> List[Dict[str, Any]]:
        """Fetch unprocessed or failed survey responses."""
        col = self._get_collection()
        query = self._build_pending_query()
        cursor = col.find(query).limit(limit)
        return list(cursor)

    def _build_pending_query(self) -> Dict[str, Any]:
        """Select unprocessed, failed, or stale in-flight survey responses."""
        stale_before = datetime.now(timezone.utc) - timedelta(
            seconds=settings.processing_stale_after_seconds
        )
        return {
            "$or": [
                {"agentResponse": {"$exists": False}},
                {"agentResponse": None},
                {"agentResponseStatus": {"$in": [None, "pending", "failed"]}},
                {
                    "agentResponseStatus": "processing",
                    "agentResponseUpdatedAt": {"$lt": stale_before},
                },
            ]
        }

    async def _process_document(self, doc: Dict[str, Any]) -> None:
        doc_id = str(doc.get("_id"))
        logger.info("Submitting survey response %s to Clinical Writer.", doc_id)
        col = self._get_collection()

        col.update_one(
            {"_id": doc.get("_id")},
            {
                "$set": {
                    "agentResponseStatus": "processing",
                    "agentResponseUpdatedAt": datetime.now(timezone.utc),
                }
            },
        )

        payload = self._serialize_document(doc)
        try:
            agent_response = await self._call_clinical_writer(payload)
            col.update_one(
                {"_id": doc.get("_id")},
                {
                    "$set": {
                        "agentResponse": agent_response,
                        "agentResponseStatus": "succeeded",
                        "agentResponseUpdatedAt": datetime.now(timezone.utc),
                    }
                },
            )
            logger.info("Updated survey response %s with agent output.", doc_id)
        except Exception as exc:  # pragma: no cover - safeguard
            logger.error("Failed to process survey response %s: %s", doc_id, exc)
            col.update_one(
                {"_id": doc.get("_id")},
                {
                    "$set": {
                        "agentResponse": {"errorMessage": str(exc)},
                        "agentResponseStatus": "failed",
                        "agentResponseUpdatedAt": datetime.now(timezone.utc),
                    }
                },
            )

    def _serialize_document(self, value: Any) -> Any:
        """Convert Mongo-specific values into JSON-safe primitives."""
        if isinstance(value, ObjectId):
            return str(value)
        if isinstance(value, datetime):
            return value.isoformat()
        if isinstance(value, dict):
            return {
                key: self._serialize_document(item)
                for key, item in value.items()
            }
        if isinstance(value, list):
            return [self._serialize_document(item) for item in value]
        return value

    def _build_request_payload(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """Build the Clinical Writer request body expected by `/process`."""
        patient = payload.get("patient") or {}
        patient_ref = None
        if isinstance(patient, dict):
            patient_ref = patient.get("email") or patient.get("name")

        output_profile = payload.get("outputProfile") or "patient_condition_overview"
        persona_skill_key = payload.get("personaSkillKey") or output_profile

        return {
            "input_type": "survey7",
            "content": json.dumps(self._serialize_document(payload), ensure_ascii=False),
            "locale": "pt-BR",
            "prompt_key": payload.get("promptKey") or "survey7",
            "persona_skill_key": persona_skill_key,
            "output_profile": output_profile,
            "output_format": "report_json",
            "metadata": {
                "source_app": "survey-worker",
                "request_id": str(uuid.uuid4()),
                "patient_ref": patient_ref,
            },
        }

    async def _call_clinical_writer(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """Invoke the Clinical Writer agent and normalize its response."""
        client = await self._get_http_client()
        response = await client.post(
            settings.clinical_writer_url,
            json=self._build_request_payload(payload),
        )
        response.raise_for_status()
        data = response.json()
        return self._normalize_agent_response(data)

    def _report_to_text(self, report: Dict[str, Any]) -> str | None:
        """Flatten the report JSON into readable text for legacy consumers."""
        sections = report.get("sections") or []
        lines: list[str] = []
        for section in sections:
            title = section.get("title")
            if title:
                lines.append(str(title))
            for block in section.get("blocks") or []:
                block_type = block.get("type")
                if block_type == "paragraph":
                    spans = block.get("spans") or []
                    lines.append("".join(span.get("text", "") for span in spans))
                elif block_type == "bullet_list":
                    for item in block.get("items") or []:
                        spans = item.get("spans") or []
                        lines.append("- " + "".join(span.get("text", "") for span in spans))
                elif block_type == "key_value":
                    for item in block.get("items") or []:
                        key = item.get("key", "")
                        spans = item.get("value") or []
                        value = "".join(span.get("text", "") for span in spans)
                        lines.append(f"{key}: {value}")
        flattened = "\n".join(line for line in lines if line)
        return flattened or None

    def _normalize_agent_response(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Ensure the stored agent response matches our expected shape."""
        report = data.get("report")
        warnings = data.get("warnings")
        if not isinstance(warnings, list):
            warnings = []
        return {
            "ok": data.get("ok"),
            "input_type": data.get("input_type"),
            "prompt_version": data.get("prompt_version"),
            "questionnaire_prompt_version": data.get("questionnaire_prompt_version"),
            "persona_skill_version": data.get("persona_skill_version"),
            "model_version": data.get("model_version"),
            "report": report,
            "warnings": warnings,
            "classification": data.get("classification"),
            "medicalRecord": data.get("medicalRecord") or self._report_to_text(report or {}),
            "errorMessage": data.get("errorMessage") or data.get("error_message"),
        }

    async def close(self) -> None:
        """Clean up open resources."""
        if self._http_client is not None:
            await self._http_client.aclose()
        if self._client is not None:
            self._client.close()


async def run_forever(job: ClinicalWriterJob) -> None:
    """Run the Clinical Writer job in an infinite loop with backoff."""
    try:
        while True:
            await job.run_once()
            await asyncio.sleep(settings.poll_interval_seconds)
    finally:
        await job.close()
