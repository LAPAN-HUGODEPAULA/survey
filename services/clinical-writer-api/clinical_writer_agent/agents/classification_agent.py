"""Classification agent that encapsulates the Strategy Pattern for routing decisions.

This module isolates semantic classification from validation and generation. The agent
consumes already-validated and sanitized text, executes a prioritized set of strategies
(inappropriate-content detection, JSON detection, conversation cues, fallback), and
produces a classification label that directs the LangGraph to the appropriate processor.
The separation of concerns allows us to evolve validation (including LLM judges) and
classification independently while keeping the routing logic explicit and testable.
"""

# Package imports
import logging
from datetime import datetime
from typing import Callable, Iterable, Optional

# Project imports
from .agent_state import AgentState
from ..agent_config import AgentConfig
from ..classification_strategies import (
    ClassificationContext,
    ClassificationStrategy,
    ConversationClassificationStrategy,
    InappropriateContentStrategy,
    JsonClassificationStrategy,
    OtherClassificationStrategy,
)

logger = logging.getLogger(__name__)


class ClassificationAgent:  # pylint: disable=too-few-public-methods
    """Delegates classification to a prioritized set of strategies."""

    def __init__(
        self,
        *,
        extra_strategies: Optional[Iterable[ClassificationStrategy]] = None,
        strategy_factories: Optional[
            Iterable[Callable[[], ClassificationStrategy]]
        ] = None,
    ):
        """
        Initialize classification strategies, honoring dynamic registrations.
        """
        with open(AgentConfig.BAD_WORDS_FILE, "r", encoding="utf-8") as bad_words_file:
            bad_words = [line.strip() for line in bad_words_file if line.strip()]

        with open(AgentConfig.SLANGS_FILE, "r", encoding="utf-8") as slang_file:
            slang_patterns = [line.strip() for line in slang_file if line.strip()]

        self.classification_context = ClassificationContext()
        self.classification_context.add_strategy(
            InappropriateContentStrategy(bad_words, slang_patterns)
        )
        self.classification_context.add_strategy(JsonClassificationStrategy())
        self.classification_context.add_strategy(ConversationClassificationStrategy())
        self.classification_context.add_strategy(OtherClassificationStrategy())

        factories = list(
            strategy_factories or AgentConfig.CLASSIFICATION_STRATEGY_FACTORIES
        )
        for factory in factories:
            self.classification_context.add_strategy(factory())

        if extra_strategies:
            for strategy in extra_strategies:
                self.classification_context.add_strategy(strategy)

    def classify(self, state: AgentState) -> AgentState:
        """Classify sanitized input and attach routing metadata."""
        text_input = state.get("input_content", "")
        request_id = state.get("request_id")
        new_state = state.copy()
        observer = state.get("observer")

        start_time = datetime.now()
        if observer:
            observer.on_processing_start(
                "classification",
                start_time,
                {"input_length": len(text_input)},
                request_id,
            )

        classification = self.classification_context.classify(
            text_input, observer=observer, request_id=request_id
        )
        new_state["classification"] = classification

        metadata = {
            "input_length": len(text_input),
            "classification_duration": (datetime.now() - start_time).total_seconds(),
            "classification": classification,
        }

        if classification == AgentConfig.CLASSIFICATION_FLAGGED:
            new_state["error_message"] = AgentConfig.ERROR_MSG_INAPPROPRIATE_CONTENT
            metadata["reason"] = "strategy_flagged"
        elif classification == AgentConfig.CLASSIFICATION_OTHER:
            new_state["error_message"] = AgentConfig.ERROR_MSG_UNCLASSIFIED_INPUT
            metadata["reason"] = "unclassified"

        if observer:
            observer.on_processing_complete(
                "classification",
                metadata["classification_duration"],
                datetime.now(),
                metadata,
                request_id,
            )
            observer.on_classification(classification, datetime.now(), metadata, request_id)

        logger.info(
            "Classification completed for request_id=%s",
            request_id,
            extra={"metadata": metadata},
        )

        return new_state
