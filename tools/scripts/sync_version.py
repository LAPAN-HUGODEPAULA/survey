#!/usr/bin/env python3
"""Synchronize repo version fields from the root VERSION file.

The root VERSION file is the only canonical source for the repository marketing
version. This script propagates that version into selected repo-owned files.

Usage:
    python3 tools/scripts/sync_version.py
    python3 tools/scripts/sync_version.py --check
"""

from __future__ import annotations

import argparse
import re
import sys
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class TargetFile:
    """A file and the replacement rules that derive from VERSION."""

    path: Path
    rules: tuple["ReplacementRule", ...]


@dataclass(frozen=True)
class ReplacementRule:
    """One regex substitution within a target file."""

    pattern: re.Pattern[str]
    replacement: str | Callable[[re.Match[str], str], str]
    expected_matches: int = 1


def _compile(pattern: str) -> re.Pattern[str]:
    return re.compile(pattern, re.MULTILINE)


def _replace_pubspec_semver(match: re.Match[str], version: str) -> str:
    prefix = match.group("prefix")
    build_suffix = match.group("build_suffix") or ""
    trailing = match.group("trailing") or ""
    return f"{prefix}{version}{build_suffix}{trailing}"


def _build_targets() -> tuple[TargetFile, ...]:
    pubspec_rule = ReplacementRule(
        pattern=_compile(
            r"^(?P<prefix>version:\s*)(?P<version>\d+\.\d+\.\d+)(?P<build_suffix>\+\d+)?(?P<trailing>[ \t]*)$"
        ),
        replacement=_replace_pubspec_semver,
    )
    return (
        TargetFile(
            path=ROOT / "README.md",
            rules=(
                ReplacementRule(
                    pattern=_compile(r"(?m)^- Current release: `\d+\.\d+\.\d+` \(tracked in the root `VERSION` file\)\.$"),
                    replacement=lambda _m, version: (
                        f"- Current release: `{version}` (tracked in the root `VERSION` file)."
                    ),
                ),
            ),
        ),
        TargetFile(
            path=ROOT / "services/survey-backend/pyproject.toml",
            rules=(
                ReplacementRule(
                    pattern=_compile(r'^(version = ")\d+\.\d+\.\d+(")$'),
                    replacement=lambda m, version: f'{m.group(1)}{version}{m.group(2)}',
                ),
            ),
        ),
        TargetFile(
            path=ROOT / "services/clinical-writer-api/clinical_writer_agent/pyproject.toml",
            rules=(
                ReplacementRule(
                    pattern=_compile(r'^(version = ")\d+\.\d+\.\d+(")$'),
                    replacement=lambda m, version: f'{m.group(1)}{version}{m.group(2)}',
                ),
            ),
        ),
        TargetFile(
            path=ROOT / "services/survey-backend/app/main.py",
            rules=(
                ReplacementRule(
                    pattern=_compile(r'(\bversion=")\d+\.\d+\.\d+(")'),
                    replacement=lambda m, version: f'{m.group(1)}{version}{m.group(2)}',
                ),
            ),
        ),
        TargetFile(
            path=ROOT / "services/clinical-writer-api/clinical_writer_agent/main.py",
            rules=(
                ReplacementRule(
                    pattern=_compile(r'(\bversion=")\d+\.\d+\.\d+(")'),
                    replacement=lambda m, version: f'{m.group(1)}{version}{m.group(2)}',
                ),
            ),
        ),
        TargetFile(
            path=ROOT / "packages/contracts/survey-backend.openapi.yaml",
            rules=(
                ReplacementRule(
                    pattern=_compile(r"^(\s*version:\s*)\d+\.\d+\.\d+([ \t]*)$"),
                    replacement=lambda m, version: f"{m.group(1)}{version}{m.group(2)}",
                ),
            ),
        ),
        TargetFile(path=ROOT / "packages/design_system_flutter/pubspec.yaml", rules=(pubspec_rule,)),
        TargetFile(path=ROOT / "packages/runtime_api_url/pubspec.yaml", rules=(pubspec_rule,)),
        TargetFile(path=ROOT / "packages/runtime_app_config/pubspec.yaml", rules=(pubspec_rule,)),
        TargetFile(path=ROOT / "apps/survey-builder/pubspec.yaml", rules=(pubspec_rule,)),
        TargetFile(path=ROOT / "apps/survey-frontend/pubspec.yaml", rules=(pubspec_rule,)),
        TargetFile(path=ROOT / "apps/survey-patient/pubspec.yaml", rules=(pubspec_rule,)),
        TargetFile(path=ROOT / "apps/clinical-narrative/pubspec.yaml", rules=(pubspec_rule,)),
    )


def _read_version() -> str:
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError(
            f"VERSION must contain a SemVer core version like 0.2.0, got {version!r}."
        )
    return version


def _apply_rule(
    content: str, rule: ReplacementRule, version: str, file_path: Path
) -> tuple[str, bool]:
    changed = False

    def replacer(match: re.Match[str]) -> str:
        nonlocal changed
        replacement = rule.replacement(match, version) if callable(rule.replacement) else rule.replacement
        if replacement != match.group(0):
            changed = True
        return replacement

    updated, count = rule.pattern.subn(replacer, content)
    if count != rule.expected_matches:
        raise RuntimeError(
            f"{file_path}: expected {rule.expected_matches} match(es) for {rule.pattern.pattern!r}, found {count}."
        )
    return updated, changed


def sync_versions(check_only: bool) -> int:
    version = _read_version()
    changed_files: list[Path] = []

    for target in _build_targets():
        original = target.path.read_text(encoding="utf-8")
        updated = original
        file_changed = False
        for rule in target.rules:
            updated, rule_changed = _apply_rule(updated, rule, version, target.path)
            file_changed = file_changed or rule_changed
        if file_changed:
            changed_files.append(target.path)
            if not check_only:
                target.path.write_text(updated, encoding="utf-8")

    if changed_files:
        header = "Version drift detected" if check_only else "Updated version fields"
        print(f"{header} from VERSION={version}:")
        for path in changed_files:
            print(f"- {path.relative_to(ROOT)}")
        return 1 if check_only else 0

    print(f"All managed version fields already match VERSION={version}.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Fail if any managed file is out of sync with the root VERSION file.",
    )
    args = parser.parse_args()
    return sync_versions(check_only=args.check)


if __name__ == "__main__":
    sys.exit(main())
