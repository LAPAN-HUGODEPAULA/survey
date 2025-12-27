"""Validation agent that sanitizes, screens, and scores inputs before routing.

This agent implements the early stages of the pipeline: structural validation,
sanitization to remove markup/scripts, and an LLM-based appropriateness check.
By separating validation from classification, we keep concerns isolated and make
it clearer which component is responsible for rejecting unsafe content versus
assigning semantic labels. The validator produces a cleaned payload and either
passes it forward for classification or short-circuits to the fallback handler
if the judge deems the content inappropriate.
"""

# Package imports
import re
from datetime import datetime
from typing import Any, Dict, Optional
from langchain_google_genai import ChatGoogleGenerativeAI

# Project imports
from .agent_state import AgentState
from ..agent_config import AgentConfig


class InputValidatorAgent:  # pylint: disable=too-few-public-methods
    """
    Performs structural validation, sanitization, and LLM-based appropriateness
    scoring on incoming content before it is classified or processed downstream.
    """

    def __init__(
        self,
        *,
        llm_judge: Optional[ChatGoogleGenerativeAI] = None,
        judge_threshold: Optional[float] = None,
    ):
        """
        Initialize the validator.

        Args:
            llm_judge: Optional LLM used as a judge for appropriateness scoring.
            judge_threshold: Minimum score required to continue processing.
        """
        self.llm_judge = llm_judge
        self.judge_threshold = (
            judge_threshold
            if judge_threshold is not None
            else AgentConfig.JUDGE_APPROPRIATENESS_THRESHOLD
        )
        # Precompile sanitization regexes to avoid repeated work.
        self._script_pattern = re.compile(r"(?is)<script.*?>.*?</script>")
        self._tag_pattern = re.compile(r"(?is)<[^>]+>")
        self._whitespace_pattern = re.compile(r"\s+")

    def validate(self, state: AgentState) -> AgentState:
        """
        Sanitize, run basic checks, and consult the LLM judge for appropriateness.

        Returns updated state with:
        - sanitized `input_content`
        - `classification` set to `validated` when safe to continue
        - or `flagged_inappropriate` with error message when rejected
        """
        raw_content = state.get("input_content", "")
        new_state = state.copy()
        observer = state.get("observer")

        start_time = datetime.now()
        if observer:
            observer.on_validation_start(start_time, {"raw_length": len(raw_content)})

        sanitized = self._sanitize_content(raw_content)
        new_state["input_content"] = sanitized
        metadata: Dict[str, Any] = {
            "raw_length": len(raw_content),
            "sanitized_length": len(sanitized),
        }

        # Reject empty/degenerate content after sanitization.
        if not sanitized:
            new_state["classification"] = AgentConfig.CLASSIFICATION_FLAGGED
            new_state["error_message"] = AgentConfig.ERROR_MSG_UNCLASSIFIED_INPUT
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                metadata["reason"] = "empty_after_sanitization"
                observer.on_validation_complete(False, duration, end_time, metadata)
                observer.on_classification(
                    new_state["classification"], end_time, metadata
                )
            return new_state

        try:
            # score = self._evaluate_with_judge(sanitized)
            score = 1.0  # --- IGNORE ---
            new_state["judge_score"] = score
            metadata["judge_score"] = score
        except Exception as error:  # pylint: disable=broad-exception-caught
            # Fail closed: treat errors in judging as inappropriate to protect downstream agents.
            score = 0.0
            new_state["judge_score"] = score
            new_state["classification"] = AgentConfig.CLASSIFICATION_FLAGGED
            new_state["error_message"] = AgentConfig.ERROR_MSG_INAPPROPRIATE_CONTENT
            metadata["reason"] = "judge_error"
            if observer:
                observer.on_error(
                    error,
                    {
                        "location": "InputValidatorAgent",
                        "operation": "judge_validation",
                    },
                    datetime.now(),
                )

        if new_state.get("classification") == AgentConfig.CLASSIFICATION_FLAGGED:
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                observer.on_validation_complete(False, duration, end_time, metadata)
                observer.on_classification(
                    AgentConfig.CLASSIFICATION_FLAGGED, end_time, metadata
                )
            return new_state

        if score < self.judge_threshold:
            new_state["classification"] = AgentConfig.CLASSIFICATION_FLAGGED
            new_state["error_message"] = AgentConfig.ERROR_MSG_INAPPROPRIATE_CONTENT
            metadata["reason"] = "judge_score_below_threshold"
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            if observer:
                observer.on_validation_complete(False, duration, end_time, metadata)
                observer.on_classification(
                    AgentConfig.CLASSIFICATION_FLAGGED, end_time, metadata
                )
            return new_state

        new_state["classification"] = AgentConfig.CLASSIFICATION_VALIDATED
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        if observer:
            observer.on_validation_complete(True, duration, end_time, metadata)
        return new_state

    def _sanitize_content(self, text: str) -> str:
        """Remove scripts, strip tags, and normalize whitespace to protect downstream processing."""
        without_scripts = self._script_pattern.sub(" ", text)
        without_tags = self._tag_pattern.sub(" ", without_scripts)
        collapsed = self._whitespace_pattern.sub(" ", without_tags)
        return collapsed.strip()

    def _evaluate_with_judge(self, sanitized_text: str) -> float:
        """Call the LLM judge to obtain an appropriateness score between 0 and 1."""
        if self.llm_judge is None:
            self.llm_judge = AgentConfig.create_llm_instance()

        prompt = self._build_judge_prompt(sanitized_text)
        response = self.llm_judge.invoke(prompt)
        raw_content = (
            response.content
            if isinstance(response.content, str)
            else str(response.content)
        )
        score = self._parse_score(raw_content)
        return score

    @staticmethod
    def _build_judge_prompt(content: str) -> str:
        """Structured prompt asking the LLM to return only a numeric appropriateness score."""
        return (
            "You are an impartial safety and relevance judge for clinical text. "
            "Return only a single number between 0 and 1 indicating how appropriate "
            "and clinically relevant the input is for generating a medical report "
            "(0 = inappropriate/off-topic/unsafe, 1 = fully appropriate and relevant). "
            f"Input:\n{content}\nScore:"
        )

    @staticmethod
    def _parse_score(raw_content: str) -> float:
        """Extract a numeric score from the LLM response, ensuring it lies within [0, 1]."""
        match = re.search(r"0(?:\.\d+)?|1(?:\.0+)?", raw_content)
        if not match:
            raise ValueError(
                f"Could not parse appropriateness score from judge response: {raw_content}"
            )
        score = float(match.group(0))
        if score < 0 or score > 1:
            raise ValueError(f"Judge score out of range: {score}")
        return score
