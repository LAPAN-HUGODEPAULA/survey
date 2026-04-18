"""Correlation ID dependency for request-scoped audit tracing."""

from typing import Annotated

from fastapi import Depends, Request


def _get_request_correlation_id(request: Request) -> str:
    """Return the correlation ID populated by middleware for the current request."""
    return getattr(request.state, "correlation_id", "")


CorrelationID = Annotated[str, Depends(_get_request_correlation_id)]
