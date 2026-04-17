## ADDED Requirements

### Requirement: Administrative navigation MUST reduce dead ends and context loss
The `survey-builder` navigation model MUST prevent dead-end administrative screens and MUST preserve user orientation during long-lived catalog and editor workflows.

#### Scenario: Admin opens a secondary catalog
- **WHEN** an admin navigates from the survey area into a secondary catalog such as prompts or persona skills
- **THEN** the destination screen MUST show its current section clearly
- **AND** it MUST provide visible actions to return to the parent context or the administrative home

#### Scenario: Admin completes a save inside a nested editor
- **WHEN** an admin saves changes from a nested prompt, persona, or survey editor
- **THEN** the post-save state MUST preserve orientation by showing the current section and available next navigation choices
- **AND** the user MUST not land in a screen that lacks a clear onward path
