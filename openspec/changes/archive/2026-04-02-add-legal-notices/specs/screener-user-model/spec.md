## MODIFIED Requirements

### Requirement: Screener User Schema
The system MUST provide a schema for `Screener` users in the database.

#### Scenario: Create a new screener
**Given** a request to create a new screener with valid data
**When** the screener is saved to the database
**Then** the screener document MUST conform to the following structure:
```json
{
  "cpf": "11111111111",
  "firstName": "Maria",
  "surname": "Henriques Moreira Vale",
  "email": "maria.vale@holhos.com",
  "password": "<hashed_password>",
  "phone": "31988447613",
  "address": {
    "postalCode": "27090639",
    "street": "Praça da Liberdade",
    "number": "932",
    "complement": "",
    "neighborhood": "Copacabana",
    "city": "Uberlândia",
    "state": "MG"
  },
  "professionalCouncil": {
    "type": "CRP",
    "registrationNumber": "12543"
  },
  "jobTitle": "Psychologist",
  "degree": "Psychology",
  "darvCourseYear": 2019,
  "initialNoticeAcceptedAt": null
}
```

#### Scenario: Persist a screener that already accepted the initial notice
- **WHEN** the system stores or reads a screener record after the platform initial notice was accepted
- **THEN** the screener document MUST keep `initialNoticeAcceptedAt`
- **AND** the field MUST store the acknowledgement date and time in a consistent datetime format
