# Roadmap: Service Layer Implementation

This document outlines the plan to implement a service layer within the Clinical Writer AI system, as per the recommendation in `REFACTORING_RECOMMENDATIONS.md`.

## 1. Goal

The primary goal is to separate the core business logic (generating clinical records) from the agent orchestration and LLM interaction logic. This will create a more modular, testable, and maintainable architecture.

## 2. Proposed Architecture

A new `ClinicalRecordService` will be created. This service will expose methods for generating clinical records from various input formats.

```python
# clinical_writer_agent/src/services/clinical_record_service.py

class ClinicalRecordService:
    """
    A service responsible for the business logic of generating
    clinical records.
    """
    def __init__(self, llm_provider):
        self.llm_provider = llm_provider

    def generate_from_conversation(self, conversation_text: str) -> str:
        """
        Generates a clinical record from a plain text conversation.
        
        (This is where the core prompt engineering and LLM calls will happen)
        """
        # ... implementation ...
        pass

    def generate_from_json(self, json_data: dict) -> str:
        """
        Generates a clinical record from structured JSON data.
        """
        # ... implementation ...
        pass
```

## 3. Impact on Existing Code

*   **Agents (`ConversationProcessorAgent`, `JsonProcessorAgent`)**: These agents will be refactored to use the `ClinicalRecordService`. Instead of containing the generation logic themselves, they will call the appropriate method on the service.
*   **Dependency Injection**: The `ClinicalRecordService` will be instantiated and injected into the agents where needed, likely managed by a future dependency injection container.

## 4. Implementation Steps

1.  Create the `services` directory and the `clinical_record_service.py` file.
2.  Implement the `ClinicalRecordService` class.
3.  Move the record generation logic from the agents to the service.
4.  Refactor the agents to use the service.
5.  Update unit and integration tests to cover the new service and the refactored agents.
