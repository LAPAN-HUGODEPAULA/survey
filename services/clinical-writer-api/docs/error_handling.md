# Error Handling

## Standardized Error Messages

Error messages have been standardized and centralized in the `agent_config.py` file. This ensures consistency across the application and makes them easier to manage and internationalize.

### Before Refactoring

Error messages were hardcoded and duplicated across multiple files, leading to inconsistencies.

```python
# conversation_processor_agent.py
new_state["error_message"] = f"Error generating medical record: {e}"

# input_validator.py
new_state["error_message"] = "Input content flagged as inappropriate."
```

### After Refactoring

All error messages are defined as constants in `AgentConfig`.

```python
# agent_config.py
class AgentConfig:
    ERROR_MSG_INAPPROPRIATE_CONTENT = "Input content flagged as inappropriate."
    ERROR_MSG_UNCLASSIFIED_INPUT = "Input content could not be classified as conversation or JSON. Please provide a valid input."
    ERROR_MSG_MEDICAL_RECORD_GENERATION = "Error generating medical record: {error}"
    ERROR_MSG_NO_ERROR_AVAILABLE = "No error message available"

# Usage in any file
new_state["error_message"] = AgentConfig.ERROR_MSG_INAPPROPRIATE_CONTENT
new_state["error_message"] = AgentConfig.ERROR_MSG_MEDICAL_RECORD_GENERATION.format(error=e)
```

## Future Improvements: Custom Exception Hierarchy

For more robust error handling, a custom exception hierarchy is recommended. This will provide more context for errors and allow for more specific error handling logic.

### Proposed Exception Hierarchy

```python
# exceptions.py
class ClinicalWriterException(Exception):
    """Base exception for clinical writer system"""
    pass

class ConfigurationError(ClinicalWriterException):
    """Raised when configuration is invalid"""
    pass

class ValidationError(ClinicalWriterException):
    """Raised when input validation fails"""
    pass

class InappropriateContentError(ValidationError):
    """Raised when content is flagged as inappropriate"""
    def __init__(self, reason: str):
        self.reason = reason
        super().__init__(f"Content flagged: {reason}")

class ClassificationError(ClinicalWriterException):
    """Raised when input cannot be classified"""
    pass

class LLMProcessingError(ClinicalWriterException):
    """Raised when LLM processing fails"""
    def __init__(self, original_error: Exception):
        self.original_error = original_error
        super().__init__(f"LLM processing failed: {original_error}")
```

### Benefits

*   **Better Debugging:** Clear, domain-specific exceptions make it easier to identify the source of errors.
*   **Specific Handling:** Allows for `try...except` blocks that catch specific types of errors.
*   **Improved Logging:** More informative error logs.