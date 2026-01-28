# Package imports
from datetime import datetime
from typing import Optional, Dict, Any
import logging
from starlette_context import context

# Project imports
from .base_monitors import ProcessingMonitor


class LoggingMonitor(ProcessingMonitor):
    """
    Observer that logs all processing events in a structured way.
    It automatically includes the `request_id` from the context.
    """

    def __init__(
        self, logger: Optional[logging.Logger] = None, log_level: int = logging.INFO
    ):
        self.logger = logger or self._create_default_logger()
        self.log_level = log_level

    def _create_default_logger(self) -> logging.Logger:
        """Create a default logger with a console handler and structured format."""
        logger = logging.getLogger("ClinicalWriterObserver")
        logger.setLevel(logging.DEBUG)

        if not logger.handlers:
            handler = logging.StreamHandler()
            handler.setLevel(logging.DEBUG)
            formatter = logging.Formatter(
                "%(asctime)s - [%(levelname)s] - [%(request_id)s] - %(message)s - metadata=%(metadata)s",
                datefmt="%Y-%m-%d %H:%M:%S",
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)

        return logger

    def _get_extra(self, base_extra: Dict[str, Any], request_id: Optional[str] = None) -> Dict[str, Any]:
        """Merges base extra data with the request ID from context."""
        extra = {"metadata": base_extra.get("metadata", {})}
        # Prioritize explicit request_id, then context, then from metadata
        req_id = request_id or context.get("request_id") or extra["metadata"].get("request_id")
        extra["request_id"] = req_id or "not-set"
        return extra

    def on_classification(
        self,
        classification: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ):
        extra = self._get_extra({
            "event": "classification",
            "classification": classification,
            "timestamp": timestamp.isoformat(),
            "metadata": metadata or {},
        }, request_id)
        self.logger.log(
            self.log_level,
            f"Input classified as: {classification}",
            extra=extra,
        )

    def on_processing_start(
        self,
        agent_type: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ):
        extra = self._get_extra({
            "event": "processing_start",
            "agent_type": agent_type,
            "timestamp": timestamp.isoformat(),
            "metadata": metadata or {},
        }, request_id)
        self.logger.log(
            self.log_level,
            f"Agent '{agent_type}' started processing",
            extra=extra,
        )

    def on_processing_complete(
        self,
        agent_type: str,
        duration: float,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ):
        extra = self._get_extra({
            "event": "processing_complete",
            "agent_type": agent_type,
            "duration": duration,
            "timestamp": timestamp.isoformat(),
            "metadata": metadata or {},
        }, request_id)
        self.logger.log(
            self.log_level,
            f"Agent '{agent_type}' completed in {duration:.3f}s",
            extra=extra,
        )

    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime, request_id: Optional[str] = None):
        extra = self._get_extra({
            "event": "error",
            "error_type": type(error).__name__,
            "error_message": str(error),
            "context": context,
            "metadata": context or {},
            "timestamp": timestamp.isoformat(),
        }, request_id)
        self.logger.error(
            f"Error in {context.get('location', 'unknown')}: {str(error)}",
            extra=extra,
            exc_info=True,
        )

    def on_validation_start(
        self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None,
    ):
        extra = self._get_extra({
            "event": "validation_start",
            "timestamp": timestamp.isoformat(),
            "metadata": metadata or {},
        }, request_id)
        self.logger.log(
            self.log_level,
            "Input validation started",
            extra=extra,
        )

    def on_validation_complete(
        self,
        is_valid: bool,
        duration: float,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ):
        status = "passed" if is_valid else "failed"
        extra = self._get_extra({
            "event": "validation_complete",
            "is_valid": is_valid,
            "duration": duration,
            "timestamp": timestamp.isoformat(),
            "metadata": metadata or {},
        }, request_id)
        self.logger.log(
            self.log_level,
            f"Input validation {status} in {duration:.3f}s",
            extra=extra,
        )

    def on_event(
        self,
        event_name: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        request_id: Optional[str] = None,
    ):
        extra = self._get_extra({
            "event": "generic_event",
            "event_name": event_name,
            "timestamp": timestamp.isoformat(),
            "metadata": metadata or {},
        }, request_id)
        self.logger.log(
            self.log_level,
            f"Event: {event_name}",
            extra=extra,
        )
