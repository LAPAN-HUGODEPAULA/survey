"""Monitor implementation that maps LangGraph node events into progress snapshots."""

from __future__ import annotations

from datetime import datetime
from typing import Optional, Dict, Any

from .base_monitors import ProcessingMonitor
from .progress_tracker import ProgressTracker


def _looks_retryable(error: Exception) -> bool:
    text = str(error).lower()
    return any(token in text for token in ("timeout", "tempor", "overload", "503", "rate limit"))


class ProgressMonitor(ProcessingMonitor):
    """Updates request progress in an in-memory tracker."""

    def __init__(self, tracker: ProgressTracker):
        self._tracker = tracker

    def on_classification(
        self,
        classification: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ) -> None:
        del classification, timestamp, metadata
        if request_id:
            self._tracker.start(request_id)

    def on_processing_start(
        self,
        agent_type: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ) -> None:
        del timestamp, metadata
        if request_id:
            self._tracker.update_stage(request_id, agent_type)

    def on_processing_complete(
        self,
        agent_type: str,
        duration: float,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ) -> None:
        del agent_type, duration, timestamp, metadata, request_id

    def on_error(
        self,
        error: Exception,
        context: Dict[str, Any],
        timestamp: datetime,
        request_id: Optional[str] = None,
    ) -> None:
        del context, timestamp
        if request_id:
            self._tracker.fail(request_id, str(error), retryable=_looks_retryable(error))

    def on_validation_start(
        self,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ) -> None:
        del timestamp, metadata
        if request_id:
            self._tracker.start(request_id)

    def on_validation_complete(
        self,
        is_valid: bool,
        duration: float,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ) -> None:
        del duration, timestamp, metadata
        if request_id and not is_valid:
            self._tracker.fail(
                request_id,
                "Não foi possível validar os dados recebidos para gerar o laudo.",
                retryable=False,
            )

    def on_event(
        self,
        event_name: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ) -> None:
        del event_name, timestamp, metadata, request_id

