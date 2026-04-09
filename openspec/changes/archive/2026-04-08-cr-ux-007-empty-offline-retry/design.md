## Context

The LAPAN Survey Platform already includes the `DsFeedbackMessage` model (CR-UX-001), but it lacks native support for recovery actions (Retry) and a standardized visual for empty screens. Connectivity transitions are also not explicitly handled, leaving the user unsure of data safety during outages.

## Goals / Non-Goals

**Goals:**
- Standardize the visual and textual experience of empty states across all applications.
- Implement an explicit connectivity feedback layer (Online/Offline) using the correct banner governance.
- Provide a clear, standardized "Retry" mechanism for recoverable connection errors.
- Ensure users always have an exit path (Wayfinding) in fatal error states.

**Non-Goals:**
- Implement a fully offline database (focus is on UX guidance and simple retry).
- Replace all specific error messages (focus is on the container and generic recovery logic).

## Decisions

### 1. New Component: `DsEmptyState`
- **Rationale**: Prevent "dead ends" in the UI.
- **Visual & Functional Hierarchy**:
    1. **Illustration/Icon**: High visual weight, centered. Uses `DsStatusType.info` tonal colors or a stylized gray-scale illustration to indicate absence.
    2. **Headline**: Semi-bold text (H2/H3 level) in pt-BR. Briefly states the condition (e.g., "Nenhum paciente encontrado").
    3. **Sub-headline/Description**: Regular weight text, limited to 60-80 characters per line for readability. Provides context or instruction (e.g., "Você ainda não cadastrou pacientes. Comece adicionando o primeiro.").
    4. **Call to Action (CTA)**: A primary `DsButton` that represents the most logical next step (Wayfinding), such as "Novo Paciente".
- **Props**: `visual`, `title`, `description`, `actionLabel`, `onAction`.

### 2. Connectivity Guidance (DsMessageBanner)
- **Rationale**: Users need to know if data submission is safe.
- **Implementation**: Per CR-UX-006, a persistent `DsMessageBanner` SHALL be used at the top of the relevant section when connectivity is lost, using `warning` severity.

### 3. Integrated Retry in `DsFeedbackMessage` (CR-UX-001)
- **Rationale**: Errors without actions generate user frustration.
- **Implementation**: Update the `DsFeedbackMessage` model to support an optional `onRetry` callback. When present, the widget SHALL render a primary button with "Tentar Novamente" (pt-BR).

### 4. Smart Redirects on Unrecoverable Error
- **Rationale**: Prevent users from getting stuck in fatal states.
- **Implementation**: If a page fails to load after retries, the error state SHALL include a secondary action to "Voltar ao Dashboard" (Return to Dashboard) following CR-UX-004 hierarchy.

## Risks / Trade-offs

- **[Risk]** Redundancy with browser-level offline messages. → **Mitigation**: Use in-app banners only in critical clinical flows where data loss is a risk.
- **[Trade-off]** Complexity of managing retry states. → **Mitigation**: Standardize the UI contract first; the state management (BLoC/Provider) remains local to each app.
