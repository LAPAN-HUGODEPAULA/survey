## Context

`survey-builder` is moving from a convenience editor to the operational control plane for surveys, prompts, persona skills, output profiles, and future agent access points. That makes its writes security-relevant and compliance-relevant. Today those actions are not captured in a dedicated persistent audit trail, which creates gaps for LGPD traceability, incident investigation, and basic change accountability.

The platform already has general audit and privacy specifications, but builder administration needs a more concrete event taxonomy and retention policy because it deals with configuration that can indirectly affect patient-facing clinical narratives. The design must distinguish between operational observability logs and protected audit records, minimize stored content, and ensure the backend is the source of truth for what happened.

## Goals / Non-Goals

**Goals:**
- Persist an append-only audit trail for privileged builder actions and authorization events.
- Record enough metadata to answer who changed what, when, from where, and with what outcome.
- Keep PHI, raw secrets, and large prompt bodies out of the audit payload unless explicitly required for governance.
- Ensure builder UI actions are auditable only through backend-mediated operations, not local-only state transitions.
- Define retention and access constraints aligned with LGPD and internal operational needs.

**Non-Goals:**
- Building a full audit-log review UI in this change.
- Capturing generic low-value telemetry such as every scroll, focus event, or local draft keystroke.
- Replacing infrastructure logs or application metrics.

## Architectural Decisions

### 1. Decorator Pattern for Audit Recording
**Decision**: Use `@audit_builder_operation` decorator for explicit, adaptable audit recording.

```python
@audit_builder_operation("create_survey")
@router.post("/surveys/")
async def create_survey(...):
    # Business logic only - audit handled by decorator
    return repo.create(...)

@audit_builder_operation("create_prompt") 
@router.post("/survey_prompts/")
async def create_survey_prompt(...):
    return repo.create(...)
```

**Why**:
- Explicit control over what gets audited
- Self-documenting with operation names
- Easy to test and maintain
- No risk of missing audit on new endpoints

**Alternatives considered**:
- Centralized middleware: Rejected because less explicit and harder to debug
- Manual audit calls: Rejected because error-prone and verbose

### 2. Correlation ID Middleware with Request State
**Decision**: Simple middleware that injects correlation ID into request state.

```python
@app.middleware("http")
async def correlation_middleware(request: Request, call_next):
    correlation_id = (
        request.headers.get("X-Request-ID")
        or f"corr_{uuid.uuid4().hex[:16]}"
    )
    
    request.state.correlation_id = correlation_id
    response = await call_next(request)
    response.headers["X-Correlation-ID"] = correlation_id
    
    return response
```

**Why**:
- Zero dependencies - just FastAPI request state
- No complex injection needed
- Available everywhere in the request lifecycle
- Client-transparent via HTTP headers

### 3. Dedicated Builder Audit Collection with Synchronization
**Decision**: Create dedicated `builder_audit` collection with synchronization to `security_audit`.

```python
class BuilderAuditLog(BaseModel):
    id: str = Field(default="", alias="_id")
    correlation_id: str = Field(..., alias="correlationId")
    namespace: str = "builder"
    event_type: str = Field(..., alias="eventType")  # builder_create_survey
    actor: ActorInfo = Field(...)
    operation: str = Field(...)  # Fine-grained operation name
    status: str = Field(...)  # success|failed
    resource: ResourceInfo = Field(...)
    outcome: dict = Field(...)
    created_at: datetime = Field(default_factory=datetime.utcnow, alias="createdAt")

class BuilderAuditService:
    async def record_event(self, event: BuilderAuditCreate):
        # Write to specialized collection
        builder_record = await self._builder_repo.create(event.model_dump())
        
        # Sync to security for platform visibility
        await self._security_service.record_event(
            event_type=f"builder_{event.operation}",
            actor=event.actor,
            target=event.resource,
            payload={"correlationId": event.correlation_id}
        )
```

**Why**:
- Optimized queries for builder-specific operations
- Clear separation of concerns
- Platform-wide visibility through synchronization
- Easier to add builder-specific features later

