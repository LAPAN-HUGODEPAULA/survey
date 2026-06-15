# global-ai-governance Specification

## Purpose
Define the requirements for global AI governance and configuration hierarchy across all LAPAN platform services.

## Requirements

### Requirement: Centralized Global AI Configuration
The system SHALL maintain a global configuration for AI model defaults that applies when no specific override exists at the Access Point level.

#### Scenario: Admin updates global AI model
- **WHEN** an authorized admin updates the Primary Model in the "Configurações Globais" screen
- **THEN** all subsequent AI requests that do not have an explicit model override MUST use the new global model
- **AND** the system MUST persist this change as a singleton Mongo document using `aiConfig` fields

### Requirement: Configuration Hierarchy for AI Models
The system MUST resolve AI configuration using the following priority:
1. Request-level payload overrides (e.g. manual API test).
2. Agent Access Point specific configuration.
3. Global AI Configuration (from MongoDB).
4. Environment variables / System defaults (last resort).

#### Scenario: Access Point lacks configuration
- **WHEN** a request uses an Access Point that has "Global Default" selected for its model
- **THEN** the system MUST fetch and apply the model from the Global AI Configuration

### Requirement: Global and Access Point configuration MUST share one schema
The platform MUST represent AI settings with a single `aiConfig` structure across global settings, access points, and runtime payloads.

#### Scenario: Runtime builds effective AI configuration
- **WHEN** the backend computes effective AI parameters for a request
- **THEN** it MUST use only `aiConfig` fields (`primaryProvider`, `primaryModel`, `fallbackProvider`, `fallbackModel`, `temperature`, `reasoningEffort`, `enableCaching`)
- **AND** it MUST NOT rely on retired flat fields (`aiProvider`, `glmModel`, `geminiModel`)
