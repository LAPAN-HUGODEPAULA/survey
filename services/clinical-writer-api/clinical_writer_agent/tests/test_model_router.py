from types import SimpleNamespace
from unittest.mock import MagicMock
import pytest
import clinical_writer_agent.model_router as model_router_module
from clinical_writer_agent.model_router import GLMClient, ModelRouter, ModelResponse, OpenAICompatibleClient


def test_model_router_success_primary():
    primary_llm = MagicMock()
    primary_llm.invoke.return_value = ModelResponse(content="primary response")
    
    router = ModelRouter(
        primary_model="glm-4",
        fallback_model="gemini-1.5",
        primary_provider="glm",
        fallback_provider="gemini"
    )
    # Inject mock
    router._get_primary_llm = MagicMock(return_value=primary_llm)
    
    response = router.invoke("test prompt")
    
    assert response.content == "primary response"
    assert router.model_version == "glm:glm-4"
    assert primary_llm.invoke.called


def test_model_router_fallback_on_error():
    primary_llm = MagicMock()
    primary_llm.invoke.side_effect = Exception("primary failed")
    
    fallback_llm = MagicMock()
    fallback_llm.invoke.return_value = ModelResponse(content="fallback response")
    
    router = ModelRouter(
        primary_model="glm-4",
        fallback_model="gemini-1.5",
        primary_provider="glm",
        fallback_provider="gemini"
    )
    # Inject mocks
    router._get_primary_llm = MagicMock(return_value=primary_llm)
    router._get_fallback_llm = MagicMock(return_value=fallback_llm)
    
    response = router.invoke("test prompt")
    
    assert response.content == "fallback response"
    assert router.model_version == "gemini:gemini-1.5"
    assert primary_llm.invoke.called
    assert fallback_llm.invoke.called


def test_model_router_raises_when_both_fail():
    primary_llm = MagicMock()
    primary_llm.invoke.side_effect = Exception("primary failed")
    
    fallback_llm = MagicMock()
    fallback_llm.invoke.side_effect = Exception("fallback failed")
    
    router = ModelRouter(
        primary_model="glm-4",
        fallback_model="gemini-1.5",
        primary_provider="glm",
        fallback_provider="gemini"
    )
    # Inject mocks
    router._get_primary_llm = MagicMock(return_value=primary_llm)
    router._get_fallback_llm = MagicMock(return_value=fallback_llm)
    
    with pytest.raises(Exception, match="fallback failed"):
        router.invoke("test prompt")


def test_glm_client_invoke_uses_sync_openai_client(monkeypatch):
    create_mock = MagicMock(
        return_value=SimpleNamespace(
            choices=[SimpleNamespace(message=SimpleNamespace(content="glm response"))]
        )
    )
    openai_client = SimpleNamespace(
        chat=SimpleNamespace(
            completions=SimpleNamespace(create=create_mock)
        )
    )

    monkeypatch.setattr(model_router_module, "OpenAI", lambda **_kwargs: openai_client)
    client = GLMClient(model="glm-4-flash", api_key="key", base_url="https://api.z.ai/api/paas/v4/")

    response = client.invoke("hello")

    assert response.content == "glm response"
    create_mock.assert_called_once_with(
        model="glm-4-flash",
        messages=[{"role": "user", "content": "hello"}],
        temperature=0.0,
        do_sample=False,
        extra_body={"thinking": {"type": "disabled"}},
    )


def test_openai_compatible_client_uses_configured_base_url_and_payload(monkeypatch):
    create_mock = MagicMock(
        return_value=SimpleNamespace(
            choices=[SimpleNamespace(message=SimpleNamespace(content="ok"))]
        )
    )
    openai_client = SimpleNamespace(
        chat=SimpleNamespace(
            completions=SimpleNamespace(create=create_mock)
        )
    )
    openai_constructor = MagicMock(return_value=openai_client)
    monkeypatch.setattr(model_router_module, "OpenAI", openai_constructor)

    client = OpenAICompatibleClient(
        model="qwen2.5-coder:7b",
        api_key="key",
        base_url="https://lapan-ai.tailf9eac9.ts.net:8088/v1",
        temperature=0.3,
        max_tokens=64,
    )
    response = client.invoke("hello")

    assert response.content == "ok"
    openai_constructor.assert_called_once_with(
        api_key="key",
        base_url="https://lapan-ai.tailf9eac9.ts.net:8088/v1",
        timeout=120.0,
    )
    create_mock.assert_called_once_with(
        model="qwen2.5-coder:7b",
        messages=[{"role": "user", "content": "hello"}],
        temperature=0.3,
        stream=False,
        max_tokens=64,
    )


def test_model_router_uses_ordered_agent_routes(monkeypatch):
    primary_llm = MagicMock()
    primary_llm.invoke.side_effect = RuntimeError("local failed")
    fallback_llm = MagicMock()
    fallback_llm.invoke.return_value = ModelResponse(content="fallback response")
    router = ModelRouter(
        primary_model="qwen2.5-coder:7b",
        agent_routes=[
            {
                "agentKey": "local_qwen",
                "providerType": "openai_compatible",
                "baseUrl": "https://lapan-ai.tailf9eac9.ts.net:8088/v1",
                "apiKeyEnvVar": "AI_API_KEY",
                "model": "qwen2.5-coder:7b",
                "enabled": True,
            },
            {
                "agentKey": "gemini",
                "providerType": "gemini",
                "apiKeyEnvVar": "GEMINI_API_KEY",
                "model": "gemini-2.5-flash",
                "enabled": True,
            },
        ],
    )
    route_clients = [primary_llm, fallback_llm]
    monkeypatch.setattr(router, "_get_route_llm", lambda index, _route: route_clients[index])

    response = router.invoke("test prompt")

    assert response.content == "fallback response"
    assert router.model_version == "gemini:gemini-2.5-flash"


def test_model_router_emits_fallback_model_version_when_primary_fails():
    primary_llm = MagicMock()
    primary_llm.invoke.side_effect = RuntimeError("429 RESOURCE_EXHAUSTED")
    fallback_llm = MagicMock()
    fallback_llm.invoke.return_value = ModelResponse(content="fallback response")

    router = ModelRouter(
        primary_model="glm-4",
        fallback_model="gemini-1.5",
        primary_provider="glm",
        fallback_provider="gemini",
    )
    router._get_primary_llm = MagicMock(return_value=primary_llm)
    router._get_fallback_llm = MagicMock(return_value=fallback_llm)

    response = router.invoke("test prompt")

    assert response.content == "fallback response"
    assert router.model_version == "gemini:gemini-1.5"
