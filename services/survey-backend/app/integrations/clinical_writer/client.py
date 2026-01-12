"""Service helpers for interacting with the local LangGraph agent."""

import json
from typing import Any, Dict

import httpx

from app.config.logging_config import logger
import os

from app.config.settings import settings

LANGGRAPH_URL = os.getenv("LANGGRAPH_URL")
DEFAULT_LANGGRAPH_URL = "http://localhost:9566/process"
LANGGRAPH_TOKEN = os.getenv("LANGGRAPH_API_TOKEN")


def _normalize_agent_response(payload: Dict[str, Any]) -> Dict[str, Any]:
    if "medical_record" in payload and "medicalRecord" not in payload:
        payload["medicalRecord"] = payload["medical_record"]
    if "error_message" in payload and "errorMessage" not in payload:
        payload["errorMessage"] = payload["error_message"]
    return payload


async def send_to_langgraph_agent(payload: Any) -> Dict[str, Any]:
    """
    Send a survey response payload to the LangGraph agent and return its result.

    The agent expects a JSON body with a single "content" field containing the
    conversation text or JSON string to process.
    """
    if isinstance(payload, str):
        content = payload.strip()
    else:
        try:
            content = json.dumps(payload, default=str)
        except (TypeError, ValueError) as exc:
            logger.warning("Failed to serialize payload for LangGraph agent: %s", exc)
            content = str(payload)

    headers: Dict[str, str] = {}
    token = settings.clinical_writer_token or LANGGRAPH_TOKEN
    if token:
        headers["Authorization"] = f"Bearer {token}"

    try:
        endpoint = settings.clinical_writer_url or LANGGRAPH_URL or DEFAULT_LANGGRAPH_URL
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(
                endpoint,
                json={"content": content},
                headers=headers,
            )
            response.raise_for_status()
            agent_result: Dict[str, Any] = _normalize_agent_response(response.json())
            logger.info("LangGraph agent responded successfully.")
            return agent_result
    except httpx.HTTPStatusError as exc:
        text = exc.response.text if exc.response is not None else str(exc)
        logger.error("LangGraph agent returned an error: %s", text)
        return {"error_message": f"Agent error: {text}"}
    except httpx.RequestError as exc:
        logger.error("Failed to reach LangGraph agent: %s", exc)
        return {"error_message": "Unable to reach AI agent"}
    except Exception as exc:  # pragma: no cover - guard for unexpected failures
        logger.error("Unexpected error when calling LangGraph agent: %s", exc)
        return {"error_message": "Unexpected error contacting AI agent"}
