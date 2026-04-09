## Why

Currently, the LAPAN Survey Platform's empty states and error paths are often "dead ends" that are not sufficiently informative or actionable. Users frequently encounter empty screens without context or face connection failures that don't offer a clear path to recovery. Improving these states is crucial to reduce abandonment and ensure trust, especially in clinical environments with unstable connectivity. This change aligns these experiences with the **Shared Feedback (CR-UX-001)** and **Notification Governance (CR-UX-006)** standards.

## What Changes

- **Empty State Standardization**: Implementation of visual and textual patterns for screens without data using the new `DsEmptyState` component, differentiating between intentional empty states and filter-related "no results" states.
- **Offline & Connectivity Guidance**: Formalization of the offline experience using `DsMessageBanner` (CR-UX-006) to communicate connectivity status and data safety.
- **Smart Retry Pattern**: Integration of a standardized `onRetry` action within `DsFeedbackMessage` (CR-UX-001) to offer recovery paths in error containers.
- **Wayfinding Integration (CR-UX-004)**: Guidance on how to return to a safe state (e.g., Home or Dashboard) when an unrecoverable error occurs.

## Capabilities

### New Capabilities
- `empty-state-standard`: Definition of visual hierarchy, microcopy, and action patterns for empty contexts.
- `offline-retry-experience`: Rules for communication and recovery of operations failed due to connectivity issues.

### Modified Capabilities
- `error-handling`: Extension to support contextual retry actions and standardized offline state transitions.

## Impact

- `packages/design_system_flutter`: Implementation of the `DsEmptyState` widget and update to `DsFeedbackMessage` with retry support.
- All frontend apps: Refactoring of lists, dashboards, and error boundaries to use the new standardized components.
