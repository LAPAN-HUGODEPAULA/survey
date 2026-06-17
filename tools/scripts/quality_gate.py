#!/usr/bin/env python3
"""Unified Python quality gate runner for local and CI use."""

from __future__ import annotations

import argparse
import os
import shlex
import subprocess
import sys
from collections.abc import Sequence
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
PYPROJECT_PATH = REPO_ROOT / "pyproject.toml"
MANAGED_ROOTS = (
    "services/",
    "packages/python/",
    "tools/scripts/",
)
EXCLUDED_PREFIXES = (
    ".venv/",
    ".skylos/",
    "config/runtime/generated/",
    "tools/codex-claude-mobile-toolkit/",
)


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments for the quality gate runner."""
    parser = argparse.ArgumentParser(
        description="Run Python quality checks for the LAPAN Survey Platform.",
    )
    parser.add_argument("files", nargs="*", help="Optional explicit file list.")
    parser.add_argument(
        "--all",
        action="store_true",
        help="Run the quality gate across the managed Python surface.",
    )
    parser.add_argument(
        "--staged",
        action="store_true",
        help="Use only staged files from the git index.",
    )
    parser.add_argument(
        "--hook",
        choices=("compile", "ruff", "mypy", "pylint", "skylos"),
        help="Run a single check, primarily for pre-commit hooks.",
    )
    return parser.parse_args()


def main() -> int:
    """Run the selected quality checks and return a process exit code."""
    args = parse_args()
    os.chdir(REPO_ROOT)

    files = resolve_python_files(
        explicit_files=args.files,
        run_all=args.all,
        staged_only=args.staged,
    )

    if args.hook:
        return run_single_check(args.hook, files, run_all=args.all)

    if not files and not args.all:
        print("quality_gate: no managed Python changes detected")
        return 0

    for check_name in ("compile", "ruff", "mypy", "pylint", "skylos"):
        exit_code = run_single_check(check_name, files, run_all=args.all)
        if exit_code != 0:
            return exit_code
    return 0


def resolve_python_files(
    *,
    explicit_files: Sequence[str],
    run_all: bool,
    staged_only: bool,
) -> list[str]:
    """Resolve the managed Python file set for the current invocation."""
    candidates: list[str]
    if explicit_files:
        candidates = [str(item) for item in explicit_files]
    elif run_all:
        candidates = git_lines("git ls-files -- '*.py'")
    elif staged_only:
        candidates = git_lines("git diff --cached --name-only --diff-filter=ACMRTUXB -- '*.py'")
    else:
        base_ref = diff_base_ref()
        candidates = git_lines(
            f"git diff --name-only --diff-filter=ACMRTUXB {shlex.quote(base_ref)} -- '*.py'"
        )
        candidates.extend(git_lines("git ls-files --others --exclude-standard -- '*.py'"))

    unique_files: list[str] = []
    seen: set[str] = set()
    for candidate in candidates:
        if not candidate.endswith(".py"):
            continue
        normalized = normalize_path(candidate)
        if not normalized.exists():
            continue
        rel_path = normalized.relative_to(REPO_ROOT).as_posix()
        if not is_managed_python_path(rel_path):
            continue
        if is_git_ignored(rel_path):
            continue
        if rel_path in seen:
            continue
        seen.add(rel_path)
        unique_files.append(rel_path)
    return unique_files


def normalize_path(value: str) -> Path:
    """Return an absolute normalized path rooted in the repository."""
    candidate = Path(value)
    if candidate.is_absolute():
        return candidate.resolve()
    return (REPO_ROOT / candidate).resolve()


def is_managed_python_path(rel_path: str) -> bool:
    """Return whether a path belongs to the managed Python surface."""
    if rel_path.startswith(EXCLUDED_PREFIXES):
        return False
    return rel_path.startswith(MANAGED_ROOTS)


def is_git_ignored(rel_path: str) -> bool:
    """Return whether gitignore excludes a path."""
    result = subprocess.run(
        ["git", "check-ignore", rel_path],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0


def diff_base_ref() -> str:
    """Resolve a stable diff base for quick local scans."""
    for candidate in ("origin/main", "main", "master"):
        verify = subprocess.run(
            ["git", "rev-parse", "--verify", candidate],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if verify.returncode == 0:
            merge_base = subprocess.run(
                ["git", "merge-base", candidate, "HEAD"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            if merge_base.returncode == 0:
                return merge_base.stdout.strip()
            return candidate
    return "HEAD"


def git_lines(command: str) -> list[str]:
    """Run a git command and return non-empty output lines."""
    result = subprocess.run(
        command,
        cwd=REPO_ROOT,
        shell=True,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def run_single_check(check_name: str, files: Sequence[str], *, run_all: bool) -> int:
    """Run a single configured quality check."""
    if check_name == "skylos":
        return run_skylos(files, run_all=run_all)
    if not files:
        print(f"quality_gate: skipping {check_name}, no managed Python files selected")
        return 0

    commands = {
        "compile": [sys.executable, "-m", "compileall", "-q", *files],
        "ruff": ["ruff", "check", "--force-exclude", *files],
        "mypy": ["mypy", "--config-file", str(PYPROJECT_PATH), *files],
        "pylint": ["pylint", *files],
    }
    command = commands[check_name]
    return run_command(command, label=check_name)


def run_skylos(files: Sequence[str], *, run_all: bool) -> int:
    """Run Skylos in baseline-aware gate mode."""
    if not run_all and not files:
        print("quality_gate: skipping skylos, no managed Python files selected")
        return 0
    command = [
        "uvx",
        "skylos",
        "--config-file",
        str(PYPROJECT_PATH),
        ".",
        "--baseline",
        "--gate",
        "--format",
        "concise",
    ]
    return run_command(command, label="skylos")


def run_command(command: Sequence[str], *, label: str) -> int:
    """Run a subprocess command and stream its output."""
    print(f"quality_gate: running {label}: {' '.join(shlex.quote(part) for part in command)}")
    result = subprocess.run(command, cwd=REPO_ROOT, check=False)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
