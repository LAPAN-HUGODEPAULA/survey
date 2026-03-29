"""Shared LangGraph state schema used by the clinical writer agents.

This module defines the narrow contract for information exchanged between LangGraph
nodes. Keeping this state explicit avoids ad-hoc dictionaries and makes the data flow
across validation, classification, and processing agents traceable and testable. Each
agent reads from and writes to this typed mapping to signal progress (e.g., validation
status), intermediate results (e.g., appropriateness scores), and final outputs
(classification label, generated medical record, or error message).
"""

# Package imports
from typing import Any, Literal, Optional, TypedDict

# Project imports
from ..monitoring.base_monitors import ProcessingMonitor

InputType = Literal["consult", "survey7", "full_intake", "invalid"]
ValidationStatus = Literal[
    "validated",
    "flagged",
    "context_loaded",
    "prompt_not_found",
    "context_error",
    "analyzed",
    "written",
]
ClinicalFacts = dict[str, Any]
ReportPayload = dict[str, Any]


class AgentState(TypedDict, total=False):
    """State passed between LangGraph nodes during request processing."""

    input_content: str
    input_type: InputType
    validation_status: ValidationStatus

    # Request and routing context
    request_id: Optional[str]
    prompt_key: str
    persona_skill_key: str
    output_profile: str

    # Hydrated prompt context
    prompt_text: str
    prompt_version: str
    interpretation_prompt: str
    persona_prompt: str
    questionnaire_prompt_version: str
    persona_skill_version: str

    # Intermediate and final outputs
    clinical_facts: ClinicalFacts
    draft_narrative: str
    report: ReportPayload
    medical_record: str
    model_version: str

    # Error and runtime metadata
    error_kind: str
    error_message: str
    prompt_registry: Any
    observer: Optional[ProcessingMonitor]
