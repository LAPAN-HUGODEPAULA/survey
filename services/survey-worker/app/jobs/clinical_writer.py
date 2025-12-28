"""Background job that enriches survey responses using the Clinical Writer agent."""

from __future__ import annotations

import asyncio
from datetime import datetime
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
        return self._get_db()["survey_results"]

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
        query = {
            "$or": [
                {"agentResponse": {"$exists": False}},
                {"agentResponse": None},
                {"agentResponseStatus": {"$in": [None, "pending", "failed"]}},
            ]
        }
        cursor = col.find(query).limit(limit)
        return list(cursor)

    async def _process_document(self, doc: Dict[str, Any]) -> None:
        doc_id = str(doc.get("_id"))
        logger.info("Submitting survey response %s to Clinical Writer.", doc_id)
        col = self._get_collection()

        col.update_one(
            {"_id": doc.get("_id")},
            {
                "$set": {
                    "agentResponseStatus": "processing",
                    "agentResponseUpdatedAt": datetime.utcnow(),
                }
            },
        )

        payload = self._serialize_payload(doc)
        try:
            agent_response = await self._call_clinical_writer(payload)
            col.update_one(
                {"_id": doc.get("_id")},
                {
                    "$set": {
                        "agentResponse": agent_response,
                        "agentResponseStatus": "succeeded",
                        "agentResponseUpdatedAt": datetime.utcnow(),
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
                        "agentResponse": {"error_message": str(exc)},
                        "agentResponseStatus": "failed",
                        "agentResponseUpdatedAt": datetime.utcnow(),
                    }
                },
            )

    def _serialize_payload(self, doc: Dict[str, Any]) -> Dict[str, Any]:
        """Prepare the survey response document for the Clinical Writer agent."""
        payload = dict(doc)
        if "_id" in payload and isinstance(payload["_id"], ObjectId):
            payload["_id"] = str(payload["_id"])
        return payload

    async def _call_clinical_writer(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """Invoke the Clinical Writer agent and normalize its response."""
        client = await self._get_http_client()
        response = await client.post(settings.clinical_writer_url, json=payload)
        response.raise_for_status()
        data = response.json()
        return self._normalize_agent_response(data)

    def _normalize_agent_response(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Ensure the stored agent response matches our expected shape."""
        return {
            "classification": data.get("classification"),
            "medicalRecord": data.get("medicalRecord"),
            "error_message": data.get("error_message") or data.get("errorMessage"),
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

