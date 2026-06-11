import pytest
from app.domain.models.agent_access_point_model import AgentAccessPointUpsert, AIConfig

def test_agent_access_point_upsert_serialization_with_ai_config():
    payload = {
        "accessPointKey": "test.key",
        "name": "Test Name",
        "sourceApp": "survey-patient",
        "flowKey": "test.flow",
        "promptKey": "p1",
        "personaSkillKey": "ps1",
        "outputProfile": "op1",
        "aiConfig": {
            "primaryProvider": "glm",
            "primaryModel": "glm-4",
            "temperature": 0.5,
            "reasoningEffort": "medium",
            "enableCaching": True
        }
    }
    
    model = AgentAccessPointUpsert.model_validate(payload)
    assert model.ai_config is not None
    assert model.ai_config.primary_provider == "glm"
    assert model.ai_config.temperature == 0.5
    assert model.ai_config.reasoning_effort == "medium"

def test_ai_config_validation():
    # Valid
    AIConfig(primaryProvider="glm", primaryModel="glm-4", reasoningEffort="low")
    
    # Invalid reasoning effort
    with pytest.raises(ValueError, match="reasoningEffort must be one of"):
        AIConfig(primaryProvider="glm", primaryModel="glm-4", reasoningEffort="super-high")
        
    # Invalid temperature
    with pytest.raises(ValueError):
        AIConfig(primaryProvider="glm", primaryModel="glm-4", temperature=1.5)


def test_ai_config_accepts_agent_refs_without_legacy_provider():
    model = AIConfig(
        agentRefs=[
            {
                "agentKey": "local_qwen",
                "model": "qwen2.5-coder:7b",
                "temperature": 0.3,
                "enabled": True,
            }
        ]
    )

    assert model.agent_refs is not None
    assert model.agent_refs[0].agent_key == "local_qwen"
    assert model.agent_refs[0].temperature == 0.3
