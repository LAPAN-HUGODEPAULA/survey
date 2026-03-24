# Change: Clinical Narrative UI/UX System

## Why
The `clinical-narrative` app needs clear interface, interaction, and accessibility standards to support clinical conversational flows and reduce documentation friction. This proposal consolidates UX requirements and aligns the shared design system for consistent use.

## What Changes
- Define conversational UI standards, session management, and multimodal input.
- Formalize UI states and behaviors for voice (recording, preview, errors).
- Include accessibility requirements (WCAG 2.1 AA) and keyboard navigation.
- Set perceptual performance targets for the interface.
- Align shared components in `packages/design_system_flutter` with the new standards.

## Impact
- Affected specs: `clinical-chat-ui`, `clinical-session-ui`, `voice-input-ui`, `ux-accessibility`, `ux-performance`.
- Affected code: `apps/clinical-narrative/`, `packages/design_system_flutter/`.
- Related to: `add-clinical-narrative-overview` (capability `design-clinical-ui`).
