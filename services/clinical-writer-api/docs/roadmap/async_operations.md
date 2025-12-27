# Roadmap: Asynchronous Operations

## Current Issue

The agents' `process` methods are synchronous, which can block the application, especially during I/O-bound LLM calls.

## Recommendation

Refactor the processing logic to be asynchronous using `asyncio`.

```python
# src/conversation_processor_agent.py
import asyncio

class ConversationProcessorAgent:
    # ...
    async def process(self, state: AgentState) -> AgentState:
        # ...
        response = await self.llm_model.ainvoke(prompt)
        # ...

# src/main.py
@app.post("/invoke")
async def invoke_agent(input: Input, graph = Depends(get_graph)) -> AgentState:
    state = {"input_content": input.input_content, "observer": _default_observer}
    final_state = await graph.ainvoke(state) # Use ainvoke for async
    return final_state
```

## Benefits

-   **Performance:** Improves throughput by allowing the application to handle other requests while waiting for the LLM.
-   **Scalability:** Essential for building a responsive and scalable service.

## Priority

**High**
