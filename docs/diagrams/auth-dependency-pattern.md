# FastAPI Authorization Dependency Pattern

How route authorization is enforced in survey-backend.

```mermaid
flowchart TD
    REQ([HTTP Request]) --> DEP{FastAPI Depends}

    DEP -->|Public route| PUB[No auth required<br/>Compensating controls]
    DEP -->|Screener route| RS[require_screener]
    DEP -->|Template admin| RTA[require_template_admin]
    DEP -->|Builder admin| RBA[require_builder_admin]
    DEP -->|Builder write| RBC[require_builder_csrf]
    DEP -->|Privacy admin| RPA[_assert_privacy_admin]

    RS -->|"Decode Bearer JWT"| JWT[Validate token<br/>exp, sub, purpose]
    JWT -->|valid| LOOKUP[ScreenerRepository<br/>find_by_email]
    JWT -->|invalid/expired| REJ1[401 Unauthorized]

    LOOKUP -->|found| SCR[[ScreenerModel]]
    LOOKUP -->|not found| REJ2[401 SCREENER_NOT_FOUND]

    RTA --> RS
    RTA -->|isBuilderAdmin=true| SCR
    RTA -->|isBuilderAdmin=false| REJ3[403 TEMPLATE_ADMIN_REVOKED]

    RBA -->|Cookie session| COOK[Decode session cookie]
    RBC --> RBA
    RBC -->|CSRF cookie + header match| SCR
    RBC -->|mismatch| REJ4[403 BUILDER_CSRF_INVALID]

    SCR --> HANDLER[Route handler<br/>Business logic]

    style REJ1 fill:#fee2e2,stroke:#dc2626,color:#991b1b
    style REJ2 fill:#fee2e2,stroke:#dc2626,color:#991b1b
    style REJ3 fill:#fee2e2,stroke:#dc2626,color:#991b1b
    style REJ4 fill:#fee2e2,stroke:#dc2626,color:#991b1b
    style HANDLER fill:#bbf7d0,stroke:#16a34a,color:#166534
    style PUB fill:#fef3c7,stroke:#d97706,color:#78350f
```

## Public Routes (Explicit Exceptions)

These mutating routes are intentionally public with compensating controls:

| Route | Control |
|:---|:---|
| `POST /screeners/register` | Rate limiting, schema validation |
| `POST /screeners/login` | Credential check |
| `POST /screeners/recover-password` | Rate limiting, email enumeration prevention |
| `POST /survey_responses/` | Access link token validation |
| `POST /patient_responses/` | Access link token validation |
| `POST /privacy/requests` | Rate limiting |
| `GET /screener_access_links/{token}` | Token-based resolution |
| `POST /builder/login` | Credential + admin check |

## Audit

`test_route_authorization_audit.py` dynamically inspects `app.routes` and asserts that all mutating endpoints (POST/PUT/PATCH/DELETE) have a recognized auth dependency or are listed as a public exception. New mutating routes will fail CI until protected.
