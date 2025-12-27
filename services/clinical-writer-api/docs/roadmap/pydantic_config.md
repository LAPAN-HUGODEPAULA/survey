# Roadmap: Configuration Management with Pydantic

## Current Issue

`agent_config.py` is a good start, but it can be made more robust and type-safe.

## Recommendation

Use Pydantic's `BaseSettings` to manage configuration and environment variables.

```python
# src/agent_config.py
from pydantic_settings import BaseSettings
from pathlib import Path

class AgentSettings(BaseSettings):
    GEMINI_API_KEY: str
    LLM_MODEL_NAME: str = "gemini-1.5-flash"
    LLM_TEMPERATURE: float = 0.0
    BASE_DIR: Path = Path(__file__).parent
    BAD_WORDS_FILE: Path = BASE_DIR / "bad_word.txt"
    SLANGS_FILE: Path = BASE_DIR / "slangs.txt"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = AgentSettings()
```

## Benefits

-   **Type Safety:** Pydantic automatically validates the types of your configuration variables.
-   **Environment Variable Loading:** Automatically loads variables from a `.env` file.
-   **Self-Documenting:** The `AgentSettings` class serves as clear documentation for your configuration.

## Priority

**High**
