"""
Integration test to verify the Strategy Pattern and validation pipeline work together.
"""
from ..agent_config import AgentConfig
from ..agents.agent_state import AgentState
from ..agents.classification_agent import ClassificationAgent
from ..agents.input_validator_agent import InputValidatorAgent


class _StubJudge:
    def __init__(self, score: float = 1.0):
        self.score = score

    def invoke(self, prompt: str):

        class Response:
            def __init__(self, content: str):
                self.content = content

        return Response(str(self.score))


def test_integration():
    """Test that validation + classification cooperate to route inputs correctly."""
    validator = InputValidatorAgent(llm_judge=_StubJudge(1.0))
    classifier = ClassificationAgent()

    print("Testing Strategy Pattern Integration...")
    print("=" * 60)

    def _run_pipeline(text: str) -> AgentState:
        state = AgentState(input_content=text)
        validated = validator.validate(state)
        if validated.get("classification") == AgentConfig.CLASSIFICATION_FLAGGED:
            return validated
        return classifier.classify(validated)

    # Test 1: JSON input
    print("\n1. Testing JSON classification:")
    result = _run_pipeline('{"patient": "John Doe", "age": 30}')
    print(f"   Input: JSON with patient key")
    print(f"   Result: {result.get('classification')}")
    assert result.get('classification') == AgentConfig.CLASSIFICATION_JSON, "JSON classification failed"
    print("   ✅ PASS")

    # Test 2: Conversation input
    print("\n2. Testing conversation classification:")
    result = _run_pipeline("Doutor: Como está? Paciente: Bem, obrigado.")
    print(f"   Input: Conversation with 'doutor' and 'paciente'")
    print(f"   Result: {result.get('classification')}")
    assert result.get('classification') == AgentConfig.CLASSIFICATION_CONVERSATION, "Conversation classification failed"
    print("   ✅ PASS")

    # Test 3: Inappropriate content
    print("\n3. Testing inappropriate content detection:")
    result = _run_pipeline("Buy now and get discount!")
    print(f"   Input: Text with ad keywords")
    print(f"   Result: {result.get('classification')}")
    assert result.get('classification') == AgentConfig.CLASSIFICATION_FLAGGED, "Inappropriate content detection failed"
    assert "error_message" in result, "Error message not set"
    print("   ✅ PASS")

    # Test 4: Other/unclassified
    print("\n4. Testing fallback classification:")
    result = _run_pipeline("Just some random text here.")
    print(f"   Input: Random text without keywords")
    print(f"   Result: {result.get('classification')}")
    assert result.get('classification') == AgentConfig.CLASSIFICATION_OTHER, "Other classification failed"
    assert "error_message" in result, "Error message not set for other"
    print("   ✅ PASS")

    # Test 5: Priority order (inappropriate should be caught before conversation)
    print("\n5. Testing strategy priority order:")
    result = _run_pipeline("Doutor, buy now for discount!")
    print(f"   Input: Text with both conversation and ad keywords")
    print(f"   Result: {result.get('classification')}")
    assert result.get('classification') == AgentConfig.CLASSIFICATION_FLAGGED, "Priority order failed"
    print("   ✅ PASS (Inappropriate content caught first)")

    print("\n" + "=" * 60)
    print("✅ ALL INTEGRATION TESTS PASSED!")
    print("\nStrategy Pattern is working correctly with the full system.")
    print("InputValidator performs validation + judging; ClassificationAgent delegates to strategies.")


if __name__ == "__main__":
    test_integration()
