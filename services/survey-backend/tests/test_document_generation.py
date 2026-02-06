import unittest

from app.services.document_generation import (
    build_body_from_messages,
    build_title,
    detect_missing_fields,
    validate_compliance,
)


class DocumentGenerationTests(unittest.TestCase):
    def test_build_body_from_messages(self) -> None:
        messages = [
            {"role": "clinician", "content": "Hello", "deletedAt": None},
            {"role": "assistant", "content": "Hi", "deletedAt": None},
        ]
        body = build_body_from_messages(messages)
        self.assertIn("Clinician: Hello", body)
        self.assertIn("Assistant: Hi", body)

    def test_detect_missing_fields(self) -> None:
        missing = detect_missing_fields("", "", {"patientId": None})
        self.assertIn("title", missing)
        self.assertIn("body", missing)
        self.assertIn("patientId", missing)

    def test_validate_compliance(self) -> None:
        with self.assertRaises(ValueError):
            validate_compliance("", "content")
        with self.assertRaises(ValueError):
            validate_compliance("Title", "")

        validate_compliance("Title", "Body")

    def test_build_title(self) -> None:
        title = build_title("consult_note")
        self.assertIn("Consult Note", title)


if __name__ == "__main__":
    unittest.main()
