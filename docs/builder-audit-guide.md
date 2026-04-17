# Survey Builder Audit Trail Guide

## Overview

The Survey Builder includes a comprehensive audit trail that tracks all administrative actions performed by privileged users. This audit system ensures traceability for security, debugging, and LGPD compliance.

## Architecture

### Core Components

1. **Audit Middleware** - Automatically generates and propagates correlation IDs
2. **Audit Decorators** - Decorators for instrumenting builder operations
3. **Audit Service** - Central service for recording audit events
4. **Privacy Service** - Enforces data minimization and content redaction
5. **Audit Repository** - Manages persistent audit records

### Audit Storage

- **Primary Collection**: `builder_audit` - Optimized for builder-specific queries
- **Secondary Collection**: `security_audit` - Platform-wide visibility with synchronization
- **Retention**: 90-day automatic cleanup with TTL indexes

## Event Types

### Authentication Events
- `builder_login_auth` - Login attempts (success/failure)
- `builder_logout_auth` - Logout events

### Survey Operations
- `builder_create_survey` - New survey creation
- `builder_update_survey` - Survey modifications
- `builder_delete_survey` - Survey deletions

### Prompt Operations
- `builder_create_prompt` - New prompt creation
- `builder_update_prompt` - Prompt modifications  
- `builder_delete_prompt` - Prompt deletions

### Authorization Events
- `builder_auth_denied` - Failed authorization attempts

## Using the Audit System

### 1. Correlation ID Tracking

The correlation ID middleware automatically:
- Generates unique IDs for each request chain
- Propagates via `X-Request-ID` header
- Stores in request.state for easy access

```python
# In route handlers
correlation_id = request.state.correlation_id
```

### 2. Using Audit Decorators

Apply decorators to builder routes:

```python
from app.api.decorators.builder_audit import audit_builder_operation

@router.post("/survey_prompts/")
@audit_builder_operation("create_prompt")
@Depends(require_builder_csrf)
async def create_survey_prompt(
    prompt: SurveyPromptUpsert,
    repo: SurveyPromptRepository = Depends(get_survey_prompt_repo),
    correlation_id: CorrelationID,
) -> SurveyPrompt:
    return repo.create(prompt.model_dump(by_alias=True))
```

### 3. Custom Audit Events

For operations not covered by decorators:

```python
from app.services.builder_audit import BuilderAuditService

await BuilderAuditService.record_event(
    correlation_id=correlation_id,
    event_type="builder_custom_operation",
    actor=ActorInfo(id=screener.id, email=screener.email),
    operation="custom_operation",
    status="success",
    resource=resource_info,
    outcome=operation_outcome
)
```

## Privacy and Data Minimization

### Content Rules

- **Surveys**: Captures ID, version, display name - no raw content
- **Prompts**: Captures digest, name, word count - not full text
- **Authentication**: Captures email, IP, user agent - no sensitive tokens
- **PII**: Automatically detected and flagged

### Access Control

Only users with specific roles can access audit records:
- `admin` - Full access
- `security_officer` - Security-focused access
- `compliance_officer` - Compliance-focused access

Access is logged when audit records are retrieved.

## Querying Audit Records

### Correlation Tracing

Find all events in a workflow:

```python
# Get builder records for a correlation ID
trace = await BuilderAuditService.get_correlation_trace("corr_abc123")
```

### Actor-Based Queries

Find all actions by a specific user:

```python
# List all audit records for a screener
records = await builder_repo.list_by_actor(user_id)
```

### Resource-Based Queries

Find all actions affecting a specific resource:

```python
# Find all operations on a specific survey
records = await builder_repo.list_by_resource("survey", survey_id)
```

## Incident Response

### Investigation Workflow

1. **Identify**: Get correlation ID from affected resource
2. **Trace**: Retrieve full event chain using correlation ID
3. **Analyze**: Review sequence of operations and outcomes
4. **Validate**: Cross-check with security audit events if needed

### Example Investigation

```python
# Example: Survey shows unexpected changes
correlation_id = "workflow_123"

# Get builder events
builder_events = await builder_repo.list_by_correlation_id(correlation_id)

# Format for investigation
for event in builder_events:
    print(f"{event.created_at}: {event.operation} by {event.actor.email}")
    print(f"Status: {event.status}")
    if event.outcome:
        print(f"Outcome: {event.outcome}")
```

## Compliance Features

### LGPD Alignment

- **Purpose Limitation**: Audit data only for governance and security
- **Data Minimization**: No PHI or sensitive content stored
- **Retention**: 90-day retention period
- **Access Control**: Role-based access with audit logging
- **Right to Erasure**: Automated cleanup after retention period

### Privacy Report

Generate privacy compliance report:

```python
from app.services.audit_privacy import AuditPrivacyService

report = AuditPrivacyService.generate_privacy_report()
print(report["compliance_status"]["lgpd_compliant"])
```

## Testing

### Running Tests

```bash
pytest services/survey-backend/tests/test_builder_audit.py -v
```

### Test Coverage

- Audit event recording
- Content minimization
- Correlation ID propagation
- Failure scenarios
- Privacy rules

## Best Practices

### 1. Always Use Decorators

Apply `@audit_builder_operation` to all builder endpoints to ensure complete coverage.

### 2. Capture Correlation IDs

Always pass correlation ID to audit service calls for proper tracing.

### 3. Follow Data Minimization

Only capture essential data - use privacy service to sanitize payloads.

### 4. Handle Failures Gracefully

Don't let audit failures break your operations. Use fire-and-forget pattern.

### 5. Monitor Audit System

Regularly check audit statistics for anomalies or volume spikes.

## Troubleshooting

### Missing Audit Events

1. Check if decorator is applied
2. Verify correlation ID is available
3. Confirm service is properly injected

### Performance Issues

1. Ensure indexes are created
2. Check for slow queries
3. Consider batching bulk operations

### Privacy Concerns

1. Review content minimization rules
2. Check for PII in stored outcomes
3. Validate access controls

## Future Enhancements

- Real-time audit streaming
- Automated alerting for suspicious patterns
- Advanced search and filtering UI
- Integration with SIEM systems