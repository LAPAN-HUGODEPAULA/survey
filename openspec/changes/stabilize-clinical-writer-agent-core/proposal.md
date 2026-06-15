# Change: stabilize-clinical-writer-agent-core

## Why

The Clinical Writer API implements a domain-critical AI workflow. Refactoring should preserve the 4-stage graph contract while isolating configuration, prompt resolution, model routing, monitoring, and retention policies.

## What Changes

- Clarify graph construction and stage interfaces.
- Extract prompt/persona registry access from graph nodes.
- Separate model routing from MongoDB access and LLM provider construction.
- Consolidate monitoring hooks and error handling.
- Revisit retention file handling in coordination with runtime-boundaries.

## Scope

services/clinical-writer-api/clinical_writer_agent/** excluding generated artifacts and broad prompt content changes.

## Impact

- Affected capability: `clinical-writer-agent`
- Refactor leverage: Medium-high
- Confidence: High for quality/architecture findings, medium on exact refactor boundaries until source is inspected
- Expected implementation style: focused PR, preserve external behavior unless the spec explicitly changes it.

## Evidence From Skylos v1

- Clinical-writer quality findings cluster around agent_graph.py, context_loader_agent.py, clinical_analyzer_agent.py, persona_writer_agent.py, layered_node_utils.py, prompt_registry.py, base_monitors.py, metrics_monitor.py, logging_monitor.py, and transcription_retention.py.
- Architecture rows mark multiple clinical_writer_agent modules as zone_of_pain, including agent_config, analysis/report/transcription models, monitoring, prompts, prompt_registry, transcription_retention, and agent_state.
- AGENTS.md defines the intended 4-stage Clinical Writer pattern: ContextLoader -> ClinicalAnalyzer -> PersonaWriter -> ReflectorNode.

## Non-Goals

- Do not perform unrelated formatting churn.
- Do not change API contracts unless a task explicitly requires OpenAPI/spec updates.
- Do not suppress findings without documenting whether they are generated noise, first-party import context, test-only scope, or proven false positives.
