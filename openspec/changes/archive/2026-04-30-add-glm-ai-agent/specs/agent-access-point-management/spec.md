## ADDED Requirements

### Requirement: Access-point catalog MUST persist provider and model bindings for clinical writer runtime
Each agent access point MUST persist provider/model bindings that determine which primary and fallback models are used at runtime.

#### Scenario: Admin saves access-point model settings
- **WHEN** an authorized admin creates or updates an access point with provider/model fields
- **THEN** the system MUST persist the configured provider/model bindings with the access-point record

### Requirement: Access-point resolution MUST include provider and model precedence
Runtime access-point resolution MUST include provider/model selection with precedence: request override, access-point binding, system default setting.

#### Scenario: Access point defines explicit model binding
- **WHEN** a request references an access point that includes provider/model bindings
- **THEN** the resolved runtime configuration MUST use the access-point provider/model values
- **AND** it MUST not fall back to system defaults for fields explicitly set on the access point

#### Scenario: Access point omits model binding
- **WHEN** a request references an access point without provider/model bindings
- **THEN** the system MUST resolve missing fields from system default settings
