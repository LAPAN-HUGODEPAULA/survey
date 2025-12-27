# Package imports
import os
from fastapi import FastAPI, Depends, HTTPException, Security, status
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field, field_validator
from typing import Optional

# Project imports
from .agent_graph import (
    clinical_writer_graph,
    get_metrics_monitor,
    get_shared_observer,
)

app = FastAPI()

class Input(BaseModel):
    content: str = Field(..., description="Conversation text or JSON string")

    @field_validator("content")
    @classmethod
    def content_must_not_be_empty(cls, value: str) -> str:
        """Ensure content is not empty or whitespace."""
        if not value or not value.strip():
            raise ValueError("content must not be empty")
        return value.strip()

class AgentStateResponse(BaseModel):
    classification: Optional[str] = None
    medical_record: Optional[str] = None
    error_message: Optional[str] = None


api_key_header = APIKeyHeader(name="Authorization", auto_error=False)

def verify_token(api_key: Optional[str] = Security(api_key_header)) -> bool:
    """
    Basic bearer token guard. If API_TOKEN is set, enforce Authorization: Bearer <token>.
    If no token is configured, allow all requests (development-friendly).
    """
    expected_token = os.getenv("API_TOKEN")
    if not expected_token:
        return True

    if not api_key or api_key != f"Bearer {expected_token}":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API token",
        )
    return True

def get_graph():
    return clinical_writer_graph


def get_observer(graph = Depends(get_graph)):
    # Prefer the observer attached to the graph; fall back to the shared default.
    observer = getattr(graph, "observer", None)
    return observer or get_shared_observer()

@app.get("/")
async def root():
    return {"message": "Clinical Writer AI Multiagent System is running! Use the /process endpoint to process clinical data."}

@app.post("/process", response_model=AgentStateResponse, dependencies=[Depends(verify_token)])
async def process_content(input: Input, graph = Depends(get_graph), observer = Depends(get_observer)):
    state = {
        "input_content": input.content,
        "observer": observer
    }
    final_state = graph.invoke(state) # type: ignore

    # The observer field cannot be serialized, so we remove it.
    if 'observer' in final_state:
        del final_state['observer']

    return final_state

@app.get("/metrics")
async def get_metrics(observer = Depends(get_observer)):
    """Get collected metrics from the live metrics observer."""
    metrics_monitor = get_metrics_monitor(observer)
    return metrics_monitor.get_metrics_summary()
