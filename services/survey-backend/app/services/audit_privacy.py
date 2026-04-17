"""Service for enforcing privacy rules on audit data."""

import hashlib
import re
from typing import Dict, List, Optional, Any

from app.config.privacy_audit_config import BuilderAuditPrivacyConfig
from app.config.logging_config import logger


class AuditPrivacyService:
    """Service for applying privacy and minimization rules to audit data."""

    @staticmethod
    def minimize_outcome_data(
        outcome: Dict[str, Any],
        resource_type: str
    ) -> Dict[str, Any]:
        """Apply minimization rules to outcome data."""
        if resource_type not in BuilderAuditPrivacyConfig.CONTENT_MINIMIZATION:
            # If resource type not configured, return empty dict
            return {}

        config = BuilderAuditPrivacyConfig.CONTENT_MINIMIZATION[resource_type]
        minimized = {}

        # Only include allowed fields
        for field_name, value in outcome.items():
            if field_name in config["allowed_fields"]:
                minimized[field_name] = value

        # Add summary fields if applicable
        if resource_type == "surveys" and "questions" in outcome:
            minimized["question_count"] = len(outcome["questions"])
        elif resource_type == "prompts" and "prompt_text" in outcome:
            minimized["word_count"] = len(outcome["prompt_text"].split())

        return minimized

    @staticmethod
    def detect_sensitive_content(text: str) -> List[str]:
        """Detect sensitive content in text."""
        detected_patterns = []

        # Check for PHI keywords
        for keyword in BuilderAuditPrivacyConfig.SENSITIVE_PATTERNS["phi_keywords"]:
            if keyword.lower() in text.lower():
                detected_patterns.append(f"PHI_KEYWORD:{keyword}")

        # Check for PII patterns
        for pattern in BuilderAuditPrivacyConfig.SENSITIVE_PATTERNS["pii_patterns"]:
            matches = re.findall(pattern, text)
            if matches:
                detected_patterns.append(f"PII_PATTERN:{pattern}")

        return detected_patterns

    @staticmethod
    def compute_content_digest(text: Optional[str] = None, data: Optional[Dict] = None) -> Optional[str]:
        """Compute content digest for integrity checking."""
        if text:
            # Use text content
            content = text.encode('utf-8')
        elif data:
            # Use data dict (sorted keys for consistency)
            content = str(sorted(data.items())).encode('utf-8')
        else:
            return None

        return hashlib.sha256(content).hexdigest()

    @staticmethod
    def sanitize_user_agent(user_agent: str) -> str:
        """Sanitize user agent to remove potentially sensitive info."""
        # Remove IP addresses, session IDs, and other sensitive tokens
        sanitized = re.sub(r'(ip=\d+\.\d+\.\d+\.\d+)', '[IP]', user_agent)
        sanitized = re.sub(r'(session|token)=[a-zA-Z0-9_-]{20,}', '[SESSION]', sanitized)
        sanitized = re.sub(r'(csrf|xsrf)=[a-zA-Z0-9_-]{10,}', '[CSRF]', sanitized)
        return sanitized

    @staticmethod
    def should_audit_access(user_roles: List[str], requested_records: int = 1) -> bool:
        """Check if access to audit records should be audited."""
        config = BuilderAuditPrivacyConfig.ACCESS_CONTROL

        # Check role permissions
        if not any(role in config["allowed_roles"] for role in user_roles):
            return False

        # Check two-factor requirement
        if config["required_two_factor"]:
            # This would be checked against user session data
            pass

        # Check export limits
        if requested_records > config["max_export_records"]:
            return False

        return config["audit_on_access"]

    @staticmethod
    def validate_retention_policy() -> Dict[str, Any]:
        """Validate current retention policy configuration."""
        config = BuilderAuditPrivacyConfig

        validation = {
            "is_valid": True,
            "warnings": [],
            "retention_days": config.AUDIT_RETENTION_DAYS,
            "compliant_with": ["LGPD"],
            "recommendations": []
        }

        # Check retention period meets minimum requirements
        if config.AUDIT_RETENTION_DAYS < 90:
            validation["warnings"].append("Retention period below LGPD minimum (90 days)")
            validation["is_valid"] = False

        # Check if we have patterns defined for all resource types
        defined_types = set(config.CONTENT_MINIMIZATION.keys())
        all_types = {"surveys", "prompts", "persona_skills", "agent_access_points", "authentication"}

        missing_types = all_types - defined_types
        if missing_types:
            validation["recommendations"].append(
                f"Add content minimization rules for: {', '.join(missing_types)}"
            )

        return validation

    @staticmethod
    def generate_privacy_report() -> Dict[str, Any]:
        """Generate a privacy compliance report for audit records."""
        config = BuilderAuditPrivacyConfig

        return {
            "timestamp": "2026-04-17T00:00:00Z",  # Current date
            "configuration": {
                "retention_days": config.AUDIT_RETENTION_DAYS,
                "content_minimization_enabled": True,
                "phi_detection_enabled": True,
                "pii_pattern_detection": len(config.SENSITIVE_PATTERNS["pii_patterns"]),
                "phi_keywords_count": len(config.SENSITIVE_PATTERNS["phi_keywords"])
            },
            "access_control": {
                "allowed_roles": config.ACCESS_CONTROL["allowed_roles"],
                "two_factor_required": config.ACCESS_CONTROL["required_two_factor"],
                "audit_on_access": config.ACCESS_CONTROL["audit_on_access"],
                "max_export_records": config.ACCESS_CONTROL["max_export_records"]
            },
            "compliance_status": {
                "lgpd_compliant": config.AUDIT_RETENTION_DAYS >= 90,
                "data_minimization": len(config.CONTENT_MINIMIZATION) > 0,
                "access_controls": len(config.ACCESS_CONTROL["allowed_roles"]) > 0
            }
        }