# Roadmap: Factory Pattern for Agent Creation

## Current Issue

Agents are instantiated directly in `agent_graph.py`.

## Recommendation

Use a factory to centralize agent creation.

```python
# src/agent_factory.py
from clinical_writer_agent.src.agent_config import AgentConfig
from clinical_writer_agent.src.conversation_processor_agent import ConversationProcessorAgent
from clinical_writer_agent.src.json_processor_agent import JsonProcessorAgent
# ...

class AgentFactory:
    @staticmethod
    def create_conversation_processor() -> ConversationProcessorAgent:
        llm = AgentConfig.create_llm_instance()
        return ConversationProcessorAgent(llm)

    @staticmethod
def create_json_processor() -> JsonProcessorAgent:
        llm = AgentConfig.create_llm_instance()
        return JsonProcessorAgent(llm)
    # ... other agents
```

## Benefits

-   **Centralization:** Simplifies agent creation and dependency management.
-   **Flexibility:** Makes it easier to change agent implementations or their dependencies.

## Priority

**Medium**
