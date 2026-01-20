# Design for 'patient-screen-flow'

## Screen Flow

The new screen flow for the `survey-patient` application is designed to be more inviting and to reduce friction for the user.

1.  **Welcome Screen**:
    *   This will be the new entry point for the user.
    *   It will contain a brief explanation of the survey and a clear "Start Survey" button.

2.  **Survey Screen**:
    *   This screen will contain the 7-question survey.
    *   The user will navigate through the questions as they do now.

3.  **Thank You / Summary Screen**:
    *   After completing the survey, the user will be taken to this screen.
    *   It will display a summary of their answers.
    *   A radar chart will be used to provide a visual representation of the answers.
    *   Below the summary, there will be a section that explains the benefits of providing personal information (e.g., a more detailed analysis) and two buttons: "Add Information" and "Continue".

4.  **Demographic Information Screen**:
    *   This screen will only be shown if the user clicks "Add Information" on the Thank You screen.
    *   It will be the same demographic information screen that is currently in use.

5.  **Report Screen**:
    *   After the user provides demographic information (or clicks "Continue" on the Thank You screen), the application will submit the data to the AI agent and navigate to this new screen.
    *   It will display the formatted response from the AI agent.
    *   The content will be selectable for copy and paste.
    *   It will have two buttons: "Save as Text" and "Export as PDF".

## Radar Chart

The radar chart on the Thank You / Summary screen will provide a visual summary of the user's survey responses.

*   **Vertices**: Each vertex of the radar chart will represent one of the questions in the survey.
*   **Values**: The value at each vertex will correspond to the user's answer to that question. The values should be normalized to fit the chart's scale (e.g., 0 to 5).
*   **Appearance**: The chart will be styled to match the application's design system. The area inside the vertices will be filled with a semi-transparent color.

## Report Page

The report page will be responsible for displaying the AI agent's response.

*   **Content**: The page will use the `ReportView` widget from the `design_system_flutter` package, similar to the current `thank_you_page.dart`. This ensures the content is selectable.
*   **Save as Text**: This button will trigger a download of the report as a plain text file. It will use the `toPlainText()` method of the `ReportDocument` model.
*   **Export as PDF**: This button will trigger the browser's print functionality on the web, allowing the user to save the report as a PDF. On native platforms, it would trigger a share/save dialog.
