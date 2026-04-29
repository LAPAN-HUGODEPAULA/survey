"""Tests for the shared key normalization utility."""

import pytest

from app.domain.models._key_validation import normalize_key


class TestNormalizeKey:
    def test_normalizes_and_lowercases(self):
        assert normalize_key("MyKey", field_name="test") == "mykey"

    def test_strips_whitespace(self):
        assert normalize_key("  my-key  ", field_name="test") == "my-key"

    def test_allows_base_charset(self):
        assert normalize_key("abc_123:test-key", field_name="test") == "abc_123:test-key"

    def test_rejects_blank(self):
        with pytest.raises(ValueError, match="test must not be blank"):
            normalize_key("", field_name="test")

    def test_rejects_whitespace_only(self):
        with pytest.raises(ValueError, match="test must not be blank"):
            normalize_key("   ", field_name="test")

    def test_rejects_spaces(self):
        with pytest.raises(ValueError, match="test must contain only"):
            normalize_key("my key", field_name="test")

    def test_rejects_special_chars(self):
        with pytest.raises(ValueError, match="test must contain only"):
            normalize_key("key@name", field_name="test")

    def test_optional_returns_none_for_none(self):
        assert normalize_key(None, field_name="test", optional=True) is None

    def test_optional_returns_none_for_blank(self):
        assert normalize_key("", field_name="test", optional=True) is None

    def test_optional_returns_none_for_whitespace(self):
        assert normalize_key("   ", field_name="test", optional=True) is None

    def test_optional_validates_when_present(self):
        assert normalize_key("valid-key", field_name="test", optional=True) == "valid-key"

    def test_optional_rejects_invalid_when_present(self):
        with pytest.raises(ValueError, match="test must contain only"):
            normalize_key("invalid key", field_name="test", optional=True)

    def test_allowed_extra_chars_permit_period(self):
        assert normalize_key("key.with.dots", field_name="test", allowed_extra_chars=".") == "key.with.dots"

    def test_allowed_extra_chars_rejects_unlisted(self):
        with pytest.raises(ValueError, match="test must contain only"):
            normalize_key("key$sign", field_name="test", allowed_extra_chars=".")

    def test_error_message_includes_field_name(self):
        with pytest.raises(ValueError, match="myField must not be blank"):
            normalize_key("", field_name="myField")

    def test_error_message_includes_period_label(self):
        with pytest.raises(ValueError, match="period"):
            normalize_key("bad@key", field_name="test", allowed_extra_chars=".")
