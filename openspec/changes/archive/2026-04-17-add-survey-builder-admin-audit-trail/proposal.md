## Why

The `survey-builder` is becoming the central administrative surface for prompt and survey governance, which means its actions must be traceable for security, debugging, and LGPD compliance. Today there is no dedicated persistent audit trail for builder-originated admin actions.

## What Changes

### Implementation Architecture
- **Decorator Pattern**: Use `@audit_builder_operation` decorator for explicit, adaptable audit recording across all builder admin endpoints
- **Correlation ID System**: Automatic generation and propagation via middleware to trace related operations across session flows
- **Storage Strategy**: Dedicated `builder_audit` collection with synchronization to `security_audit` for platform-wide visibility

### Audit Coverage
- **Authentication**: Login, logout, session validation, and auth failures with complete context (email, IP, user agent, success/failure)
- **Survey Management**: Create, update, delete operations with version tracking
- **Survey Prompts**: Full capture including content digest, name, and version
- **Persona Skills**: Create, update, delete operations
- **Agent Access Points**: Create, update, delete with complex validation tracking
- **Authorization Events**: CSRF failures and permission denials

### Data Model
- **Structured Events**: Separate `operation`, `resource`, and `outcome` fields for each action
- **Actor Tracking**: Always capture screener ID and email
- **Correlation**: Link all related operations via `correlation_id`
- **Content Minimization**: Redact PHI; capture prompt content digests instead of raw text
- **Integrity**: Hash chaining for audit record security

### Compliance & Operations
- **Retention**: 90-day TTL with secure access policies
- **Query Optimization**: Dedicated indexes for correlation, actor, and resource tracking
- **Incident Response**: Cross-collection tracing for full workflow visibility
- **LGPD Alignment**: Minimal data capture with clear audit purposes

## Capabilities

### New Capabilities
- `builder-admin-audit-events`: Persistent audit model and event taxonomy for `survey-builder` administration with:
  - Structured recording via decorator pattern
  - Correlation ID propagation for tracing
  - Dedicated storage with synchronization
  - Content-minimized payload capture

### Modified Capabilities
- `audit-logging-monitoring`: Extend the platform audit trail to include builder-originated administrative actions with cross-collection synchronization
- `data-privacy-governance`: Define LGPD-aligned retention, minimization, and access rules for builder audit data
- `frontend-survey-builder`: Ensure privileged UI actions emit backend-audited operations rather than local-only state changes

## Impact

- Affected apps: `apps/survey-builder`
- Affected backend areas: audit repositories, admin routes, security logging, middleware
- Affected storage: new dedicated `builder_audit` collection with synchronization to `security_audit`
- Dependencies: authenticated builder sessions, correlation id middleware, secure audit access policy

## Implementation Roadmap

1. **Phase 1 - Correlation ID Infrastructure**
   - Implement correlation ID middleware
   - Add automatic ID generation and propagation
   - Update all builder routes to use request state

2. **Phase 2 - Decorator Pattern**
   - Create `@audit_builder_operation` decorator
   - Start with high-value endpoints (surveys, prompts)
   - Extract operation-specific audit context

3. **Phase 3 - Storage System**
   - Implement dedicated `BuilderAuditLog` model
   - Create `BuilderAuditRepository` with sync to `security_audit`
   - Add indexes for performance optimization

4. **Phase 4 - Integration & Validation**
   - Add decorators to all builder endpoints
   - Test cross-collection tracing
   - Validate retention policies