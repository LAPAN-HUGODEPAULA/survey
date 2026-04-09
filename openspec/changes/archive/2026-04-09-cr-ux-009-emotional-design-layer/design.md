## Context

The LAPAN Survey Platform is functional (following CR-UX-001 through 008), but its current interface is perceived as technical and cold. In healthcare and clinical assessment contexts, emotional design plays a crucial role in reducing patient anxiety and increasing professional trust. This design introduces an "Ambient Empathy" layer—a performance-first approach using tone of voice, subtle personalization, and lightweight micro-interactions.

## Goals / Non-Goals

**Goals:**
- Centralize Tone of Voice management in `packages/design_system_flutter`.
- Implement frictionless personalization (names and contextual greetings) using local state.
- Introduce "Ambient Delight" (CSS/Flutter-native transitions) for positive reinforcement at success moments.
- Humanize waiting (CR-UX-005) and completion messages across all applications.
- **Maintain Performance:** Ensure emotional design adds zero extra interaction steps and negligible asset overhead.

**Non-Goals:**
- Implement complex gamification, reward systems, or heavy animation libraries (e.g., Lottie).
- Change primary colors or base visual identity.
- Modify authentication or security flows (only interface/tone).

## Decisions

### 1. Tone of Voice Tokenization (`DsToneTokens`)
- **Rationale**: Tone of voice SHALL be a governable design resource with an "Emotional Volume" parameter.
- **Implementation**: Create a `ThemeExtension` called `DsToneTokens` defining writing styles, microcopy examples, and `emotionalVolume` (0.0 to 1.0) for each profile.
  - `patient`: High volume (warm/supportive).
  - `professional`: Medium volume (competent/supportive).
  - `admin`: Low volume (precise/minimal).
- **Localization**: All strings in `DsToneTokens` MUST be in Brazilian Portuguese (pt-BR).

### 2. Emotional Tone Provider (`DsEmotionalToneProvider`)
- **Rationale**: Applications share components but need different emotional resonance.
- **Implementation**: An `InheritedWidget` allowing child components (e.g., `DsFeedback`, `DsStepper`) to adapt their language and transition speed based on the active profile's `DsToneTokens`.

### 3. "Ambient Delight" System (`DsAmbientDelight`)
- **Rationale**: Small successes are opportunities to reduce stress without adding friction ("Less is More").
- **Implementation**: Use standard Flutter `AnimatedContainer` or `ImplicitlyAnimatedWidget` (or CSS-equivalent transitions for Web) integrated into success/completion components. **Strictly no external asset dependencies.**

### 4. Frictionless Contextual Personalization
- **Rationale**: Personalization should be "felt" but not "processed" as an extra step.
- **Implementation**: Extend `DsScaffold` and `DsFeedback` to accept an optional `userName` property, injecting it into "Ambient Greetings" with friendly, gender-neutral fallbacks in pt-BR.

## Risks / Trade-offs

- **[Risk]** Performance degradation from animations. → **Mitigation**: Use only native-primitive animations (transform, opacity, color); no per-frame complex math or heavy assets.
- **[Trade-off]** Slightly more complex component logic. → **Mitigation**: Abstract tone-adaptation into a reusable mixin for shared components.
- **[Risk]** Over-familiarity in clinical contexts. → **Mitigation**: The `professional` and `admin` profiles SHALL have a lower `emotionalVolume` to prioritize efficiency.
