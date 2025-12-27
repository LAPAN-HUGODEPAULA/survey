# API Documentation

## `POST /process`

This is the main endpoint for processing clinical data and generating a medical report.

**Request Body:**

* `content` (string, required): The input data. This can be either a plain text string containing a doctor-patient conversation or a JSON string representing structured patient data. The value cannot be empty or whitespace-only.

**Authentication (optional but recommended):**

If an `API_TOKEN` environment variable is set on the server, requests must include:

* Header `Authorization: Bearer <API_TOKEN>`

**Example Request:**

```json
{
  "content": "Patient: I've been having severe headaches for a week. Doctor: Can you describe the pain?"
}
```

**Responses:**

* **200 OK:**
  * **Description:** The request was successful, and a medical report was generated or an error message is returned.
  * **Body:** A JSON object with the following fields:
    * `medical_record` (string): The generated medical report.
    * `classification` (string): The type of input provided (`conversation`, `json`, `other`, or `inappropriate`).
    * `error_message` (string, optional): A message describing any errors that occurred during processing.

**Example Response (Success):**

```json
{
  "medical_record": "Patient presented with a one-week history of severe headaches...",
  "classification": "conversation",
  "error_message": ""
}

```

**Example Response (Error):**

```json
{
  "medical_record": "Input content could not be classified as conversation or JSON. Please provide a valid input.",
  "classification": "other",
  "error_message": "Input content could not be classified as conversation or JSON. Please provide a valid input."
}
```

* **422 Unprocessable Entity:**
  * **Description:** The request body is not a valid JSON or is missing the `content` field.
* **401 Unauthorized:**
  * **Description:** The `Authorization` header is missing or invalid when `API_TOKEN` is configured.
* **500 Internal Server Error:**
  * **Description:** An unexpected error occurred on the server, such as a problem with the language model API.
