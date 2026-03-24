# clinical-writer-prompt-resolution Specification

## Purpose
TBD - created by archiving change add-survey-ai-prompts. Update Purpose after archive.
## Requirements
### Requirement: Clinical Writer MUST resolve survey prompt keys from MongoDB before using legacy providers.

`clinical-writer-api` MUST look up survey-driven `promptKey` values in MongoDB so questionnaire-managed prompt text can be loaded without depending on Google Drive.

#### Scenario: Resolve a Mongo-backed survey prompt
- **Given** a request reaches `clinical-writer-api` with a `promptKey` stored in MongoDB
- **When** the prompt registry resolves that key
- **Then** the system MUST load the prompt text from MongoDB
- **And** it MUST expose a traceable `prompt_version` for the resolved prompt

### Requirement: Clinical Writer MUST preserve fallback prompt providers for non-migrated keys.

Mongo-backed prompt resolution MUST not break flows that still depend on Google Drive or local prompt definitions.

#### Scenario: Prompt key is not present in MongoDB
- **Given** `clinical-writer-api` receives a `promptKey` that is not stored in MongoDB
- **When** Mongo-backed lookup does not find a matching prompt
- **Then** the system MUST continue with the existing fallback provider chain
- **And** non-survey flows such as `clinical-narrative` MUST remain operational

