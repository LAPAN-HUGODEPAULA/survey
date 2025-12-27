"""
Unit tests for classification strategies.
Tests the Strategy Pattern implementation.
"""

import unittest
import json

from ..classification_strategies import (
    ClassificationContext,
    InappropriateContentStrategy,
    JsonClassificationStrategy,
    ConversationClassificationStrategy,
    OtherClassificationStrategy,
)
from ..agent_config import AgentConfig


class TestClassificationStrategies(unittest.TestCase):
    """Test suite for classification strategies"""

    def setUp(self):
        """Set up test fixtures"""
        # Sample data for inappropriate content strategy
        self.bad_words = ["teste_palavra_ruim", "teste_ofensivo"]
        self.slang_patterns = [r"\bLOL\b", r"\bWTF\b"]  # Use regex patterns

        # Initialize context with all strategies
        self.context = ClassificationContext()
        self.context.add_strategy(
            InappropriateContentStrategy(self.bad_words, self.slang_patterns)
        )
        self.context.add_strategy(JsonClassificationStrategy())
        self.context.add_strategy(ConversationClassificationStrategy())
        self.context.add_strategy(OtherClassificationStrategy())

    def test_json_classification(self):
        """Test JSON classification strategy"""
        json_input = json.dumps(
            {"surveyId": "abc-123", "patient": "John Doe", "age": 30}
        )
        result = self.context.classify(json_input)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_JSON)

    def test_json_with_survey_id(self):
        """Test JSON with surveyId key"""
        json_input = json.dumps({"surveyId": "123", "data": "test"})
        result = self.context.classify(json_input)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_JSON)

    def test_conversation_classification(self):
        """Test conversation classification strategy"""
        conversation = "Doutor: Como você está? Paciente: Estou bem."
        result = self.context.classify(conversation)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_CONVERSATION)

    def test_conversation_with_dr(self):
        """Test conversation with 'dr.' keyword"""
        conversation = "Dr. Silva, estou com dor de cabeça."
        result = self.context.classify(conversation)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_CONVERSATION)

    def test_conversation_requires_multiple_cues(self):
        """Conversation detection should use more than a lone keyword."""
        conversation = "Paciente: sinto dor de cabeça. Doutor: vamos investigar."
        result = self.context.classify(conversation)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_CONVERSATION)

    def test_conversation_skips_when_survey_id_present(self):
        """Presence of surveyId should prevent conversation classification."""
        text = "Dr. Silva surveyId=123: como você está?"
        result = self.context.classify(text)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_OTHER)

    def test_conversation_avoids_false_positive(self):
        """Words like 'doutorado' should not trigger conversation classification."""
        text = "Estou concluindo meu doutorado em engenharia."
        result = self.context.classify(text)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_OTHER)

    def test_inappropriate_content_bad_word(self):
        """Test inappropriate content detection with bad words"""
        text = "Este texto contém teste_palavra_ruim que não deveria"
        result = self.context.classify(text)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_FLAGGED)

    def test_inappropriate_content_slang(self):
        """Test inappropriate content detection with slang pattern"""
        # Create a fresh context with case-insensitive regex pattern
        context = ClassificationContext()
        context.add_strategy(
            InappropriateContentStrategy([], [r"(?i)lol"])  # Case-insensitive regex
        )
        context.add_strategy(JsonClassificationStrategy())
        context.add_strategy(ConversationClassificationStrategy())
        context.add_strategy(OtherClassificationStrategy())

        text = "LOL isso é muito engraçado"
        result = context.classify(text)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_FLAGGED)

    def test_inappropriate_content_ad_keyword(self):
        """Test inappropriate content detection with ad keywords"""
        text = "Buy now and get 50% discount!"
        result = self.context.classify(text)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_FLAGGED)

    def test_other_classification(self):
        """Test fallback to other classification"""
        text = "This is just some random text without any keywords."
        result = self.context.classify(text)
        self.assertEqual(result, AgentConfig.CLASSIFICATION_OTHER)

    def test_priority_order(self):
        """Test that strategies are applied in correct priority order"""
        # Text that could match multiple strategies
        # But inappropriate content should be caught first
        text = "Doutor teste_palavra_ruim: Olá paciente"
        result = self.context.classify(text)
        # Should be flagged as inappropriate, not conversation
        self.assertEqual(result, AgentConfig.CLASSIFICATION_FLAGGED)

    def test_strategy_priorities(self):
        """Test that strategies have correct priorities"""
        inappropriate = InappropriateContentStrategy([], [])
        json_strategy = JsonClassificationStrategy()
        conversation = ConversationClassificationStrategy()
        other = OtherClassificationStrategy()

        self.assertEqual(inappropriate.get_priority(), 0)
        self.assertEqual(json_strategy.get_priority(), 1)
        self.assertEqual(conversation.get_priority(), 2)
        self.assertEqual(other.get_priority(), 999)


