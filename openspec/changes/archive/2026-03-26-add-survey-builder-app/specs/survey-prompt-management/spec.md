# Spec: Survey Prompt Management

This spec updates reusable survey prompt management for the single-prompt-per-questionnaire model.

## MODIFIED Requirements

### Requirement: The system MUST provide a reusable survey prompt catalog.

Reusable survey prompts MUST be stored in MongoDB and exposed through application APIs so administrators can create, edit, list, and remove prompt definitions without relying on Google Drive documents.

The catalog remains necessary because surveys still reference reusable prompts by key, but prompt definitions no longer need prompt types because questionnaires do not expose multiple prompt outcomes anymore.

#### Scenario: Create a reusable survey prompt
- **Given** an administrator is managing prompts for questionnaire reporting
- **When** they create a prompt with a human-readable name, a unique `promptKey`, and prompt text
- **Then** the system MUST persist the prompt in MongoDB
- **And** it MUST return the stored prompt definition through the API

#### Scenario: List reusable survey prompts
- **Given** reusable survey prompts exist in the system
- **When** the builder application requests the prompt catalog
- **Then** the system MUST return the stored prompt definitions with their names and keys

### Requirement: Survey prompt definitions MUST use a stable runtime key and required prompt content.

The system MUST enforce a stable, code-safe `promptKey`, a non-empty human-readable `name`, and non-empty prompt text.

This is required because prompt identity and content still matter at runtime, while `outcomeType` no longer describes any supported user-facing behavior.

Each prompt definition MUST have a unique `promptKey` suitable for use in code and runtime requests.

#### Scenario: Reject a duplicate prompt key
- **Given** a prompt already exists with a given `promptKey`
- **When** another prompt is created or updated to use the same `promptKey`
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject an empty prompt definition
- **Given** an administrator submits a prompt definition
- **When** the `name` or prompt text is blank
- **Then** the system MUST reject the request with a validation error

#### Scenario: Reject legacy prompt type metadata
- **Given** a client submits `outcomeType` as part of a reusable survey prompt definition
- **When** the API validates the request
- **Then** the system MUST reject the request as using an unsupported prompt field
