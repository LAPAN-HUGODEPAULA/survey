# Specification for Screener User Model

## ADDED Requirements

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
  "darvCourseYear": 2019
}
```

### Requirement: Unique CPF
The `cpf` field MUST be unique for each screener.

#### Scenario: Create a screener with a duplicate CPF
**Given** a screener with CPF "111.111.111-11" already exists
**When** a request is made to create a new screener with the same CPF
**Then** the system MUST return an error indicating that the CPF is already in use.

### Requirement: Unique Email
The `email` field MUST be unique for each screener.

#### Scenario: Create a screener with a duplicate email
**Given** a screener with email "test@example.com" already exists
**When** a request is made to create a new screener with the same email
**Then** the system MUST return an error indicating that the email is already in use.
