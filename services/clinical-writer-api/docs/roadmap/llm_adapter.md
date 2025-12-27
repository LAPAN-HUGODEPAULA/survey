# Roadmap: Adapter Pattern for LLM Providers

## Current Issue

The code is tightly coupled to `langchain_google_genai`.

## Recommendation

Create an adapter interface for LLM providers.

```python
# src/llm_adapter.py
from abc import ABC, abstractmethod

class LLMAdapter(ABC):
    @abstractmethod
    def invoke(self, prompt: str) -> str:
        pass

class GeminiAdapter(LLMAdapter):
    def __init__(self, api_key: str, model_name: str, temperature: float):
        from langchain_google_genai import ChatGoogleGenerativeAI
        self.llm = ChatGoogleGenerativeAI(model=model_name, temperature=temperature, api_key=api_key)

    def invoke(self, prompt: str) -> str:
        return self.llm.invoke(prompt).content
```

## Benefits

-   **Provider Agnostic:** Allows you to switch between LLM providers (e.g., OpenAI, Anthropic) with minimal code changes.
-   **Testability:** You can create a mock adapter for testing.

## Priority

**Low** (but important for future flexibility)
