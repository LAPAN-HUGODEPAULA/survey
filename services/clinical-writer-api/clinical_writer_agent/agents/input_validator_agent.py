"""Validation agent that sanitizes and screens inputs before routing.

This agent implements the early stages of the pipeline: structural validation,
sanitization to remove markup/scripts, and basic checks to avoid empty payloads.
By separating validation from routing, we keep concerns isolated and make it
clearer which component is responsible for rejecting invalid content.
"""

# Package imports
import re
from datetime import datetime
from typing import Any, Dict

# Project imports
from .agent_state import AgentState


class InputValidatorAgent:  # pylint: disable=too-few-public-methods
    """Performs structural validation and sanitization before routing."""

    def __init__(self):
        # Precompile sanitization regexes to avoid repeated work.
        self._script_pattern = re.compile(r"(?is)<script.*?>.*?</script>")
        self._tag_pattern = re.compile(r"(?is)<[^>]+>")
        self._whitespace_pattern = re.compile(r"\s+")

    def validate(self, state: AgentState) -> AgentState:
        """
        Sanitize and run basic checks.
        """
        raw_content = state.get("input_content", "")
        request_id = state.get("request_id")
        new_state = state.copy()
        observer = state.get("observer")

        start_time = datetime.now()
        if observer:
            observer.on_validation_start(start_time, {"raw_length": len(raw_content)}, request_id)

        sanitized = self._sanitize_content(raw_content)
        new_state["input_content"] = sanitized
        metadata: Dict[str, Any] = {
            "raw_length": len(raw_content),
            "sanitized_length": len(sanitized),
        }

        if not sanitized:
            new_state["validation_status"] = "flagged"
            new_state["error_message"] = "Input content is empty after sanitization."
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                metadata["reason"] = "empty_after_sanitization"
                observer.on_validation_complete(False, duration, end_time, metadata, request_id)
            return new_state

        new_state["validation_status"] = "validated"
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        if observer:
            observer.on_validation_complete(True, duration, end_time, metadata, request_id)
        return new_state

    def _sanitize_content(self, text: str) -> str:
        """Remove scripts, strip tags, and normalize whitespace."""
        without_scripts = self._script_pattern.sub(" ", text)
        without_tags = self._tag_pattern.sub(" ", without_scripts)
        collapsed = self._whitespace_pattern.sub(" ", without_tags)
        return collapsed.strip()
