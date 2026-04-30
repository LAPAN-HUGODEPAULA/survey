"""Repository for searching reference medications."""

import re

from pymongo.database import Database

from app.domain.models.reference_medication_model import ReferenceMedication


class ReferenceMedicationRepository:
    """Read-only access to the reference medications collection."""

    COLLECTION_NAME = "reference_medications"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]

    def list_all(self, limit: int = 500) -> list[ReferenceMedication]:
        """Return the full medication catalog up to a safe upper bound."""
        safe_limit = max(1, min(limit, 2000))
        cursor = self._col.find(
            {},
            {"_id": 0, "substance": 1, "category": 1, "trade_names": 1, "search_vector": 1},
        ).sort("substance", 1).limit(safe_limit)
        return [ReferenceMedication(**doc) for doc in cursor]

    def search(self, query: str, limit: int = 10) -> list[ReferenceMedication]:
        """Return medications whose search vector matches the query."""
        normalized = query.strip().lower()
        if len(normalized) < 3:
            return []

        safe_limit = max(1, min(limit, 50))
        regex = re.escape(normalized)
        cursor = self._col.find(
            {"search_vector": {"$regex": regex, "$options": "i"}},
            {"_id": 0, "substance": 1, "category": 1, "trade_names": 1, "search_vector": 1},
        ).limit(safe_limit)
        return [ReferenceMedication(**doc) for doc in cursor]

    def upsert_manual(self, substance: str) -> ReferenceMedication:
        """Store a user-provided medication entry if it does not exist yet."""
        normalized = substance.strip()
        lowered = normalized.lower()
        self._col.update_one(
            {"substance": {"$regex": f"^{re.escape(normalized)}$", "$options": "i"}},
            {
                "$setOnInsert": {
                    "substance": normalized,
                    "category": "manual",
                    "trade_names": [],
                    "search_vector": [lowered],
                }
            },
            upsert=True,
        )
        found = self._col.find_one(
            {"substance": {"$regex": f"^{re.escape(normalized)}$", "$options": "i"}},
            {"_id": 0, "substance": 1, "category": 1, "trade_names": 1, "search_vector": 1},
        )
        return ReferenceMedication(**(found or {
            "substance": normalized,
            "category": "manual",
            "trade_names": [],
            "search_vector": [lowered],
        }))
