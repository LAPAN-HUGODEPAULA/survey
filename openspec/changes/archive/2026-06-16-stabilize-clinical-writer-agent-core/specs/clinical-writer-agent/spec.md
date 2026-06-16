# Delta for clinical-writer-agent

## ADDED Requirements

### Requirement: Four-Stage Clinical Writer Graph with Reflection Loop

Clinical Writer report generation SHALL preserve the ordered ContextLoader, ClinicalAnalyzer, PersonaWriter, and ReflectorNode workflow.

#### Scenario: Default flow (Success)
- **GIVEN** valid survey response input and configured prompts/persona skills,
- **WHEN** `/process` is invoked,
- **THEN** the graph MUST load context, analyze clinically, write according to persona, pass reflection validation on the first attempt, and return JSON `ReportDocument` output with no warnings.

#### Scenario: Grounding violation loops back (Retry Success)
- **GIVEN** the initial report written by `PersonaWriter` contains clinical facts or scores not present in the analyzer's output,
- **WHEN** `ReflectorNode` runs,
- **THEN** it MUST mark grounding as false, populate `reflection_feedback` in the state, increment `reflection_retries_used` to 1, and route back to `PersonaWriter` to regenerate.

#### Scenario: Persistent grounding violation (Retry Exceeded Fallback)
- **GIVEN** the report continues to fail reflection checks after 2 retries,
- **WHEN** `ReflectorNode` checks retries,
- **THEN** it MUST allow the generation to complete but MUST append a translation-appropriate safety warning to the state's `warnings` list.

#### Scenario: Missing prompt metadata
- **GIVEN** required questionnaire rules or persona skill metadata is missing from the database,
- **WHEN** context loading runs,
- **THEN** the graph MUST terminate early, routing to `handle_other` and reporting a structured `prompt_not_found` error.

---

### Requirement: Registry & Route Repository Abstractions

Graph nodes SHALL depend on explicit repository interfaces for prompt resolution and model route configuration to isolate database concerns.

#### Scenario: Cache resolution
- **GIVEN** multiple requests are processed sequentially for the same survey type,
- **WHEN** prompt strings are resolved,
- **THEN** they MUST be served from an in-memory TTL repository cache to avoid querying MongoDB on every request.

---

### Requirement: Safe Transcription File Retention

Stranded audio files from interrupted containers MUST NOT violate patient data boundaries.

#### Scenario: Startup garbage collection
- **GIVEN** temporary audio files remain in `/tmp/clinical-writer-audio/` due to an ungraceful container shutdown,
- **WHEN** the FastAPI application starts up,
- **THEN** a startup hook MUST delete all files older than 30 minutes in that folder and write audit logs of the deleted files.
