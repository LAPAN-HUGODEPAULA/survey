# Roadmap: Repository Pattern for File Access

## Current Issue

The `InputValidator` directly reads files (`bad_word.txt`, `slangs.txt`) in its constructor. This couples the validator to the file system and makes it harder to test.

## Recommendation

Implement a `ValidationDataRepository` to encapsulate file access.

```python
# src/repositories.py
from functools import lru_cache
from clinical_writer_agent.src.agent_config import AgentConfig

class ValidationDataRepository:
    """Repository for accessing validation data files."""

    @staticmethod
    @lru_cache(maxsize=None)
    def load_bad_words() -> list[str]:
        """Load and cache bad words from file."""
        with open(AgentConfig.BAD_WORDS_FILE, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip()]

    @staticmethod
    @lru_cache(maxsize=None)
    def load_slang_patterns() -> list[str]:
        """Load and cache slang patterns from file."""
        with open(AgentConfig.SLANGS_FILE, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip()]

# src/input_validator.py
class InputValidator:
    def __init__(self, repository: ValidationDataRepository):
        self.repository = repository
        # ...
        bad_words = self.repository.load_bad_words()
        slang_patterns = self.repository.load_slang_patterns()
        # ...
```

## Benefits

-   **Decoupling:** The validator is no longer responsible for file I/O.
-   **Testability:** You can easily mock the repository in tests.
-   **Caching:** `functools.lru_cache` provides a simple and effective caching mechanism.
-   **Flexibility:** The data source can be changed (e.g., to a database) without affecting the validator.

## Priority

**High**
