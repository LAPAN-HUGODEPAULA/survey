# Design: Screener Registration

This document outlines the architectural decisions for implementing the Screener Registration feature.

## 1. Screener User Model

A new collection `screeners` will be created in the MongoDB database. The `Screener` model will have the following structure:

```json
{
  "_id": "<ObjectId>",
  "cpf": "<string>",
  "firstName": "<string>",
  "surname": "<string>",
  "email": "<string>",
  "password": "<string>",
  "phone": "<string>",
  "address": {
    "postalCode": "<string>",
    "street": "<string>",
    "number": "<string>",
    "complement": "<string>",
    "neighborhood": "<string>",
    "city": "<string>",
    "state": "<string>"
  },
  "professionalCouncil": {
    "type": "<string>",
    "registrationNumber": "<string>"
  },
  "jobTitle": "<string>",
  "degree": "<string>",
  "darvCourseYear": "<number>"
}
```

**Field Naming Convention:**

Field names will follow the `camelCase` convention, which is a common standard in modern web development and aligns with the existing field names in the `survey-backend`'s models. This ensures consistency across the application.

**Address Fields:**

The address fields are structured to be compatible with the data returned from the ViaCEP API, which is a widely used service for Brazilian addresses. The proposed structure is:

-   `postalCode` (postal code)
-   `street` (street name)
-   `number` (street number)
-   `complement` (address complement)
-   `neighborhood` (neighborhood)
-   `city` (city)
-   `state` (state code)

This structure is flexible enough to store addresses that are not from Brazil as well.

## 2. Authentication

Authentication will be handled by the `survey-backend`.

-   **Password Encryption**: Passwords will be hashed using `bcrypt` before being stored in the database.
-   **Login**: The login endpoint will accept `email` and `password`. Upon successful authentication, a JWT (JSON Web Token) will be generated and returned to the client. This token must be sent in the `Authorization` header for all subsequent requests that require authentication.
-   **Password Recovery**: A password recovery mechanism will be implemented. When a user requests a password reset, a unique token will be generated and sent to their email address. This token will allow them to set a new password. The proposed solution is to generate a random password and send it to the user's email.

## 3. Survey and Screener Association

The `survey_responses` collection will be updated to include a reference to the `screener`. Instead of storing the screener's name and email directly in the survey response, we will store the `_id` of the screener from the `screeners` collection.

The `SurveyResponse` model will be updated to include a `screenerId` field:

```json
{
  "_id": "<ObjectId>",
  "surveyId": "<string>",
  "patientId": "<string>",
  "screenerId": "<ObjectId>",
  "responses": [...],
  "createdAt": "<datetime>"
}
```

This change will allow us to easily query for all surveys administered by a specific screener.

## 4. System Screener

A default "System Screener" will be created in the database. This user will be used by the `survey-patient` app, which does not have a logged-in screener. The "System Screener" will have a predefined `_id` so that it can be easily referenced.

The `survey-backend` will be updated to use this "System Screener" when it receives requests from the `survey-patient` app. The logic that currently reads the default screener from the `.env` file will be removed.

## 5. API Changes

The `survey-backend.openapi.yaml` file will be updated to include the following new endpoints:

-   `POST /screeners/register`: To register a new screener.
-   `POST /screeners/login`: To log in a screener.
-   `POST /screeners/recover-password`: To request a password recovery.

The existing `/survey-responses` endpoint will be updated to accept a `screenerId` instead of `screenerName` and `screenerEmail`.
