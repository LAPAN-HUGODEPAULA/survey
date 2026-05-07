## ADDED Requirements

### Requirement: Delayed and sparse polling for high-latency AI tasks
The system SHALL implement an optimized polling strategy for AI tasks that accounts for the high latency of reasoning models (~1 minute).

#### Scenario: Frontend initiates polling for complex analysis
- **WHEN** the frontend receives a `202 Accepted` response for an AI task
- **THEN** it SHALL wait at least 15 seconds before the first polling request
- **AND** subsequent polling requests SHALL occur at intervals of 10 seconds or more to reduce backend load
