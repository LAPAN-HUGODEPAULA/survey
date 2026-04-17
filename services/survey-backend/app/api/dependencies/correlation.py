"""Dependency to access correlation ID from request state."""

from typing import Annotated

from fastapi import Depends, Request

CorrelationID = Annotated[str, Depends(lambda request: request.state.correlation_id)]