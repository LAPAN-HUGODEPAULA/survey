## ADDED Requirements
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
