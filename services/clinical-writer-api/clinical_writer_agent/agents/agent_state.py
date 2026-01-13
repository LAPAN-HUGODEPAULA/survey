"""Shared LangGraph state schema used by the clinical writer agents.

This module defines the narrow contract for information exchanged between LangGraph
nodes. Keeping this state explicit avoids ad-hoc dictionaries and makes the data flow
across validation, classification, and processing agents traceable and testable. Each
agent reads from and writes to this typed mapping to signal progress (e.g., validation
status), intermediate results (e.g., appropriateness scores), and final outputs
(classification label, generated medical record, or error message).
"""

# Package imports
from typing import Optional, TypedDict

# Project imports
from ..monitoring.base_monitors import ProcessingMonitor

# Define Graph State
class AgentState(TypedDict, total=False):
    """State passed between LangGraph nodes during request processing."""
    input_content: str
    validation_status: str
    input_type: str
    request_id: Optional[str]
    prompt_key: str
    prompt_version: str
    prompt_text: str
    report: dict
    model_version: str
    medical_record: str
    error_message: str
    observer: Optional['ProcessingMonitor']  # Observer for monitoring and logging
