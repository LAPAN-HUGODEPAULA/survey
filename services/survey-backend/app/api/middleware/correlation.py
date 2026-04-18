"""Correlation ID middleware for tracing requests across builder operations."""

import uuid
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from app.config.logging_config import logger


class CorrelationMiddleware(BaseHTTPMiddleware):
    """Middleware to generate and propagate correlation IDs for request tracing."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Extract correlation ID from header or generate new one
        correlation_id = (
            request.headers.get("X-Request-ID")
            or f"corr_{uuid.uuid4().hex[:16]}"
        )

        # Add to request state for easy access in route handlers
        request.state.correlation_id = correlation_id

        # Add to response headers for client-side tracing
        response = await call_next(request)
        response.headers["X-Correlation-ID"] = correlation_id

        # Log for debugging
        logger.debug(
            "Request %s %s with correlation ID: %s",
            request.method,
            request.url.path,
            correlation_id
        )

        return response