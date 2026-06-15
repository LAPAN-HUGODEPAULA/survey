# Tasks

- [ ] 1. Generate a route inventory: method, path, mutating/read-only, expected principal, current dependency stack.
- [ ] 2. Classify routes into builder, screener, patient access link, public bootstrap, and internal service categories.
- [ ] 3. Implement or reuse central FastAPI dependencies for each protected class.
- [ ] 4. Move ad hoc token/header parsing into dependency functions where possible.
- [ ] 5. Mark intentional public routes in code with explicit public dependency or metadata to avoid silent exposure.
- [ ] 6. Add request tests for at least one unauthenticated and one authorized call per route class.
- [ ] 7. Rerun Skylos and suppress only findings where router-level guards are proven but not recognized by the analyzer.

## Validation

- [ ] V1. Route inventory test.
- [ ] V2. Unauthenticated mutation tests.
- [ ] V3. Skylos rerun with documented residual false positives.
