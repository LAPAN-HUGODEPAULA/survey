# Package imports
from datetime import datetime
from typing import Optional, Dict, Any
import logging

# Project imports
from .base_monitors import ProcessingMonitor


class LoggingMonitor(ProcessingMonitor):
    """
    Observer that logs all processing events.

    This observer writes structured log messages for all events in the
    processing pipeline, making it easy to trace execution and debug issues.
    """

    def __init__(
        self, logger: Optional[logging.Logger] = None, log_level: int = logging.INFO
    ):
        """
        Initialize the logging observer.

        Args:
            logger: Logger instance to use (creates default if None)
            log_level: Minimum log level for events
        """
        self.logger = logger or self._create_default_logger()
        self.log_level = log_level

    def _create_default_logger(self) -> logging.Logger:
        """Create a default logger with console handler."""
        logger = logging.getLogger("ClinicalWriterObserver")
        logger.setLevel(logging.DEBUG)

        if not logger.handlers:
            handler = logging.StreamHandler()
            handler.setLevel(logging.DEBUG)
            formatter = logging.Formatter(
                "%(asctime)s - %(name)s - %(levelname)s - %(message)s - metadata=%(metadata)s",
                datefmt="%Y-%m-%d %H:%M:%S",
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)

        return logger

    def on_classification(
        self,
        classification: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Log classification event."""
        self.logger.log(
            self.log_level,
            f"Input classified as: {classification}",
            extra={
                "event": "classification",
                "classification": classification,
                "timestamp": timestamp.isoformat(),
                "metadata": metadata or {},
            },
        )

    def on_processing_start(
        self,
        agent_type: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Log processing start event."""
        self.logger.log(
            self.log_level,
            f"Agent '{agent_type}' started processing",
            extra={
                "event": "processing_start",
                "agent_type": agent_type,
                "timestamp": timestamp.isoformat(),
                "metadata": metadata or {},
            },
        )

    def on_processing_complete(
        self,
        agent_type: str,
        duration: float,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Log processing completion event."""
        self.logger.log(
            self.log_level,
            f"Agent '{agent_type}' completed processing in {duration:.3f}s",
            extra={
                "event": "processing_complete",
                "agent_type": agent_type,
                "duration": duration,
                "timestamp": timestamp.isoformat(),
                "metadata": metadata or {},
            },
        )

    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime):
        """Log error event."""
        self.logger.error(
            f"Error in {context.get('location', 'unknown')}: {str(error)}",
            extra={
                "event": "error",
                "error_type": type(error).__name__,
                "error_message": str(error),
                "context": context,
                "metadata": context or {},
                "timestamp": timestamp.isoformat(),
            },
            exc_info=True,
        )

    def on_validation_start(
        self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None
    ):
        """Log validation start event."""
        self.logger.log(
            self.log_level,
            "Input validation started",
            extra={
                "event": "validation_start",
                "timestamp": timestamp.isoformat(),
                "metadata": metadata or {},
            },
        )

    def on_validation_complete(
        self,
        is_valid: bool,
        duration: float,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Log validation completion event."""
        status = "passed" if is_valid else "failed"
        self.logger.log(
            self.log_level,
            f"Input validation {status} in {duration:.3f}s",
            extra={
                "event": "validation_complete",
                "is_valid": is_valid,
                "duration": duration,
                "timestamp": timestamp.isoformat(),
                "metadata": metadata or {},
            },
        )

    def on_event(
        self,
        event_name: str,
        timestamp: datetime,
        metadata: Optional[Dict[str, Any]] = None,
    ):
        """Log a generic event."""
        self.logger.log(
            self.log_level,
            f"Event: {event_name}",
            extra={
                "event": "generic_event",
                "event_name": event_name,
                "timestamp": timestamp.isoformat(),
                "metadata": metadata or {},
            },
        )
