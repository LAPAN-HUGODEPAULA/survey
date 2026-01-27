# Tasks for 'patient-screen-flow'

## Frontend Development Tasks

- [x] **Create the new Welcome Screen.**
  - Design and implement the UI for the welcome screen.
  - Add a call-to-action button to start the survey.
- [x] **Rearrange the screen flow.**
  - Modify the application's navigation to follow the new flow: Welcome -> Survey -> Thank You.
- [x] **Update the Thank You screen.**
  - Implement the UI to show a summary of the user's answers.
  - Integrate a radar chart to visualize the answers.
  - Add a section with a call-to-action to provide personal information for a more detailed analysis.
- [x] **Create the new Report Page.**
  - Design and implement the UI for the report page.
  - The page should display the AI agent's response.
  - The content of the report must be selectable.
  - Add a button to save the report as a plain text file.
  - Add a button to export the report as a PDF.
- [x] **Implement conditional logic for the demographic page.**
  - Show the demographic page only if the user consents to provide personal information.
- [x] **Modify the data submission logic.**
  - If the user provides personal data, send the survey data along with the personal data to the AI agent.
  - If the user refuses, send only the survey data to the AI agent.
  - Navigate to the new report page with the AI agent's response.

## Backend Development Tasks

- [x] **Update API Contract:** Modify `survey-backend.openapi.yaml` to make the `patient` field in `SurveyResponse` optional.
- [x] **Update Pydantic Model:** Change the `SurveyResponse` model in `services/survey-backend/app/domain/models/survey_response_model.py` to make the `patient` field optional.
- [x] **Adjust Backend Logic:** Update the `create_survey_response` endpoint and any other relevant logic to handle survey responses with or without patient data.
- [x] **Database:** Ensure that the database schema can handle null values for patient data.

## Testing Tasks

- [x] **Frontend:** Write unit and integration tests for the new flow and components.
- [x] **Backend:** Add new test cases for survey submission with and without patient data.
- [x] **End-to-End:** Test the new screen flow from end-to-end.
- [x] **Report Page:** Verify the new report page functionality (selectable content, text export, PDF export).
- [x] **Data Validation:** Validate the radar chart visualization and verify that the data is sent correctly to the AI agent in both scenarios.
