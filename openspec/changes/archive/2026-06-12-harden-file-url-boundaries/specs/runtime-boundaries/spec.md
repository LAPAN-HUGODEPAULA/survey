# Delta for runtime-boundaries

## ADDED Requirements

### Requirement: Safe File Write Boundary

The backend SHALL write generated files only under explicitly configured service-owned directories.

#### Scenario: Traversal rejected

- GIVEN a requested filename containing ../ or an absolute path, WHEN a generated report or transcription artifact is written, THEN the write MUST be rejected.

#### Scenario: Symlink rejected

- GIVEN a target path that resolves through a symlink outside the service-owned directory, WHEN the service attempts to write, THEN the write MUST fail safely.

### Requirement: Outbound Clinical Writer URL Policy

The survey backend SHALL call the Clinical Writer service only through validated configured origins.

#### Scenario: Disallowed target rejected

- GIVEN a configured Clinical Writer URL pointing to link-local metadata, loopback fallback not explicitly enabled, or an unsupported scheme, WHEN health probing runs, THEN no HTTP request MUST be sent.

#### Scenario: Allowed service target

- GIVEN a configured internal Clinical Writer service origin that matches policy, WHEN health probing runs, THEN the request MAY be sent with bounded timeout and safe error handling.

