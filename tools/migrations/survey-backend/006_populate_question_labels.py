"""Deprecated label migration kept as a no-op for backward compatibility."""

from __future__ import annotations

def main() -> None:
    print(
        "006_populate_question_labels.py is deprecated. "
        "Question labels must now be declared explicitly in the survey asset JSON files."
    )


if __name__ == "__main__":
    main()
