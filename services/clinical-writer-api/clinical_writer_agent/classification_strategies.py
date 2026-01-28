"""
Classification strategies for input validation.
Implements the Strategy Pattern for flexible and extensible input classification.
"""

# Package imports
import json
import logging
import re
from abc import ABC, abstractmethod
from datetime import datetime
from typing import Optional, Tuple, TYPE_CHECKING

from .agent_config import AgentConfig
from .monitoring.base_monitors import ProcessingMonitor

logger = logging.getLogger(__name__)


class ClassificationStrategy(ABC):
    """Abstract base class for classification strategies"""

    @abstractmethod
    def classify(self, text: str) -> Tuple[Optional[str], bool]:
        """
        Classify the input text.

        Args:
            text: The input text to classify

        Returns:
            Tuple of (classification_type, is_valid)
            - classification_type: The type of classification if successful, None otherwise
            - is_valid: True if this strategy successfully classified the input
        """
        pass

    @abstractmethod
    def get_priority(self) -> int:
        """
        Get the priority of this strategy.
        Lower numbers are checked first.

        Returns:
            Priority value (0 = highest priority)
        """
        pass


class InappropriateContentStrategy(ClassificationStrategy):
    """Strategy for detecting inappropriate content (highest priority)"""

    def __init__(self, bad_words: list[str], slang_patterns: list[str]):
        """
        Initialize with bad words and slang patterns.

        Args:
            bad_words: List of inappropriate words to check
            slang_patterns: List of slang patterns to check
        """
        self.bad_words = bad_words
        self.slang_patterns = slang_patterns

        # Build emoji pattern from config
        emoji_ranges = "".join(AgentConfig.EMOJI_UNICODE_RANGES)
        self.emoji_pattern = re.compile(f"[{emoji_ranges}]+", flags=re.UNICODE)

        # Build markup pattern from config
        self.markup_pattern = re.compile(AgentConfig.MARKUP_PATTERN)

        # Get ad keywords from config
        self.ad_keywords = AgentConfig.AD_KEYWORDS

    def classify(self, text: str) -> Tuple[Optional[str], bool]:
        """Check if text contains inappropriate content"""
        if self._contains_bad_content(text):
            return (AgentConfig.CLASSIFICATION_FLAGGED, True)
        return (None, False)

    def get_priority(self) -> int:
        """Highest priority - check for inappropriate content first"""
        return 0

    def _contains_bad_content(self, text: str) -> bool:
        """Check if text contains any inappropriate content"""
        text_lower = text.lower()

        # Check bad words
        if any(word in text_lower for word in self.bad_words):
            return True

        # Check slang patterns
        if any(re.search(pattern, text_lower) for pattern in self.slang_patterns):
            return True

        # Check emojis
        if self.emoji_pattern.search(text):
            return True

        # Check markup
        if self.markup_pattern.search(text_lower):
            return True

        # Check ad keywords
        if any(keyword in text_lower for keyword in self.ad_keywords):
            return True

        return False


class JsonClassificationStrategy(ClassificationStrategy):
    """Strategy for classifying JSON input"""

    def classify(self, text: str) -> Tuple[Optional[str], bool]:
        """Check if text is JSON-like and contains the required surveyId key."""
        json_data = self._parse_json(text)
        if json_data is not None and self._has_survey_id(json_data):
            return (AgentConfig.CLASSIFICATION_JSON, True)

        recovered = self._recover_json_with_survey_id(text)
        if recovered is not None and self._has_survey_id(recovered):
            return (AgentConfig.CLASSIFICATION_JSON, True)

        return (None, False)

    def get_priority(self) -> int:
        """Medium priority - check JSON after inappropriate content"""
        return 1

    def _parse_json(self, text: str):
        """
        Attempt to parse JSON directly, then handle nested JSON-in-a-string patterns.
        Returns parsed JSON object or None.
        """
        try:
            json_data = json.loads(text)
        except json.JSONDecodeError:
            return None

        if isinstance(json_data, str):
            try:
                return json.loads(json_data)
            except json.JSONDecodeError:
                return None

        return json_data

    def _has_survey_id(self, obj) -> bool:
        """Recursively check for surveyId in dicts or lists."""
        if isinstance(obj, dict):
            if "surveyId" in obj:
                return True
            return any(self._has_survey_id(value) for value in obj.values())
        if isinstance(obj, list):
            return any(self._has_survey_id(item) for item in obj)
        return False

    def _recover_json_with_survey_id(self, text: str):
        """Handle common JSON syntax issues when surveyId is present."""
        fragment = self._extract_fragment_with_survey_id(text)
        if not fragment:
            return None

        normalized = fragment.replace("'", '"')
        normalized = re.sub(r",\s*([}\]])", r"\1", normalized)

        try:
            return json.loads(normalized)
        except json.JSONDecodeError:
            return None

    def _extract_fragment_with_survey_id(self, text: str) -> Optional[str]:
        """Find a JSON-like fragment that includes surveyId for lenient parsing."""
        candidates = re.findall(
            r"(\{[^{}]*surveyId[^{}]*\}|\[[^\[\]]*surveyId[^\[\]]*\])",
            text,
            flags=re.IGNORECASE,
        )
        if not candidates:
            return None
        # Prefer the first match to keep behavior predictable.
        return candidates[0]


