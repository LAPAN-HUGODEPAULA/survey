## ADDED Requirements

### Requirement: Backend MUST seed AI default model settings at startup
When the backend starts, it MUST ensure default AI model settings are present in `system_settings` using environment-derived values for Gemini and GLM models.

#### Scenario: Startup with missing model defaults
- **WHEN** the backend starts and AI default model keys are missing in `system_settings`
- **THEN** the backend MUST create the missing keys using `GEMINI_MODEL` and `GLM_MODEL` values

#### Scenario: Startup with existing model defaults
- **WHEN** the backend starts and AI default model keys already exist in `system_settings`
- **THEN** the backend MUST keep the existing persisted values unless an explicit refresh policy is configured
