# Change: Chat Core Infrastructure for Clinical Narrative

## Why

The current `clinical-narrative` experience lacks foundational chat infrastructure. Establishing session, message, and conversation flow capabilities is required before higher-level features (voice, templates, AI assistance) can be delivered reliably.

## What Changes

- Define session lifecycle, persistence, and recovery for consultations.
- Introduce a structured message system with types, metadata, and actions.
- Establish turn-based conversation flow, context management, and phases.
- Provide core input methods (text, voice toggle, quick actions).
- Set baseline reliability expectations (offline handling, recovery, data integrity).

## Impact

- Affected specs: `chat-session-management`, `chat-message-system`, `chat-conversation-flow`, `chat-input-methods`, `chat-reliability`.
- Affected code: `apps/clinical-narrative/`, `services/clinical-writer-api/`, `services/survey-backend/`, `packages/contracts/`.
- Parent change: `add-clinical-narrative-overview`.
