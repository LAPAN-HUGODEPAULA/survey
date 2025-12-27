"""Shared LangGraph state schema used by the clinical writer agents.

This module defines the narrow contract for information exchanged between LangGraph
nodes. Keeping this state explicit avoids ad-hoc dictionaries and makes the data flow
across validation, classification, and processing agents traceable and testable. Each
agent reads from and writes to this typed mapping to signal progress (e.g., validation
status), intermediate results (e.g., appropriateness scores), and final outputs
(classification label, generated medical record, or error message).
"""

# Package imports
from typing import TypedDict, Optional

# Project imports
from ..monitoring.base_monitors import ProcessingMonitor

# Define Graph State
class AgentState(TypedDict, total=False):
    """State passed between LangGraph nodes during request processing."""
    input_content: str
    classification: str
    medical_record: str
    error_message: str
    judge_score: float
    observer: Optional['ProcessingMonitor']  # Observer for monitoring and logging
