#!/usr/bin/env python3
"""Render runtime config artifacts from a private JSON source-of-truth."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "config" / "runtime" / "config.private.json"
GENERATED = ROOT / "config" / "runtime" / "generated"
PUBLIC_DIR = GENERATED / "public"
PRIVATE_DIR = GENERATED / "private"


def _load_source() -> dict:
    if not SOURCE.exists():
      raise FileNotFoundError(
          f"Missing runtime config: {SOURCE}. "
          "Copy config/runtime/config.private.example.json to config.private.json and fill it in."
      )
    return json.loads(SOURCE.read_text(encoding="utf-8"))


def _ensure_dirs() -> None:
    PUBLIC_DIR.mkdir(parents=True, exist_ok=True)
    PRIVATE_DIR.mkdir(parents=True, exist_ok=True)


def _write_json(path: Path, payload: dict) -> None:
    path.write_text(
        json.dumps(payload, indent=2, ensure_ascii=True) + "\n",
        encoding="utf-8",
    )


def _write_env(path: Path, payload: dict[str, str]) -> None:
    lines = [f"{key}={value}" for key, value in payload.items()]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def _csv(items: list[str]) -> str:
    return ",".join(item for item in items if item)


def main() -> None:
    config = _load_source()
    _ensure_dirs()

    public = config.get("public", {})
    private = config.get("private", {})
    mongo = private.get("mongo", {})
    mail = private.get("mail", {})
    backend = private.get("backend", {})
    worker = private.get("worker", {})
    deployment = private.get("deployment", {})

    _write_json(PUBLIC_DIR / "survey-frontend.config.json", public.get("surveyFrontend", {}))
    _write_json(PUBLIC_DIR / "survey-patient.config.json", public.get("surveyPatient", {}))
    _write_json(PUBLIC_DIR / "survey-builder.config.json", public.get("surveyBuilder", {}))
    _write_json(PUBLIC_DIR / "clinical-narrative.config.json", public.get("clinicalNarrative", {}))

    _write_env(
        PRIVATE_DIR / "mongodb.env",
        {
            "MONGO_INITDB_ROOT_USERNAME": str(mongo.get("initdbRootUsername", "")),
            "MONGO_INITDB_ROOT_PASSWORD": str(mongo.get("initdbRootPassword", "")),
        },
    )
    _write_env(
        PRIVATE_DIR / "traefik.env",
        {
            "LETSENCRYPT_EMAIL": str(deployment.get("letsencryptEmail", "")),
        },
    )
    _write_env(
        PRIVATE_DIR / "survey-backend.env",
        {
            "MONGO_URI": str(mongo.get("uri", "")),
            "MONGO_DB_NAME": str(mongo.get("dbName", "survey_db")),
            "MONGO_HOST": str(mongo.get("host", "")),
            "MONGO_USERNAME": str(mongo.get("username", "")),
            "MONGO_PASSWORD": str(mongo.get("password", "")),
            "MONGO_URI_TEMPLATE": str(mongo.get("uriTemplate", "")),
            "MONGO_URI_ATLAS": str(mongo.get("uriAtlas", "")),
            "MAIL_USERNAME": str(mail.get("username", "")),
            "MAIL_PASSWORD": str(mail.get("password", "")),
            "MAIL_SERVER": str(mail.get("server", "")),
            "MAIL_PORT": str(mail.get("port", 587)),
            "ENVIRONMENT": str(backend.get("environment", "development")),
            "MY_CUSTOM_ENV": str(backend.get("myCustomEnv", "")),
            "CLINICAL_WRITER_URL": str(backend.get("clinicalWriterUrl", "")),
            "CLINICAL_WRITER_API_TOKEN": str(backend.get("clinicalWriterApiToken", "")),
            "CLINICAL_WRITER_TRANSCRIPTION_URL": str(
                backend.get("clinicalWriterTranscriptionUrl", "")
            ),
            "SECRET_KEY": str(backend.get("secretKey", "")),
            "ALGORITHM": str(backend.get("algorithm", "HS256")),
            "ACCESS_TOKEN_EXPIRE_MINUTES": str(
                backend.get("accessTokenExpireMinutes", 30)
            ),
            "CORS_ALLOWED_ORIGINS": _csv(backend.get("corsAllowedOrigins", [])),
            "TEMPLATE_ADMIN_EMAILS": _csv(backend.get("templateAdminEmails", [])),
            "PRIVACY_ADMIN_TOKEN": str(backend.get("privacyAdminToken", "")),
            "ENCRYPTION_KEY_ID": str(backend.get("encryptionKeyId", "")),
            "ENCRYPTION_PROVIDER": str(backend.get("encryptionProvider", "")),
            "LANGGRAPH_URL": str(backend.get("langgraphUrl", "")),
            "LANGGRAPH_API_TOKEN": str(backend.get("langgraphApiToken", "")),
            "LANGGRAPH_ANALYSIS_URL": str(backend.get("langgraphAnalysisUrl", "")),
            "LANGGRAPH_TRANSCRIPTION_URL": str(
                backend.get("langgraphTranscriptionUrl", "")
            ),
        },
    )
    _write_env(
        PRIVATE_DIR / "survey-worker.env",
        {
            "MONGO_URI": str(mongo.get("uri", "")),
            "MONGO_DB_NAME": str(mongo.get("dbName", "survey_db")),
            "CLINICAL_WRITER_URL": str(backend.get("clinicalWriterUrl", "")),
            "CLINICAL_WRITER_API_TOKEN": str(backend.get("clinicalWriterApiToken", "")),
            "POLL_INTERVAL_SECONDS": str(worker.get("pollIntervalSeconds", 10)),
            "BATCH_SIZE": str(worker.get("batchSize", 10)),
            "HTTP_TIMEOUT_SECONDS": str(worker.get("httpTimeoutSeconds", 15)),
        },
    )
    _write_env(
        PRIVATE_DIR / "clinical-writer.env",
        {
            "ENVIRONMENT": str(backend.get("environment", "development")),
            "API_TOKEN": str(backend.get("clinicalWriterApiToken", "")),
            "ALLOW_UNAUTHENTICATED_ACCESS": str(
                backend.get("allowUnauthenticatedClinicalWriterAccess", False)
            ).lower(),
        },
    )


if __name__ == "__main__":
    main()
