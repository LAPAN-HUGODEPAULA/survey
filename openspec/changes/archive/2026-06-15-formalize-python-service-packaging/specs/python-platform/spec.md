# Delta for python-platform

## ADDED Requirements

### Requirement: Service Dependency Manifest

Each backend service SHALL declare its runtime and development dependencies in a uv-managed manifest or workspace member.

#### Scenario: Runtime import declared

- GIVEN a production module imports a third-party package, WHEN dependency validation runs, THEN the package MUST be declared in that service runtime dependency set.

#### Scenario: Test import declared as dev

- GIVEN a test module imports pytest or test-only tools, WHEN dependency validation runs, THEN the package MUST be declared as a development dependency and not required by production runtime images.

### Requirement: First-Party Import Classification

Static analysis SHALL classify app and clinical_writer_agent as first-party imports for their owning services.

#### Scenario: Local app import

- GIVEN survey-backend imports app.*, WHEN static analysis runs from the repository or services root, THEN app MUST NOT be reported as a third-party package to install.

#### Scenario: Local clinical writer import

- GIVEN clinical-writer-api tests import clinical_writer_agent.*, WHEN static analysis runs, THEN clinical_writer_agent MUST NOT be reported as a hallucinated PyPI dependency.

