# builder-admin-audit-events Specification

## Purpose
Define the requirements for capturing and preserving administrative audit events
originating from the `survey-builder` application and its associated backend
services. These events provide a verifiable record of configuration changes,
administrative access, and security-relevant outcomes for clinical governance
and incident response.

## Requirements

### Requirement: Builder administrative actions MUST emit persistent audit events
Every privileged `survey-builder` operation MUST produce a persistent audit event written by the backend. This includes successful and failed create, update, delete, publish, login, logout, and authorization-denied actions.

#### Scenario: Admin updates a questionnaire prompt
- **WHEN** an authorized builder admin updates a questionnaire prompt through the backend API
- **THEN** the system MUST persist an audit event for that action
- **AND** the event MUST record at least the actor identity, action type, target resource identifier, timestamp, correlation id, and outcome

#### Scenario: Unauthorized builder action is denied
- **WHEN** a builder-managed request is rejected because the screener lacks builder-admin authorization
- **THEN** the system MUST persist an audit event for the denied action
- **AND** the event MUST identify the attempted target and the denial outcome without exposing protected resource content

### Requirement: Builder audit records MUST be append-only and queryable by governance keys
The builder audit store MUST preserve audit entries as append-only records and MUST support retrieval by actor, resource type, resource id, action type, timeframe, and correlation id.

#### Scenario: Investigator traces a configuration change
- **WHEN** an authorized operator investigates a prompt or survey configuration incident
- **THEN** the audit records MUST allow filtering by the affected resource id and timeframe
- **AND** the sequence of matching events MUST show who performed each recorded action and whether it succeeded or failed
