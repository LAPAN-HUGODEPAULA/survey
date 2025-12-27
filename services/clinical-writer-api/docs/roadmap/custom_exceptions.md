# Roadmap: Custom Exception Hierarchy

## Current Issue

The system uses generic exceptions and string-based error messages, which makes error handling less precise.

## Recommendation

Define a hierarchy of custom exceptions.

```python
# src/exceptions.py
class ClinicalWriterException(Exception):
    """Base exception for the application."""
    pass

class ConfigurationError(ClinicalWriterException):
    """For errors related to configuration."""
    pass

class ValidationError(ClinicalWriterException):
    """For input validation errors."""
    pass

class InappropriateContentError(ValidationError):
    """For inappropriate content."""
    def __init__(self, reason: str):
        self.reason = reason
        super().__init__(f"Content flagged as inappropriate: {reason}")

class LLMProcessingError(ClinicalWriterException):
    """For errors during LLM interaction."""
    pass
```

## Benefits

-   **Granular Error Handling:** Allows for specific `except` blocks for different error types.
-   **Clarity:** Makes the code more self-documenting.
-   **Debugging:** Provides better context for debugging and logging.

## Priority

**High**
