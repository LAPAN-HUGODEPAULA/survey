# Proposal: Complete Survey Builder Implementation with Question Editing

## Why
The current `survey_builder` implementation only allows editing basic survey fields, which prevents administrators from creating complete, valid surveys. This proposal closes the gap by enabling full editing of instructions and questions while aligning UI/UX with the rest of the LAPAN platform.

## What Changes
- Implement UI for editing the `instructions` object of a survey.
- Implement UI for adding, removing, and editing questions and their answers.
- Enforce validation requiring at least one question and at least one answer per question.
- Align UI/UX with the platform theme (app bar color, required field indicators) and provide a clear cancel/discard flow.
