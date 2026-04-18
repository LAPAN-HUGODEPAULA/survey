"""Tests for builder audit functionality."""

import pytest
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock

from app.domain.models.audit_models import (
    ActorInfo,
    BuilderAuditCreate,
    ResourceInfo
)
from app.services.builder_audit import BuilderAuditService
from app.services.audit_privacy import AuditPrivacyService


class TestBuilderAuditService:
    """Test the builder audit service."""

    @pytest.fixture
    def mock_builder_repo(self):
        """Mock builder audit repository."""
        repo = AsyncMock()
        repo.create = AsyncMock(return_value={"_id": "test_id", "created_at": datetime.utcnow()})
        return repo

    @pytest.fixture
    def mock_security_repo(self):
        """Mock security audit repository."""
        repo = AsyncMock()
        return repo

    @pytest.fixture
    def mock_security_service(self):
        """Mock security audit service."""
        service = AsyncMock()
        service.record_event = AsyncMock()
        return service

    @pytest.fixture
    def audit_service(self, mock_builder_repo, mock_security_repo, mock_security_service):
        """Create audit service with mocked dependencies."""
        return BuilderAuditService(
            builder_repo=mock_builder_repo,
            security_repo=mock_security_repo,
            security_service=mock_security_service
        )

    @pytest.mark.asyncio
    async def test_record_survey_operation_success(self, audit_service):
        """Test recording a successful survey operation."""
        # Arrange
        correlation_id = "test_corr_123"
        actor = ActorInfo(id="user1", email="user@example.com")
        survey_id = "survey_123"
        version = datetime.utcnow()
        display_name = "Test Survey"

        # Act
        result = await audit_service.record_survey_operation(
            correlation_id=correlation_id,
            actor=actor,
            operation="create_survey",
            status="success",
            survey_id=survey_id,
            version=version,
            display_name=display_name
        )

        # Assert
        assert result is not None
        audit_service._builder_repo.create.assert_called_once()
        audit_service._security_service.record_event.assert_called_once()

    @pytest.mark.asyncio
    async def test_record_prompt_operation_with_digest(self, audit_service):
        """Test recording a prompt operation with content digest."""
        # Arrange
        correlation_id = "test_corr_456"
        actor = ActorInfo(id="user2", email="user2@example.com")
        prompt_key = "clinical_v1"
        name = "Clinical Prompt"
        prompt_text = "This is a clinical prompt about patient care."
        version = datetime.utcnow()

        # Act
        result = await audit_service.record_prompt_operation(
            correlation_id=correlation_id,
            actor=actor,
            operation="create_prompt",
            status="success",
            prompt_key=prompt_key,
            name=name,
            prompt_text=prompt_text,
            version=version
        )

        # Assert
        assert result is not None
        # Verify content digest was calculated
        call_args = audit_service._builder_repo.create.call_args
        assert "content_digest" in call_args[0]["outcome"]
        assert call_args[0]["outcome"]["word_count"] == 6

    @pytest.mark.asyncio
    async def test_record_auth_operation_failure(self, audit_service):
        """Test recording a failed authentication operation."""
        # Arrange
        correlation_id = "test_corr_auth"
        email = "baduser@example.com"
        failure_reason = "Invalid credentials"
        ip_address = "192.168.1.1"
        user_agent = "Mozilla/5.0"

        # Act
        result = await audit_service.record_auth_operation(
            correlation_id=correlation_id,
            email=email,
            operation="login",
            status="failed",
            ip_address=ip_address,
            user_agent=user_agent,
            failure_reason=failure_reason
        )

        # Assert
        assert result is not None
        audit_service._security_service.record_event.assert_called_once()
        # Verify failure is captured
        call_args = audit_service._security_service.record_event.call_args
        assert call_args[0]["payload"]["outcome"]["success"] is False


class TestAuditPrivacyService:
    """Test the audit privacy service."""

    def test_minimize_outcome_data_surveys(self):
        """Test minimizing survey outcome data."""
        # Arrange
        outcome = {
            "survey_id": "survey_123",
            "display_name": "Test Survey",
            "instructions": "Raw instructions that should be redacted",
            "questions": ["Q1", "Q2"],
            "raw_responses": ["Sensitive data"]
        }

        # Act
        minimized = AuditPrivacyService.minimize_outcome_data(outcome, "surveys")

        # Assert
        assert "survey_id" in minimized
        assert "display_name" in minimized
        assert "instructions" not in minimized
        assert "raw_responses" not in minimized
        assert "question_count" in minimized
        assert minimized["question_count"] == 2

    def test_compute_content_digest(self):
        """Test content digest computation."""
        # Arrange
        text = "This is test content"

        # Act
        digest1 = AuditPrivacyService.compute_content_digest(text=text)
        digest2 = AuditPrivacyService.compute_content_digest(text=text)
        digest3 = AuditPrivacyService.compute_content_digest(text="Different content")

        # Assert
        assert digest1 == digest2  # Same content should produce same digest
        assert digest1 != digest3  # Different content should produce different digests
        assert len(digest1) == 64  # SHA256 produces 64-character hex strings

    def test_detect_sensitive_content(self):
        """Test sensitive content detection."""
        # Arrange
        text_with_phi = "Patient John Doe has diabetes and lives at 123 Main St."

        # Act
        detected = AuditPrivacyService.detect_sensitive_content(text_with_phi)

        # Assert
        assert len(detected) > 0
        assert any("PHI_KEYWORD" in pattern for pattern in detected)

    def test_sanitize_user_agent(self):
        """Test user agent sanitization."""
        # Arrange
        raw_ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 ip=192.168.1.100 session=abc123def456"
        expected = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 [IP] [SESSION]"

        # Act
        sanitized = AuditPrivacyService.sanitize_user_agent(raw_ua)

        # Assert
        assert "[IP]" in sanitized
        assert "[SESSION]" in sanitized
        assert "192.168.1.100" not in sanitized
        assert "abc123def456" not in sanitized

    def test_should_audit_access(self):
        """Test access audit decision."""
        # Arrange
        valid_roles = ["admin", "security_officer"]
        invalid_roles = ["user", "viewer"]

        # Act & Assert
        assert AuditPrivacyService.should_audit_access(valid_roles) is True
        assert AuditPrivacyService.should_audit_access(invalid_roles) is False
        assert AuditPrivacyService.should_audit_access(valid_roles, requested_records=20000) is False  # Exceeds limit

    def test_validate_retention_policy(self):
        """Test retention policy validation."""
        # Act
        validation = AuditPrivacyService.validate_retention_policy()

        # Assert
        assert isinstance(validation, dict)
        assert "is_valid" in validation
        assert "warnings" in validation
        assert "retention_days" in validation
        assert "compliant_with" in validation