class ConversationClassificationStrategy(ClassificationStrategy):
    """Strategy for classifying conversation-based input"""

    def __init__(self):
        self.doctor_pattern = re.compile(r"\b(doutor|dr\.?|doctor)\b", re.IGNORECASE)
        self.patient_pattern = re.compile(r"\b(paciente|patient)\b", re.IGNORECASE)
        self.dialogue_marker_pattern = re.compile(
            r"(doutor|dr\.?|doctor|paciente|patient)\s*[:\-–—]"
        )
        self.pronoun_pattern = re.compile(
            r"\b(eu|estou|sinto|minha|meu|nossa|nosso)\b", re.IGNORECASE
        )
        self.html_tag_pattern = re.compile(r"<[^>]+>")

    def classify(self, text: str) -> Tuple[Optional[str], bool]:
        """Check if text contains conversation cues beyond single keywords."""
        text_lower = text.lower()

        if self._has_structured_or_survey_content(text, text_lower):
            return (None, False)

        doctor_hit = bool(self.doctor_pattern.search(text_lower))
        patient_hit = bool(self.patient_pattern.search(text_lower))
        dialogue_hit = bool(
            self.dialogue_marker_pattern.search(text_lower) or "\n" in text_lower
        )
        pronoun_hit = bool(self.pronoun_pattern.search(text_lower))
        question_hit = "?" in text_lower

        cue_score = sum(
            1
            for hit in [
                doctor_hit,
                patient_hit,
                dialogue_hit,
                pronoun_hit or question_hit,
            ]
            if hit
        )

        long_with_doctor = doctor_hit and len(text_lower.split()) >= 6

        if cue_score >= 2 or long_with_doctor:
            return (AgentConfig.CLASSIFICATION_CONVERSATION, True)

        return (None, False)

    def _has_structured_or_survey_content(self, text: str, text_lower: str) -> bool:
        """Block conversation detection when structured data or survey markers appear."""
        if "surveyid" in text_lower:
            return True

        if self.html_tag_pattern.search(text):
            return True

        stripped = text.strip()
        if stripped.startswith(("{", "[")):
            return True

        try:
            json.loads(text)
            return True
        except json.JSONDecodeError:
            pass

        if re.search(r"\{[^{}]*\}|\[[^\[\]]*\]", text):
            return True

        return False

    def get_priority(self) -> int:
        """Lower priority - check conversation patterns after JSON"""
        return 2


class OtherClassificationStrategy(ClassificationStrategy):
    """Fallback strategy for unclassified input (lowest priority)"""

    def classify(self, text: str) -> Tuple[Optional[str], bool]:
        """Always returns 'other' classification as fallback"""
        return (AgentConfig.CLASSIFICATION_OTHER, True)

    def get_priority(self) -> int:
        """Lowest priority - catch-all fallback"""
        return 999


class ClassificationContext:
    """
    Context class that uses classification strategies.
    Maintains a list of strategies and applies them in priority order.
    """

    def __init__(self):
        """Initialize with empty strategy list"""
        self.strategies: list[ClassificationStrategy] = []

    def add_strategy(self, strategy: ClassificationStrategy) -> None:
        """
        Add a classification strategy.

        Args:
            strategy: The strategy to add
        """
        self.strategies.append(strategy)
        # Keep strategies sorted by priority
        self.strategies.sort(key=lambda s: s.get_priority())

    def classify(self, text: str, observer: Optional[ProcessingMonitor] = None, request_id: Optional[str] = None) -> str:
        """
        Classify the input text using registered strategies.
        Strategies are applied in priority order until one succeeds.
        """
        start_time = datetime.now()
        if observer:
            observer.on_event(
                "classification_context_start",
                start_time,
                {"strategy_count": len(self.strategies), "input_length": len(text)},
                request_id,
            )

        for strategy in self.strategies:
            strategy_name = type(strategy).__name__
            step_start = datetime.now()
            classification, is_valid = strategy.classify(text)
            step_duration = (datetime.now() - step_start).total_seconds()

            metadata = {
                "strategy": strategy_name,
                "duration": step_duration,
                "classification": classification,
                "is_valid": is_valid,
            }

            if observer:
                observer.on_event(
                    f"strategy_evaluated:{strategy_name}",
                    datetime.now(),
                    metadata,
                    request_id,
                )

            if is_valid:
                result_metadata = {
                    **metadata,
                    "context_duration": (datetime.now() - start_time).total_seconds(),
                }
                logger.info(
                    "Classification resolved via %s for request_id=%s",
                    strategy_name,
                    request_id,
                    extra={"metadata": result_metadata},
                )
                if observer:
                    observer.on_event(
                        "classification_resolved", datetime.now(), result_metadata, request_id
                    )
                return classification or "NONE"

        fallback_metadata = {
            "context_duration": (datetime.now() - start_time).total_seconds(),
            "reason": "fallback_to_other",
        }
        logger.warning(
            "No strategy matched for request_id=%s; falling back to OTHER",
            request_id,
            extra={"metadata": fallback_metadata},
        )
        if observer:
            observer.on_event(
                "classification_fallback", datetime.now(), fallback_metadata, request_id
            )
        return AgentConfig.CLASSIFICATION_OTHER
