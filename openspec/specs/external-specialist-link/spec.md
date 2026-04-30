# external-specialist-link Specification

## Purpose
Integration of a link to the external Irlen Syndrome GPT on the survey-patient thank-you page.

## Requirements
### Requirement: Thank-you page MUST include an external specialist link section
The thank-you page SHALL display a `DsSection` titled "Converse com o especialista" with a link to an external Irlen Syndrome GPT.

#### Scenario: User views the specialist link section
- **WHEN** the user is on the thank-you page
- **THEN** the page MUST display a section titled "Converse com o especialista"
- **AND** the section MUST include explanatory text stating this GPT is an external LAPAN project focused on visual distress and learning
- **AND** the section MUST mention it can provide useful tips for visual sensitivity problems
- **AND** the section MUST include a button or link that opens `https://chatgpt.com/g/g-699b668db91c8191877e65ba10726cd2-irlen-syndrome-for-teachers-and-educators` in a new browser tab

#### Scenario: User taps the external link
- **WHEN** the user taps the GPT link button
- **THEN** the URL MUST open in a new browser tab or window
- **AND** the current survey app MUST remain open
