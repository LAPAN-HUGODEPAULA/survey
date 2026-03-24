## Context
The `clinical-narrative` interface needs consistent conversational patterns and a reusable component set to reduce visual variation and improve clinical efficiency. The proposal influences the shared design system to ensure consistency across screens and states.

## Goals / Non-Goals
- Goals:
  - Define UI requirements for conversation, session, and voice.
  - Ensure accessibility (WCAG 2.1 AA) and keyboard navigation.
  - Set perceptual performance targets for the interface.
  - Standardize components and states in `design_system_flutter`.
- Non-Goals:
  - Define a fixed color palette or typography.
  - Redesign apps outside `clinical-narrative`.

## Decisions
- Decision: Split capabilities by domain (chat, session, voice, accessibility, performance).
  - Rationale: Enables incremental evolution and avoids monolithic requirements.
- Decision: Reusable components must exist in the design system.
  - Rationale: Reduces duplication and ensures consistent states.

## Alternatives Considered
- Keep requirements only in the app: rejected due to increased divergence between screens and components.

## Risks / Trade-offs
- Risk: Design system complexity from supporting many states.
  - Mitigation: Well-defined and documented variants.

## Migration Plan
1. Specify components and states in the design system.
2. Implement `clinical-narrative` UI with those components.
3. Validate accessibility and performance.

## Open Questions
- Which message and history limits should the UI support.
- Which keyboard shortcuts are required initially.