**Alternatives considered**:
- Single security_audit collection: Rejected because mixed event types complicate queries
- Separate collections without sync: Rejected because needed for incident response

### 4. Content-Minimized Payload Capture
**Decision**: Capture only essential data with strict minimization rules.

**Surveys** (version after only):
```python
{
    "operation": "create|update|delete_survey",
    "outcome": {
        "survey_id": "string",
        "version": "timestamp",
        "display_name": "string"
    }
}
```

**Prompts** (full capture):
```python
{
    "operation": "create|update|delete_prompt", 
    "outcome": {
        "prompt_key": "string",
        "name": "string",
        "content_digest": "sha256",
        "version": "timestamp",
        "word_count": number
    }
}
```

**Authentication** (all context):
```python
{
    "operation": "login|logout|auth_check",
    "outcome": {
        "email": "string",
        "ip_address": "string",
        "user_agent": "string", 
        "success": boolean,
        "failure_reason": "string"
    }
}
```

**Why**:
- Reduces privacy risk
- Complies with data minimization principle
- Captures enough for governance without over-collecting

## Implementation Details

### Decorator Implementation
```python
def audit_builder_operation(operation_type: str):
    def decorator(func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            request = kwargs.get('request')
            screener = kwargs.get('screener')
            
            audit_context = {
                "operation": operation_type,
                "correlation_id": request.state.correlation_id,
                "timestamp": datetime.utcnow(),
                "actor": {
                    "id": screener.id,
                    "email": screener.email
                },
                "resource": extract_resource_info(kwargs, operation_type)
            }
            
            try:
                result = await func(*args, **kwargs)
                audit_context.update({
                    "status": "success",
                    "outcome": extract_outcome(result, operation_type)
                })
            except Exception as e:
                audit_context.update({
                    "status": "failed",
                    "error": {
                        "type": type(e).__name__,
                        "message": str(e)
                    }
                })
                raise
            
            asyncio.create_task(
                security_audit_service.record_builder_event(audit_context)
            )
            
            return result
        return wrapper
    return decorator
```

### Query Optimization
```python
# Builder-specific queries
builder_audit.find({
    "resource.type": "survey", 
    "actor.id": user_id,
    "created_at": {"$gte": start, "$lte": end}
})

# Cross-collection tracing
security_audit.find({
    "eventType": {"$regex": "^builder_"},
    "payload.correlationId": correlation_id
})
```

### Index Strategy
```python
# builder_audit collection indexes
db.builder_audit.create_index([("correlation_id", 1)])
db.builder_audit.create_index([("actor.id", 1)])
db.builder_audit.create_index([("resource.id", 1)])
db.builder_audit.create_index([("created_at", -1)])
db.builder_audit.create_index([("namespace", 1), ("operation", 1)])
```

## Risks / Trade-offs

- [Risk] Overly detailed audit metadata can become a privacy liability. → Mitigation: define per-action allowlists, avoid raw payload capture, and retain only identifiers plus minimal change context.
- [Risk] Missing audit writes on failed operations would create blind spots. → Mitigation: emit audit events for both success and failure outcomes, including authorization failures.
- [Risk] Synchronous audit persistence can slow admin writes. → Mitigation: use asyncio.create_task for fire-and-forget writes; optimize indexes and schema later if needed.
- [Risk] Two collections could complicate incident response. → Mitigation: create helper service for cross-collection queries.

## Migration Plan

1. **Phase 1**: Implement correlation ID middleware and test across all builder routes
2. **Phase 2**: Create BuilderAuditLog model and repository structure
3. **Phase 3**: Implement decorator pattern on high-value endpoints (surveys, prompts)
4. **Phase 4**: Add decorators to remaining endpoints and validate completeness
5. **Phase 5**: Enable TTL indexes and document retention procedures
6. **Phase 6**: Validate against compliance requirements and test incident response

## Open Questions

- Should audit retrieval live behind a future builder UI, a backend-only admin endpoint, or an external SIEM/export path first?
- Do failed login attempts for non-admin screeners need alert thresholds in the same release, or can that remain a later security-monitoring enhancement?
- Should we add automatic redaction of sensitive patterns in prompt content beyond just using content digests?