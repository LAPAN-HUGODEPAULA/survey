## Context
The `clinical-narrative` app needs voice input with high-quality transcription. The flow should be hybrid: browser preview for fast feedback and final server transcription for clinical quality. The backend must support multiple STT providers without direct coupling.

## Goals / Non-Goals
- Goals:
  - Modular, configurable architecture for capture and transcription.
  - Hybrid flow with local preview and final server transcription.
  - Provider-agnostic and extensible transcription contract.
  - Audio retention policy with verifiable deletion.
- Non-Goals:
  - Choose and lock a specific STT provider.
  - Implement fully offline processing in the browser.

## Decisions
- Decision: Use Strategy + Adapter for transcription providers in the backend.
  - Rationale: Allows switching providers (Whisper, AWS, etc.) via configuration without rewriting the flow.
- Decision: Split capabilities into distinct specs (capture, preview, processing, playback, retention, errors).
  - Rationale: Avoids monolithic requirements and supports incremental evolution.
- Decision: Parameterize formats, limits, and language via configuration.
  - Rationale: Enables tuning for quality and cost while keeping consistency.

## Alternatives Considered
- Monolithic (a single coupled transcription service): rejected due to reduced flexibility.
- 100% client-side processing: rejected due to support and quality variance.

## Risks / Trade-offs
- Risk: Quality differences across providers.
  - Mitigation: Confidence metadata, validation, and configurable thresholds.
- Risk: Audio upload latency.
  - Mitigation: Local preview + progress feedback + configurable timeouts.

## Migration Plan
1. Introduce the provider-agnostic contract and endpoints behind feature flags.
2. Release capture and preview in the frontend.
3. Enable final server transcription and measure quality.
4. Enable retention policy and auditability.

## Open Questions
- Maximum duration and audio size limits per session.
- Initial confidence thresholds and quality alerts.
