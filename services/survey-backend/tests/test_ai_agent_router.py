from datetime import datetime, timezone
from unittest.mock import MagicMock

from fastapi.testclient import TestClient

from app.api.dependencies.builder_auth import require_builder_admin, require_builder_csrf
from app.main import app
from app.persistence.deps import get_ai_agent_repo


client = TestClient(app)


def _override_dependencies(repo: MagicMock) -> None:
    app.dependency_overrides[require_builder_admin] = lambda: None
    app.dependency_overrides[require_builder_csrf] = lambda: None
    app.dependency_overrides[get_ai_agent_repo] = lambda: repo


def _agent_doc() -> dict:
    timestamp = datetime.now(timezone.utc).isoformat()
    return {
        "agentKey": "local_qwen",
        "name": "Local Qwen",
        "providerType": "openai_compatible",
        "baseUrl": "https://lapan-ai.tailf9eac9.ts.net:8088/v1",
        "apiKeyEnvVar": "AI_API_KEY",
        "defaultModel": "qwen2.5-coder:7b",
        "enabled": True,
        "supportsOpenAIChatCompletions": True,
        "supportsResponseFormat": True,
        "supportsRag": True,
        "createdAt": timestamp,
        "modifiedAt": timestamp,
    }


def test_list_ai_agents_redacts_secret_value():
    repo = MagicMock()
    repo.list_all.return_value = [_agent_doc()]
    _override_dependencies(repo)

    response = client.get("/api/v1/ai_agents/")

    assert response.status_code == 200
    payload = response.json()[0]
    assert payload["agentKey"] == "local_qwen"
    assert payload["apiKeyEnvVar"] == "AI_API_KEY"
    assert "apiKey" not in payload
    app.dependency_overrides = {}


def test_create_ai_agent():
    repo = MagicMock()
    repo.create.return_value = _agent_doc()
    _override_dependencies(repo)

    response = client.post(
        "/api/v1/ai_agents/",
        json={
            "agentKey": "local_qwen",
            "name": "Local Qwen",
            "providerType": "openai_compatible",
            "baseUrl": "https://lapan-ai.tailf9eac9.ts.net:8088/v1",
            "apiKeyEnvVar": "AI_API_KEY",
            "defaultModel": "qwen2.5-coder:7b",
            "enabled": True,
            "supportsOpenAIChatCompletions": True,
            "supportsResponseFormat": True,
            "supportsRag": True,
        },
    )

    assert response.status_code == 201
    assert response.json()["defaultModel"] == "qwen2.5-coder:7b"
    app.dependency_overrides = {}
