import unittest

from app.services.template_service import (
    SUPPORTED_DOCUMENT_TYPE_IDS,
    apply_conditions,
    bump_patch,
    extract_placeholders,
    merge_placeholders,
    normalize_document_type,
    render_template,
    validate_conditions,
)


class TemplateServiceTests(unittest.TestCase):
    def test_extract_placeholders(self) -> None:
        placeholders = extract_placeholders("Hello {{patient.name}} {{ visitId }}")
        self.assertEqual(placeholders, ["patient.name", "visitId"])

    def test_merge_placeholders(self) -> None:
        merged = merge_placeholders("Hello {{patient.name}}", ["patient.name", "extra"])
        self.assertEqual(merged, ["extra", "patient.name"])

    def test_bump_patch(self) -> None:
        self.assertEqual(bump_patch("1.0.0"), "1.0.1")
        self.assertEqual(bump_patch("2.3.9"), "2.3.10")
        self.assertEqual(bump_patch("invalid"), "1.0.0")

    def test_normalize_document_type(self) -> None:
        for doc_type in SUPPORTED_DOCUMENT_TYPE_IDS:
            self.assertEqual(normalize_document_type(doc_type), doc_type)
        with self.assertRaises(ValueError):
            normalize_document_type("unknown")

    def test_render_template_with_missing_fields(self) -> None:
        body = "Hello {{patient.name}} - {{missingField}}"
        rendered, missing = render_template(body, None, {"patient": {"name": "Ana"}})
        self.assertIn("Ana", rendered)
        self.assertIn("missingField", missing)

    def test_apply_conditions(self) -> None:
        base = "Base content"
        conditions = [
            {"field": "patient.age", "equals": 65, "section": "Senior section"},
            {"field": "patient.age", "equals": 20, "section": "Youth section"},
        ]
        conditioned = apply_conditions(base, conditions, {"patient": {"age": 65}})
        self.assertIn("Senior section", conditioned)
        self.assertNotIn("Youth section", conditioned)

    def test_validate_conditions(self) -> None:
        normalized = validate_conditions(
            [{"field": "patient.age", "equals": 30, "section": "Adult section"}]
        )
        self.assertEqual(normalized[0]["field"], "patient.age")
        with self.assertRaises(ValueError):
            validate_conditions([{"field": "patient.age"}])


if __name__ == "__main__":
    unittest.main()
