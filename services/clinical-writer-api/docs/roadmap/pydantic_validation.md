# Roadmap: Pydantic for Data Validation

## Current Issue

JSON input is validated by checking for the presence of keys, which is not very robust.

## Recommendation

Use Pydantic models to define and validate the structure of the JSON input.

```python
# src/models.py
from pydantic import BaseModel
from typing import List

class PatientSurvey(BaseModel):
    patient: str
    surveyId: str
    responses: List[dict]

# src/classification_strategies.py
from .models import PatientSurvey

class JsonClassificationStrategy(ClassificationStrategy):
    def classify(self, text: str) -> Tuple[Optional[str], bool]:
        try:
            data = json.loads(text)
            PatientSurvey.model_validate(data)
            return (AgentConfig.CLASSIFICATION_JSON, True)
        except (json.JSONDecodeError, ValidationError):
            return (None, False)
```

## Benefits

-   **Robust Validation:** Ensures the JSON input has the correct structure and data types.
-   **Clear Schemas:** The Pydantic model serves as a clear and executable schema for your data.
-   **Error Handling:** Provides detailed error messages when validation fails.

## Priority

**Medium**