class TestIndividualStrategies(unittest.TestCase):
    """Test individual strategies in isolation"""

    def test_json_strategy_valid_json(self):
        """Test JSON strategy with valid JSON"""
        strategy = JsonClassificationStrategy()
        json_text = json.dumps({"patient": "John"})
        classification, is_valid = strategy.classify(json_text)
        self.assertTrue(is_valid)
        self.assertEqual(classification, AgentConfig.CLASSIFICATION_JSON)

    def test_json_strategy_invalid_json(self):
        """Test JSON strategy with invalid JSON"""
        strategy = JsonClassificationStrategy()
        classification, is_valid = strategy.classify("not json at all")
        self.assertFalse(is_valid)
        self.assertIsNone(classification)

    def test_json_strategy_recoverable_with_survey_id(self):
        """Recover JSON-like input that has surveyId but minor syntax issues."""
        strategy = JsonClassificationStrategy()
        json_text = "{'surveyId': 'abc', 'age': 30,}"
        classification, is_valid = strategy.classify(json_text)
        self.assertTrue(is_valid)
        self.assertEqual(classification, AgentConfig.CLASSIFICATION_JSON)

    def test_json_strategy_missing_keys(self):
        """Test JSON strategy without expected keys"""
        strategy = JsonClassificationStrategy()
        json_text = json.dumps({"other": "data"})
        classification, is_valid = strategy.classify(json_text)
        self.assertFalse(is_valid)
        self.assertIsNone(classification)

    def test_conversation_strategy_with_keywords(self):
        """Test conversation strategy with keywords"""
        strategy = ConversationClassificationStrategy()
        text = "Doutor, estou com febre"
        classification, is_valid = strategy.classify(text)
        self.assertTrue(is_valid)
        self.assertEqual(classification, AgentConfig.CLASSIFICATION_CONVERSATION)

    def test_conversation_strategy_without_keywords(self):
        """Test conversation strategy without keywords"""
        strategy = ConversationClassificationStrategy()
        text = "Just some random text"
        classification, is_valid = strategy.classify(text)
        self.assertFalse(is_valid)
        self.assertIsNone(classification)

    def test_conversation_strategy_skips_survey_id(self):
        """Conversation strategy should not match when surveyId appears."""
        strategy = ConversationClassificationStrategy()
        text = "Doutor surveyId: 999"
        classification, is_valid = strategy.classify(text)
        self.assertFalse(is_valid)
        self.assertIsNone(classification)

    def test_conversation_strategy_skips_html(self):
        """HTML-like content should be treated as structured, not conversation."""
        strategy = ConversationClassificationStrategy()
        text = "<div>Paciente: oi</div>"
        classification, is_valid = strategy.classify(text)
        self.assertFalse(is_valid)
        self.assertIsNone(classification)

    def test_conversation_strategy_skips_json_like(self):
        """JSON-like payloads should not be treated as conversation."""
        strategy = ConversationClassificationStrategy()
        text = '{"surveyId":"abc","text":"Olá doutor"}'
        classification, is_valid = strategy.classify(text)
        self.assertFalse(is_valid)
        self.assertIsNone(classification)

    def test_other_strategy_always_matches(self):
        """Test that other strategy always matches"""
        strategy = OtherClassificationStrategy()
        classification, is_valid = strategy.classify("anything")
        self.assertTrue(is_valid)
        self.assertEqual(classification, AgentConfig.CLASSIFICATION_OTHER)

    def test_config_registered_strategies_are_applied(self):
        """Additional strategies registered via config should be evaluated."""
        from clinical_writer_agent.agent_config import AgentConfig
        from clinical_writer_agent.agents.classification_agent import (
            ClassificationAgent,
        )

        class CustomStrategy(OtherClassificationStrategy):
            def classify(self, text: str):
                if "custom_marker" in text:
                    return ("custom", True)
                return (None, False)

            def get_priority(self) -> int:
                return 1  # After inappropriate, alongside JSON

        original_factories = AgentConfig.CLASSIFICATION_STRATEGY_FACTORIES
        AgentConfig.CLASSIFICATION_STRATEGY_FACTORIES = [CustomStrategy]
        try:
            classifier = ClassificationAgent()
            state = classifier.classify({"input_content": "custom_marker example"})
            self.assertEqual(state["classification"], "custom")
        finally:
            AgentConfig.CLASSIFICATION_STRATEGY_FACTORIES = original_factories


if __name__ == "__main__":
    unittest.main()
