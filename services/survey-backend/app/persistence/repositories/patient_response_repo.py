"""Repository for patient-facing response documents."""

from pymongo.database import Database
from bson import ObjectId


class PatientResponseRepository:
    """Persist patient responses in the canonical Mongo collection."""

    COLLECTION_NAME = "patient_responses"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]

    def create(self, doc: dict) -> dict:
        result = self._col.insert_one(doc)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        return [self._normalize(x) for x in self._col.find()]

    def _normalize(self, doc: dict | None) -> dict:
        """Convert Mongo IDs into plain strings without mutating the source document."""
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        return normalized
