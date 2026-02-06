# Change: Narrative AI Conversation Engine

## Why
The clinical narrative workflow needs intelligent, context-aware assistance to reduce missing information, improve documentation quality, and surface clinical safety issues. A dedicated AI conversation engine provides these capabilities while keeping the clinician in control.

## What Changes
- Add AI-driven suggestion capabilities for missing information and follow-up questions.
- Introduce clinical context management with entity extraction and phase detection.
- Provide medical NLP processing for terminology normalization, negation, and temporal relationships.
- Surface clinical alerts for safety concerns (e.g., interactions, red flags).
- Define knowledge integration requirements for codes and clinical references.

## Impact
- Affected specs: `ai-suggestions`, `ai-context-management`, `medical-nlp-processing`, `clinical-alerts`, `knowledge-integration`.
- Affected code: `services/clinical-writer-api/`, `services/survey-backend/`, `apps/clinical-narrative/`, `packages/contracts/`.
- Parent change: `add-clinical-narrative-overview`.
