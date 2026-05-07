## Why

The platform currently suffers from an infinite retry loop in `survey-worker` when AI model quotas are exhausted or rate limits are hit, leading to excessive token consumption and potential cost spikes. Furthermore, AI model configuration is fragmented, with environment variables overriding database-managed settings, and no centralized interface to manage global AI defaults without manual deployments.

## What Changes

- **Worker Reliability**: Implement a `retryCount` mechanism and exponential backoff in `survey-worker` to stop the infinite polling of failed documents.
- **Configuration Authority**: Refactor `clinical-writer-api` and `survey-backend` to ensure that database-driven configurations (from Access Points or Global Settings) always supersede environment variables and hardcoded defaults.
- **Global AI Governance**: Introduce a new "Global AI Settings" feature in `survey-builder` to manage system-wide default providers, models, and sampling parameters.
- **Hardcode Removal**: Eliminate literal model version strings (like `glm-4.7`) from the source code, moving all version authority to the configuration layer.
- **Single Pattern Enforcement**: Remove legacy AI configuration fields (`aiProvider`, `glmModel`, `geminiModel`) from backend contracts, persistence models, and builder payloads. Runtime AI resolution MUST use only `aiConfig`.
- **Builder Inheritance UX**: Add clear inheritance labels in `survey-builder` so admins can explicitly choose access-point override or global default behavior.
- **Documentation Synchronization**: Update architecture and operational documentation so all runtime behavior, settings ownership, and configuration hierarchy match the implemented design.

## Capabilities

### New Capabilities
- `global-ai-governance`: Centralized system settings for AI model defaults managed via `survey-builder`.
- `ai-job-resilience`: Managed retry logic and failure states for asynchronous AI processing tasks.

### Modified Capabilities
- `agent-access-point-management`: Updated to correctly prioritize and propagate model configurations.
- `clinical-writer-prompt-resolution`: Refactored to prioritize request payload data over system environments.

## Impact

- **survey-worker**: New retry logic and document schema updates (`retryCount`, `lastError`).
- **clinical-writer-api**: Redesigned `ModelRouter` and agent initialization logic to strictly follow payload instructions.
- **survey-backend**: New API endpoints for system settings and updated resolution logic.
- **survey-builder**: New administration screens for Global AI Configuration.
- **Contracts and data model**: Legacy flat AI fields are retired and removed from runtime patterns; `aiConfig` becomes the single source of truth across all components.
- **Documentation set**: Existing architecture and runbook documents that describe AI routing/configuration authority must be updated to avoid outdated guidance.

## Delivery Strategy

This change remains a **single OpenSpec proposal** and is implemented as one cohesive governance cutover.

- We intentionally avoid multi-proposal transition work because the project is pre-production and the desired outcome is a strict, non-hybrid architecture.
- Execution may still happen in ordered tasks, but all tasks enforce the same final invariant: one schema (`aiConfig`) and one authority chain.
