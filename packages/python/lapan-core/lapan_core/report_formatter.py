"""Shared utilities for turning clinical writer report payloads into text."""

from __future__ import annotations

from typing import Any


class ReportTextFormatter:
    """Flatten structured report payloads into readable plain text."""

    @classmethod
    def to_text(cls, report: dict[str, Any] | None) -> str:
        if not isinstance(report, dict):
            return ""

        lines: list[str] = []
        if cls._looks_like_section_report(report):
            cls._append_section_report(lines, report)
        else:
            cls._append_generic_value(lines, report, 0)
        return "\n".join(line for line in lines if line).strip()

    @staticmethod
    def _looks_like_section_report(report: dict[str, Any]) -> bool:
        return isinstance(report.get("sections"), list)

    @classmethod
    def _append_section_report(cls, lines: list[str], report: dict[str, Any]) -> None:
        for field in ("title", "subtitle"):
            value = str(report.get(field) or "").strip()
            if value:
                lines.append(value)

        for section in report.get("sections") or []:
            if not isinstance(section, dict):
                continue
            heading = str(
                section.get("title") or section.get("heading") or ""
            ).strip()
            body = str(section.get("body") or "").strip()
            if heading:
                lines.append(heading)
            if body:
                lines.append(body)

            for block in section.get("blocks") or []:
                if not isinstance(block, dict):
                    continue
                cls._append_block(lines, block)

    @classmethod
    def _append_block(cls, lines: list[str], block: dict[str, Any]) -> None:
        block_type = block.get("type")
        if block_type == "paragraph":
            text = cls._join_spans(block.get("spans"))
            if text:
                lines.append(text)
            return

        if block_type == "bullet_list":
            for item in block.get("items") or []:
                if not isinstance(item, dict):
                    continue
                text = cls._join_spans(item.get("spans"))
                if text:
                    lines.append(f"- {text}")
            return

        if block_type == "key_value":
            for item in block.get("items") or []:
                if not isinstance(item, dict):
                    continue
                key = str(item.get("key") or "").strip()
                value = cls._join_spans(item.get("value"))
                if key and value:
                    lines.append(f"{key}: {value}")
                elif key:
                    lines.append(key)
                elif value:
                    lines.append(value)

    @classmethod
    def _append_generic_value(cls, lines: list[str], value: Any, level: int) -> None:
        if isinstance(value, dict):
            for key, nested in value.items():
                if nested is None:
                    continue
                label = key.replace("_", " ").strip().capitalize()
                indent = "  " * level
                if isinstance(nested, str):
                    content = nested.strip()
                    if content:
                        lines.append(f"{indent}{label}: {content}")
                    continue
                if isinstance(nested, dict):
                    marker = f"{indent}{label}:"
                    before = len(lines)
                    cls._append_generic_value(lines, nested, level + 1)
                    if len(lines) > before:
                        lines.insert(before, marker)
                    continue
                if isinstance(nested, list):
                    before = len(lines)
                    cls._append_generic_list(lines, nested, level + 1)
                    if len(lines) > before:
                        lines.insert(before, f"{indent}{label}:")
                    continue
                lines.append(f"{indent}{label}: {nested}")
            return

        if isinstance(value, list):
            cls._append_generic_list(lines, value, level)

    @classmethod
    def _append_generic_list(cls, lines: list[str], values: list[Any], level: int) -> None:
        indent = "  " * level
        for item in values:
            if item is None:
                continue
            if isinstance(item, dict):
                marker_index = len(lines)
                lines.append(f"{indent}-")
                before = len(lines)
                cls._append_generic_value(lines, item, level + 1)
                if len(lines) == before:
                    lines.pop(marker_index)
                continue
            if isinstance(item, list):
                cls._append_generic_list(lines, item, level + 1)
                continue
            text = str(item).strip()
            if text:
                lines.append(f"{indent}- {text}")

    @staticmethod
    def _join_spans(spans: Any) -> str:
        if not isinstance(spans, list):
            return ""
        return "".join(
            str(span.get("text", ""))
            for span in spans
            if isinstance(span, dict)
        ).strip()
