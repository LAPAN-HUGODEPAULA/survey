"""Privacy and audit configuration for builder records."""

from datetime import timedelta


class BuilderAuditPrivacyConfig:
    """Configuration for builder audit privacy policies."""

    # Retention policy
    AUDIT_RETENTION_DAYS = 90  # 90-day retention per LGPD requirements

    # Content minimization rules
    CONTENT_MINIMIZATION = {
        "surveys": {
            "allowed_fields": ["survey_id", "version", "display_name"],
            "excluded_fields": ["instructions", "questions", "final_notes", "raw_responses"],
            "summary_fields": ["question_count", "has_final_notes"]
        },
        "prompts": {
            "allowed_fields": ["prompt_key", "name", "content_digest", "version", "word_count"],
            "excluded_fields": ["full_prompt_text", "raw_prompt_content"],
            "summary_fields": ["topic_category", "is_clinical", "complexity_score"]
        },
        "persona_skills": {
            "allowed_fields": ["persona_skill_key", "name", "version"],
            "excluded_fields": ["full_description", "capability_matrix", "raw_training_data"],
            "summary_fields": ["domain_focus", "expertise_level"]
        },
        "agent_access_points": {
            "allowed_fields": ["access_point_key", "name", "survey_id", "prompt_key", "version"],
            "excluded_fields": ["configuration_details", "access_rules", "raw_api_keys"],
            "summary_fields": ["endpoint_type", "is_active", "last_used"]
        },
        "authentication": {
            "allowed_fields": ["email", "ip_address", "user_agent", "success", "failure_reason"],
            "excluded_fields": ["password_hash", "session_tokens", "security_tokens"],
            "summary_fields": ["auth_method", "device_type", "browser_info"]
        }
    }

    # Access control
    ACCESS_CONTROL = {
        "allowed_roles": ["admin", "security_officer", "compliance_officer"],
        "required_two_factor": True,
        "ip_whitelist": [],  # Empty means allow from anywhere with proper auth
        "audit_on_access": True,  # Log who accessed audit records
        "max_export_records": 10000,  # Limit for bulk exports
    }

    # Sensitive pattern detection
    SENSITIVE_PATTERNS = {
        "phi_keywords": [
            "patient", "medical", "clinical", "diagnosis", "treatment",
            "symptom", "prescription", "hospital", "doctor", "health",
            "ssn", "cpf", "rg", "nascimento", "idade", "gender",
            "telefone", "celular", "endereco", "bairro", "cidade"
        ],
        "pii_patterns": [
            r'\b\d{3}\.\d{3}\.\d{3}-\d{4}\b',  # CPF
            r'\b\d{2}\.\d{3}\.\d{3}-\d{4}\b',  # RG variation
            r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  # Email (except for audit actor)
            r'\b\d{2}\d{4,5}-\d{4}\b',  # Phone numbers
            r'\b\d{2}/\d{2}/\d{4}\b',  # Dates
        ],
        "redaction_flags": {
            "redact_phi": True,
            "hash_content": True,
            "anonymize_pii": False,  # Only hash by default
            "preserve_for_governance": ["content_digest", "version", "word_count"]
        }
    }

    @classmethod
    def should_redact_field(cls, field_name: str, resource_type: str) -> bool:
        """Check if a field should be redacted based on privacy rules."""
        if resource_type not in cls.CONTENT_MINIMIZATION:
            return True

        return (
            field_name in cls.CONTENT_MINIMIZATION[resource_type]["excluded_fields"]
            or any(keyword in field_name.lower()
                   for keyword in cls.SENSITIVE_PATTERNS["phi_keywords"])
        )

    @classmethod
    def get_allowed_fields(cls, resource_type: str) -> list:
        """Get list of allowed fields for a resource type."""
        return cls.CONTENT_MINIMIZATION.get(resource_type, {}).get("allowed_fields", [])

    @classmethod
    def get_retention_period(cls) -> timedelta:
        """Get the retention period as a timedelta."""
        return timedelta(days cls.AUDIT_RETENTION_DAYS)