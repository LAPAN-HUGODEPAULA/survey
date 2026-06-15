# Delta for backend-auth

## ADDED Requirements

### Requirement: Mutating Route Authorization

Every survey-backend mutating route SHALL declare an explicit authorization policy or an explicit public-route exception.

#### Scenario: Unauthenticated mutation rejected

- GIVEN a protected mutating route, WHEN a request has no valid principal, THEN the route MUST reject the request before business logic executes.

#### Scenario: Public exception documented

- GIVEN a mutating route intentionally used for public onboarding or password recovery, WHEN the route is declared, THEN it MUST include an explicit public exception and compensating controls such as rate limiting, token validation, or scoped payload validation.

### Requirement: Route Auth Inventory

The backend SHALL maintain a testable inventory of route authorization requirements.

#### Scenario: Inventory drift

- GIVEN a new mutating route is added, WHEN route authorization tests run, THEN the route MUST fail the inventory check unless it has an assigned authorization class.

