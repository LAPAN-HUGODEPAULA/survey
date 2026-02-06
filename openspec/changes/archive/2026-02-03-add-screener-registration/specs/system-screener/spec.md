# Specification for System Screener

## ADDED Requirements

### Requirement: Create System Screener
A default "System Screener" user MUST be created in the database.

#### Scenario: System startup
**Given** the `survey-backend` application starts
**When** the database is initialized
**Then** a "System Screener" user with the following data MUST be present in the `screeners` collection:
```json
{
   "cpf": "00000000000",
   "firstName": "LAPAN",
   "surname": "System Screener",
   "email": "lapan.hugodepaula@gmail.com",
   "password": "<randomly_generated_and_hashed>",
   "phone": "31984831284",
   "address": {
     "postalCode": "34000000",
     "street": "Rua da Paisagem",
     "number": "220",
     "complement": "",
     "neighborhood": "Vale do Sereno",
     "city": "Nova Lima",
     "state": "MG"
   },
   "professionalCouncil": {
     "type": "none",
     "registrationNumber": ""
   },
   "jobTitle": "",
   "degree": "",
   "darvCourseYear": null
}
```

### Requirement: Use System Screener in Patient App
The `survey-patient` app MUST use the "System Screener" as the default screener for all survey responses.

#### Scenario: Patient submits a survey
**Given** a patient is using the `survey-patient` app
**When** the patient submits a survey
**Then** the survey response sent to the backend MUST be associated with the "System Screener".
