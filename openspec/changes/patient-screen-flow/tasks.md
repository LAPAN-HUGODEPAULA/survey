# Tasks for 'patient-screen-flow'

## Development Tasks

1.  **Create the new Welcome Screen.**
    *   Design and implement the UI for the welcome screen.
    *   Add a call-to-action button to start the survey.
2.  **Rearrange the screen flow.**
    *   Modify the application's navigation to follow the new flow: Welcome -> Survey -> Thank You.
3.  **Update the Thank You screen.**
    *   Implement the UI to show a summary of the user's answers.
    *   Integrate a radar chart to visualize the answers.
    *   Add a section with a call-to-action to provide personal information for a more detailed analysis.
4.  **Implement conditional logic for the demographic page.**
    *   Show the demographic page only if the user consents to provide personal information.
5.  **Modify the data submission logic.**
    *   If the user provides personal data, send the survey data along with the personal data to the AI agent.
    *   If the user refuses, send only the survey data to the AI agent.
6.  **Write unit and integration tests for the new flow and components.**

## Validation Tasks

1.  **Test the new screen flow from end-to-end.**
2.  **Validate the radar chart visualization.**
3.  **Verify that the data is sent correctly to the AI agent in both scenarios (with and without personal data).**
