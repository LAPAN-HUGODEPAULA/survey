"""Seed the reference_medications collection from the medication CSV."""

from __future__ import annotations

import csv
from pathlib import Path

from app.persistence.mongo.client import get_db

CSV_PATH = (
    Path(__file__).resolve().parents[3]
    / "apps"
    / "survey-patient"
    / "assets"
    / "data"
    / "psychiatric_medications_list.csv"
)
COLLECTION_NAME = "reference_medications"


def _split_trade_names(raw: str) -> list[str]:
    return [item.strip() for item in raw.split(";") if item.strip()]


def _build_search_vector(
    substance: str,
    category: str,
    trade_names: list[str],
) -> list[str]:
    values = [substance, category, *trade_names]
    deduped: list[str] = []
    seen: set[str] = set()
    for value in values:
        normalized = value.strip().lower()
        if not normalized or normalized in seen:
            continue
        seen.add(normalized)
        deduped.append(normalized)
    return deduped


def seed_reference_medications() -> tuple[int, int]:
    """Upsert medications from CSV and ensure search index."""
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"Medication CSV not found at {CSV_PATH}")

    db = get_db()
    collection = db[COLLECTION_NAME]

    processed = 0
    upserted = 0
    with CSV_PATH.open(newline="", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            substance = (row.get("Substance") or "").strip()
            category = (row.get("Category") or "").strip()
            trade_names = _split_trade_names(row.get("Common Trade Names") or "")
            if not substance:
                continue

            document = {
                "substance": substance,
                "category": category,
                "trade_names": trade_names,
                "search_vector": _build_search_vector(substance, category, trade_names),
            }

            result = collection.update_one(
                {"substance": substance},
                {"$set": document},
                upsert=True,
            )
            processed += 1
            if result.upserted_id is not None or result.modified_count > 0:
                upserted += 1

    collection.create_index([("search_vector", "text")], name="search_vector_text_idx")
    return processed, upserted


def main() -> None:
    """Run the seeding process and print a concise summary."""
    processed, upserted = seed_reference_medications()
    print(
        f"Seeded {processed} medications into '{COLLECTION_NAME}' "
        f"(inserted/updated: {upserted})."
    )


if __name__ == "__main__":
    main()
