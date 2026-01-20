# Proposal for 'patient-screen-flow'

## Summary

This proposal aims to change the screen flow for the `survey-patient` application. The new flow will prioritize the survey itself, presenting it to the user before asking for any personal information. This change is intended to increase survey completion rates by reducing initial friction. This proposal also includes the necessary backend changes to support submitting surveys without patient data.

## Scope

### Frontend
- Implement a new welcome screen.
- Change the order of the screens to: Welcome -> Survey -> Thank You/Summary.
- The Thank You page will include a radar chart summarizing the user's answers and an option to provide personal data for a more detailed analysis.
- Add a new report page to display the AI agent's response. The report content must be selectable, and the page must have buttons to export the report as a plain text file and as a PDF.
- Conditionally show the demographics page based on user consent.
- Send survey data to the AI agent, with or without personal data, based on user's choice, and display the result on the new report page.

### Backend
- **API Contract:** Update `survey-backend.openapi.yaml` to allow optional `patient` in the `SurveyResponse` schema.
- **Pydantic Models:** Modify the `SurveyResponse` model in `services/survey-backend/app/domain/models/survey_response_model.py` to make the `patient` field optional.
- **Database Schema:** Ensure MongoDB schema for survey responses accommodates null `patient` data.
- **Validation Logic:** Adjust backend validation to permit survey responses without patient data.
- **Test Cases:** Add new test cases for survey submission with and without patient data.

## Motivation

The current flow requires users to input personal data before answering the survey, which may discourage participation. By reversing the flow, we expect to improve the user experience and gather more survey responses, even if some users choose not to provide personal data. The new report page will provide a clear and actionable summary of the AI agent's analysis.
