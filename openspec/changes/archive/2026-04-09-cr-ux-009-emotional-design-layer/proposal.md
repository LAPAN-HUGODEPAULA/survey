## Why

Currently, the LAPAN Survey Platform is functional and consistent (following the standardization in CR-UX-001 through 008), but its interface is perceived as "emotionally cold." In clinical and mental health contexts, reducing stress, increasing trust, and the perception of care are fundamental for engagement. Introducing an emotional design layer will transform the platform from a technical tool into an empathetic, respectful, and encouraging experience without adding cognitive friction or performance overhead.

## What Changes

- **App-Specific Tone Profiles:** Refine `DsFeedback` (CR-UX-001) and `DsScaffold` (CR-UX-004) to use tailored microcopy:
  - `survey-patient`: Calm, simple, and reassuring (Anxiety-reduction focus).
  - `survey-frontend`: Clear, professional, and supportive (Competence focus).
  - `survey-builder`: Precise, lightweight, and low-friction (Efficiency focus).
  - `clinical-narrative`: Clinically confident, transparent, and measured (Trust focus).
- **Ambient Micro-interactions:** Subtle, CSS-only transitions for "delight" in low-risk moments (successful save, task completion) using existing `DsStatusType` logic.
- **Frictionless Personalization:** Integrating name-based greetings into headers and feedback banners upon secure entry (CR-UX-002), using only available local state.
- **Supportive Completion & Wayfinding:** Redesigning `DsStepper` (CR-UX-004) and `DsAIProgressIndicator` (CR-UX-005) messages to acknowledge effort ("Obrigado pela sua participação") rather than just data receipt.
- **Encouragement Loops:** "Positive sycophancy" (encouragement) rules in long-duration flows, integrated into the structured feedback model (CR-UX-001).

## Efficiency & Performance Guardrails

- **"Less is More" Philosophy:** Emotional design must be "ambient" (background) rather than "interruptive" (foreground). No extra dialogs or clicks allowed solely for emotional feedback.
- **Performance-First Visuals:** Zero heavy assets (Lottie/GIFs). All delight states must be implemented via standard Flutter `AnimatedWidget` or CSS-equivalent transitions.
- **Context-Aware Volume:** High-frequency admin tasks (`survey-builder`) receive minimal "delight" to preserve efficiency, while high-anxiety journeys (`survey-patient`) receive warmer, more expressive cues.
- **Lazy Emotional Loading:** Emotional cues must not block core business logic or data fetching.

## Capabilities

### New Capabilities
- `emotional-tone-standard`: Defines guidelines for tone, vocabulary, and "ambient empathy" levels per profile.
- `user-personalization-ux`: Defines standards for the safe, performant, and empathetic use of names/history to humanize the interface.

### Modified Capabilities
- `ux-accessibility`: Expansion to include cognitive efficiency and anxiety-reduction via non-distracting design.

## Impact

- `packages/design_system_flutter`: Update `DsFeedback`, `DsStepper`, and `DsScaffold` with themeable tone and transition parameters.
- `apps/survey-patient`: Calmer, supportive journeys that reduce perceived wait times.
- `apps/survey-frontend`: Professional flows that communicate partnership and support.
- `apps/survey-builder`: Lightweight, precise experience that reduces "fear of mistake."
- `apps/clinical-narrative`: Transparent and measured AI communication that builds clinical trust.
