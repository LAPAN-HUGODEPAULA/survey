## ADDED Requirements

### Requirement: Layered graph nodes MUST use provider-aware routing consistently
The `ClinicalAnalyzer`, `PersonaWriter`, and `ReflectorNode` MUST all use the same provider-aware routing policy so primary/fallback behavior is consistent across stages.

#### Scenario: Request runs through all graph stages
- **WHEN** a clinical writer request passes through analyzer, writer, and reflector stages
- **THEN** each stage MUST resolve LLM invocations through provider-aware primary/fallback routing

### Requirement: Reflection stage MUST use the same provider chain policy
The reflection stage MUST apply the same primary/fallback provider behavior as report generation stages.

#### Scenario: Reflector primary provider fails
- **WHEN** the reflector primary provider invocation fails
- **THEN** the reflector MUST invoke the fallback provider
- **AND** it MUST continue evaluation using the fallback response when valid
