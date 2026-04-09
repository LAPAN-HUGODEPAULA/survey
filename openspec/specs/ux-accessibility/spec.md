# ux-accessibility Specification

## Purpose
TBD - created by archiving change add-ux-design-system. Update Purpose after archive.
## Requirements
### Requirement: WCAG 2.1 AA Accessibility
The system SHALL meet WCAG 2.1 AA criteria in `clinical-narrative` screens.

#### Scenario: Contrast and legibility
- **WHEN** the user views text and controls
- **THEN** contrast meets the WCAG 2.1 AA minimum

### Requirement: Keyboard Navigation
The system SHALL allow full use of the interface with keyboard only and visible focus indicators.

#### Scenario: Focus order
- **WHEN** the user navigates with Tab and Shift+Tab
- **THEN** focus follows a logical order without traps and focus is visibly highlighted

### Requirement: Screen Reader
The system SHALL provide labels and announcements for screen readers.

#### Scenario: Dynamic content
- **WHEN** new messages or states are updated
- **THEN** the screen reader is notified appropriately with labeled controls

### Requirement: Emotional Support and Anxiety Reduction
The system SHALL provide proactive emotional support and anxiety reduction tools for clinically sensitive or high cognitive load tasks.

#### Scenario: Support Language in Sensitive Moments
- **WHEN** the user (patient or professional) is performing a stressful task
- **THEN** the system displays support messages that do not pressure for time or perfection (e.g., "Reserve o tempo que precisar para responder")

#### Scenario: Easy Access to Help and Guidance
- **WHEN** the user is in a state of persistent error or doubt
- **THEN** the system offers clear support paths or simplified guidance to regain calm and confidence

