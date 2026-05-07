## Why

Administrators and clinicians currently lack the ability to fine-tune the core AI orchestrator prompts (e.g., system instructions and JSON output schemas) and global model configurations without code changes and deployments. The current system relies on hardcoded Python strings in `clinical-writer-api` and environment variables, which limits the platform's flexibility to adapt to new medical domains or LLM updates. Moving these controls to `survey-builder` empowers administrators to manage the full lifecycle of AI generation safely.

## What Changes

- **AI Model Configuration**: Expose comprehensive model settings (Primary/Fallback Provider, Model Name, Temperature, Reasoning Effort) in the `survey-builder` UI for each Agent Access Point.
- **Orchestrator Prompt Management**: Introduce the ability to override hardcoded system prompts (like the main clinical writer instructions and JSON formatting rules) via `survey-builder`.
- **Backend Plumb-through**: Update the `survey-backend` and `clinical-writer-api` to prioritize these dynamic configurations and prompts over the legacy hardcoded defaults.
- **Unified Governance**: Consolidate all AI-related configuration (Domain interpretation, Persona tone, and now Orchestrator behavior/models) into the `survey-builder` administrative interface.

## Capabilities

### New Capabilities
- `ai-model-configuration`: Centralized management of LLM providers, models, and sampling parameters (temperature) via Agent Access Points.
- `orchestrator-prompt-overrides`: Ability to customize the base system instructions and JSON output schemas used by the AI agents.

### Modified Capabilities
- `agent-access-point-management`: Extended to include AI configuration blocks and prompt overrides.
- `clinical-writer-prompt-resolution`: Updated to handle dynamic injection of system and format prompts.

## Impact

- **survey-builder**: New form sections in `AgentAccessPointFormPage` and updated Dart models/repositories.
- **survey-backend**: Updated Pydantic models, MongoDB schema for `AgentAccessPoints`, and API routes for `clinical_writer`.
- **clinical-writer-api**: Refactored `prompt_registry.py` and `agents` to support dynamic prompt injection and model routing.
