import unittest

from app.services.document_generation import (
    build_body_from_messages,
    build_title,
    detect_missing_fields,
    render_html,
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

    def test_render_html_escapes_title_and_metadata(self) -> None:
        html = render_html(
            '<script>alert("x")</script>',
            'Body <b>unsafe</b>',
            {
                "phase": '<img src=x onerror=alert(1)>',
                "sessionId": '<svg onload=alert(2)>',
                "patientId": '<iframe>',
                "createdAt": '<script>bad()</script>',
            },
        )

        self.assertNotIn("<script>", html)
        self.assertNotIn("<img", html)
        self.assertNotIn("<svg", html)
        self.assertIn("&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;", html)
        self.assertIn("Body &lt;b&gt;unsafe&lt;/b&gt;", html)


if __name__ == "__main__":
    unittest.main()
