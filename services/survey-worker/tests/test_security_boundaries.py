from pathlib import Path

import pytest

from lapan_core import (
    SecurityBoundaryError,
    get_safe_write_path,
    validate_outbound_url,
)


def test_get_safe_write_path_rejects_traversal(tmp_path: Path) -> None:
    with pytest.raises(SecurityBoundaryError):
        get_safe_write_path(tmp_path, "../escape.json")


def test_get_safe_write_path_rejects_existing_symlink(tmp_path: Path) -> None:
    outside_file = tmp_path.parent / "outside.json"
    outside_file.write_text("sensitive", encoding="utf-8")
    symlink_path = tmp_path / "job.json"
    symlink_path.symlink_to(outside_file)

    with pytest.raises(SecurityBoundaryError):
        get_safe_write_path(tmp_path, "job.json")


def test_validate_outbound_url_rejects_metadata_ip() -> None:
    url = "http://169.254.169.254/latest/meta-data"

    with pytest.raises(SecurityBoundaryError):
        validate_outbound_url(url, [url])


def test_validate_outbound_url_rejects_invalid_protocol() -> None:
    url = "file:///etc/passwd"

    with pytest.raises(SecurityBoundaryError):
        validate_outbound_url(url, [url])


def test_validate_outbound_url_allows_configured_service_host() -> None:
    url = "http://clinical_writer_agent:8000/process"

    assert validate_outbound_url(url, [url]) == url
