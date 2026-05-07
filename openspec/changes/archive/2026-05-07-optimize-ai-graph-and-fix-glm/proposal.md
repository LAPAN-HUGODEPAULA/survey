## Why

The AI clinical writer is currently experiencing critical failures and excessive token burn. A concurrency bug in the recently added GLM client (`asyncio.run()` called within a running event loop) causes immediate crashes, forcing all traffic to fallback to Google Gemini. This has led to rapid quota exhaustion (429 errors) and system-wide unavailability. Additionally, the 3-stage agentic workflow (Analyzer -> Writer -> Reflector) is too resource-intensive for the current budget/free-tier constraints.

## What Changes

- **Fix Concurrency Bug**: Refactor `GLMClient` to use the synchronous `openai.OpenAI` client instead of `AsyncOpenAI`, eliminating the `asyncio.run()` conflict.
- **Optimize Orchestration**: Temporarily bypass the `ReflectorNode` in the LangGraph to reduce LLM calls per request from 3 to 2, saving ~30-40% in token consumption and reducing latency.
- **Improve Resilience**: Update the graph's conditional edges to ensure robust error handling and cleaner short-circuiting when budget limits are hit.

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `clinical-writer-provider-routing`: Fix implementation bug in GLM client to ensure actual availability of the primary provider.
- `layered-graph-orchestration`: Modify the orchestration flow to bypass reflection, prioritizing cost and speed while maintaining clinical interpretation quality.

## Impact

- **Affected Services**: `services/clinical-writer-api/clinical_writer_agent`.
- **Operational Impact**: Reduced LLM costs, lower latency, and restoration of service availability through primary provider (GLM) restoration.
- **Breaking Changes**: None. The external API contract remains identical; only internal orchestration speed and cost are affected.
