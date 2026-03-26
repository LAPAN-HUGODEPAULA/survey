"""Repository for screener-facing survey response documents."""

from pymongo.database import Database
from bson import ObjectId


class SurveyResponseRepository:
    """Persist survey responses while hiding worker-only enrichment metadata."""

    COLLECTION_NAME = "survey_responses"
    INTERNAL_FIELDS = {
        "agentResponse",
        "agentResponseStatus",
        "agentResponseUpdatedAt",
    }

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]

    def create(self, doc: dict) -> dict:
        result = self._col.insert_one(doc)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        return [self._normalize(x) for x in self._col.find()]

    def _normalize(self, doc: dict | None) -> dict:
        """Convert Mongo IDs and strip internal enrichment fields for plain API reads."""
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        return {
            key: value
            for key, value in normalized.items()
            if key not in self.INTERNAL_FIELDS
        }
