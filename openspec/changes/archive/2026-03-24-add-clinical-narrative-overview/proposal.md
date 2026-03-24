# Change: Clinical Narrative Transformation Overview

## Why
The `clinical-narrative` app currently delivers only a simple narrative generator. There is an opportunity to evolve it into a complete clinical transcription and documentation platform with a conversational interface and integrated workflow, reducing documentation time and improving record quality.

## What Changes
- Structure the application as a conversational platform with sessions, history, and clinical context.
- Add voice capture with hybrid transcription (browser preview + final server processing).
- Include clinical assistance with suggestions and gap detection.
- Generate multiple clinical document types and allow export/printing.
- Implement centralized template management with versioning.
- Strengthen security, privacy, and LGPD compliance.
- Define UI/UX guidelines focused on clinical flow and the shared design system.

## Impact
- Affected specs: `manage-chat-sessions`, `process-voice-audio`, `assist-clinical-conversation`, `generate-clinical-documents`, `manage-document-templates`, `secure-clinical-data`, `design-clinical-ui`.
- Affected code: `apps/clinical-narrative/`, `services/clinical-writer-api/`, `services/survey-backend/`, `packages/design_system_flutter/`, `packages/contracts/`.
