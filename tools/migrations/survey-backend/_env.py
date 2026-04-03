"""Shared environment bootstrap helpers for survey-backend migrations."""

from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit

from dotenv import load_dotenv


SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent
ENV_FILES = (
    PROJECT_ROOT / ".env",
    PROJECT_ROOT / "config" / "runtime" / "generated" / "private" / "mongodb.env",
    PROJECT_ROOT / "config" / "runtime" / "generated" / "private" / "survey-backend.env",
)


def load_migration_env() -> None:
    """Load repository env files without overriding explicit shell variables."""
    for env_file in ENV_FILES:
        if env_file.is_file():
            load_dotenv(env_file, override=False)


def resolve_mongo_uri() -> str:
    """Resolve the Mongo connection URI for host-shell and container execution."""
    mongo_uri = os.getenv("MONGO_URI")
    if mongo_uri:
        return _normalize_mongo_uri(mongo_uri)

    username = os.getenv("MONGO_USERNAME")
    password = os.getenv("MONGO_PASSWORD")
    if username and password:
        return f"mongodb://{username}:{password}@localhost:27017/"

    return "mongodb://localhost:27017/"


def resolve_mongo_db_name() -> str:
    """Return the configured Mongo database name."""
    return os.getenv("MONGO_DB_NAME", "survey_db")


def _normalize_mongo_uri(mongo_uri: str) -> str:
    if not mongo_uri.startswith(("mongodb://", "mongodb+srv://")):
        mongo_uri = f"mongodb://{mongo_uri}"

    if mongo_uri.startswith("mongodb+srv://") or _is_running_in_container():
        return mongo_uri

    parsed = urlsplit(mongo_uri)
    if parsed.hostname != "mongodb":
        return mongo_uri

    auth = ""
    if parsed.username:
        auth = parsed.username
        if parsed.password:
            auth = f"{auth}:{parsed.password}"
        auth = f"{auth}@"

    host = "localhost"
    if parsed.port:
        host = f"{host}:{parsed.port}"

    return urlunsplit(
        (
            parsed.scheme,
            f"{auth}{host}",
            parsed.path or "/",
            parsed.query,
            parsed.fragment,
        )
    )


def _is_running_in_container() -> bool:
    return Path("/.dockerenv").exists()
