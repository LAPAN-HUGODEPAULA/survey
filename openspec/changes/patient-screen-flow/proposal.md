# Proposal for 'patient-screen-flow'

## Summary

This proposal aims to change the screen flow for the `survey-patient` application. The new flow will prioritize the survey itself, presenting it to the user before asking for any personal information. This change is intended to increase survey completion rates by reducing initial friction.

## Scope

- Implement a new welcome screen.
- Change the order of the screens to: Welcome -> Survey -> Thank You/Summary.
- The Thank You page will include a radar chart summarizing the user's answers and an option to provide personal data for a more detailed analysis.
- Conditionally show the demographics page based on user consent.
- Send survey data to the AI agent, with or without personal data, based on user's choice.

## Motivation

The current flow requires users to input personal data before answering the survey, which may discourage participation. By reversing the flow, we expect to improve the user experience and gather more survey responses, even if some users choose not to provide personal data.
