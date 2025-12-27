# Project Requirements

This document outlines the functional and non-functional requirements for the Clinical Writer AI.

## Functional Requirements

1.  **Input Handling:** The system must be able to accept two types of input:
    - Plain text representing a conversation between a doctor and a patient.
    - A JSON object containing structured patient data and questionnaire answers.

2.  **Content Validation:** The system must validate all incoming text to ensure it is appropriate for processing. This includes:
    - **Sanitization:** Removing or flagging HTML/XML tags and other markup.
    - **Content Filtering:** Detecting and rejecting input containing:
        - Profanity or offensive language.
        - Irrelevant content (e.g., advertisements, spam).
        - Emojis and excessive special characters.

3.  **Input Classification:** The system must accurately classify the provided input into one of three categories:
    - `conversation`: For free-form text dialogues.
    - `json`: For inputs that are valid JSON and match the expected schema for patient data.
    - `other`: For any input that does not fit the above categories.

4.  **Medical Report Generation:**
    - **From Conversation**: If the input is a conversation, the system will use a large language model (LLM) to extract key medical information and structure it into a formal, professional medical report.
    - **From JSON**: If the input is a JSON object, the system will use the LLM to process the structured data and generate a similar medical report.

5.  **Error Handling and User Feedback:**
    - If the input is classified as `other`, the system must return a message to the user indicating that the input was not understood and suggest providing either a conversation or a valid JSON object.
    - If the input is flagged as inappropriate, the system should reject it and inform the user.
    - The system should be able to handle cases where it cannot confidently generate a report and ask for clarification from the user.

6.  **API Endpoint:**
    - All functionality must be exposed through a secure and well-documented RESTful API.
    - The primary endpoint will be `/process`, accepting a POST request with the input data.

## Non-Functional Requirements

1.  **Performance**: The system should be able to process a standard-length consultation and return a report within 10-15 seconds.
2.  **Scalability**: The architecture must be designed to be scalable, allowing for an increase in processing capacity as the user base grows. The use of containerization (Docker) will facilitate this.
3.  **Security**:
    - All API endpoints must be secured.
    - Sensitive information, such as API keys, must be managed securely and not hardcoded in the source.
    - The system must be protected against common web application vulnerabilities (e.g., OWASP Top 10).
4.  **Maintainability**: The codebase must be well-structured, modular, and well-documented to ensure it is easy to understand, modify, and extend.
5.  **Extensibility**: The system should be designed to easily accommodate new Large Language Models, updated medical ontologies, or different report formats in the future.
6.  **Reliability**: The system should be robust and handle unexpected inputs or errors gracefully without crashing.
