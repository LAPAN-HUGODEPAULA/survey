"""Repository for searching reference medications."""

import re

from pymongo.database import Database

from app.domain.models.reference_medication_model import ReferenceMedication


class ReferenceMedicationRepository:
    """Read-only access to the reference medications collection."""

    COLLECTION_NAME = "reference_medications"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]

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
