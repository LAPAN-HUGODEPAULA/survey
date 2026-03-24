# Change: Establish Platform-Wide Security and Data Privacy

## Why
The platform handles sensitive medical data across multiple applications and services. We need a consistent, compliant security and privacy framework that applies to the entire platform to reduce risk and align with LGPD expectations.

## What Changes
- Define LGPD-aligned privacy governance (legal basis, data subject rights, privacy by default, data minimization).
- Establish platform-wide access control and session security (without MFA requirements).
- Require encryption at rest and in transit with centralized key management expectations.
- Specify audit logging and security monitoring requirements.
- Define data lifecycle and deletion workflows without fixed retention periods.

## Impact
- Affected specs: `data-privacy-governance`, `access-control-security`, `encryption-transport-security`, `audit-logging-monitoring`, `data-lifecycle`.
- Affected systems: `services/survey-backend`, `services/clinical-writer-api`, `apps/survey-frontend`, `apps/survey-patient`, `apps/clinical-narrative`.
- Notes: This proposal is platform-wide and replaces ad-hoc security practices with consistent requirements.
