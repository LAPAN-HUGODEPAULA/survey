# clinical-writer-integration Specification

## Purpose
Define requirements for Clinical Writer integration components and report formatting reuse.

## Requirements

### Requirement: Clinical Writer Integration Components

The survey backend SHALL implement Clinical Writer integration as composable endpoint, health, run-submission, response-normalization, and formatting components.

#### Scenario: Submission success

- GIVEN a valid Clinical Writer /process response, WHEN the integration submits a report request, THEN it MUST return a typed success result with report content and relevant progress metadata.

#### Scenario: Submission failure

- GIVEN a timeout, quota error, invalid JSON, or unreachable service, WHEN the integration submits a report request, THEN it MUST return a typed failure result without leaking secrets or raw clinical payloads into logs.

### Requirement: Report Text Formatting Reuse

Report-to-text conversion SHALL be implemented once per shared backend boundary rather than duplicated across integration clients and routes.

#### Scenario: Nested report content

- GIVEN a structured report with nested sections and list values, WHEN text formatting runs, THEN output MUST be deterministic and preserve clinically relevant text without O(N^2) traversal on normal inputs.
