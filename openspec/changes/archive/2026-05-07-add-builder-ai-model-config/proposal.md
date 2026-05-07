## Why

Currently, AI model configurations (primary/fallback models, temperature, reasoning parameters) are largely static or hardcoded, leading to operational rigidity and cost inefficiencies. This change enables dynamic AI agent setup via `survey-builder`, allowing administrators to tune clinical AI behavior, optimize costs through input caching, and leverage cost-effective models like `glm-4.5-flash` during promotional periods.

## What Changes

- **AI Model Selection**: Ability to configure primary and fallback models (defaulting to `glm-4.5-flash` for MVP) in `survey-builder` at both global and specific Agent Access Point levels.
- **Advanced Parameter Tuning**: UI for setting core LLM parameters such as temperature and reasoning effort (based on Zhipu AI/GLM standards).
- **Cost Optimization (Input Caching)**: Implementation of input caching mechanisms in `clinical-writer-api` to reduce token consumption and costs for repetitive clinical analysis tasks.
- **Dynamic LangGraph Setup**: The `clinical-writer-api` will dynamically initialize the agent graph using these database-driven parameters.
- **Resilient Request Polling**: Refactored frontend-to-backend and backend-to-agent polling logic to include a delayed start and longer intervals, matching the typical ~1 minute processing time of complex clinical models.

## Capabilities

### New Capabilities
- `ai-model-caching`: Standards for implementing and managing LLM input caching to optimize clinical AI costs.
- `ai-parameter-governance`: Governance framework for managing core AI parameters (temperature, reasoning) across clinical contexts.

### Modified Capabilities
- `clinical-writer-provider-routing`: Adding dynamic model selection and advanced parameters to the routing logic.
- `agent-access-point-management`: Extending the management UI in `survey-builder` to include model and parameter configurations.
- `ai-progress-api-contract`: Updating the polling contract and intervals to align with model performance profiles.

## Impact

- **survey-builder**: New UI components for model and parameter configuration.
- **survey-backend**: Database schema updates for `AgentAccessPoints` and `SystemSettings`; updated client logic for clinical writer interaction.
- **clinical-writer-api**: Refactored initialization logic; updated Pydantic models; integration of provider-specific caching headers/parameters.
- **Database**: Schema changes to `AgentAccessPoints` collection in MongoDB.
