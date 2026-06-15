# Tasks

- [ ] 1. Characterize current behavior with tests for success, fallback, quota, timeout, non-JSON, and partial report responses.
- [ ] 2. Extract ClinicalWriterEndpointResolver from _candidate_process_endpoints and URL validation policy.
- [ ] 3. Extract ClinicalWriterHealthClient from health and status probing.
- [ ] 4. Extract ClinicalWriterRunClient from send_to_langgraph_agent request/response flow.
- [ ] 5. Extract AgentResponseNormalizer from _normalize_agent_response and related branches.
- [ ] 6. Extract ReportTextFormatter and remove repeated nested-loop text conversion.
- [ ] 7. Replace raw dict return shapes with typed result models or Pydantic models at boundaries.
- [ ] 8. Update tests and rerun complexity scan.

## Validation

- [ ] V1. Existing clinical writer client tests pass.
- [ ] V2. New unit tests for each extracted component.
- [ ] V3. Skylos complexity for send_to_langgraph_agent is eliminated because the function no longer exists or is a small orchestrator.
