from types import SimpleNamespace
from unittest.mock import MagicMock
import pytest
import clinical_writer_agent.model_router as model_router_module
from clinical_writer_agent.model_router import GLMClient, ModelRouter, ModelResponse


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
