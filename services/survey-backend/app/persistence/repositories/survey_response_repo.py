from pymongo.database import Database
from bson import ObjectId

class SurveyResponseRepository:
    def __init__(self, db: Database):
        self._col = db["survey_results"]

    def create(self, doc: dict) -> dict:
        result = self._col.insert_one(doc)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        return [self._normalize(x) for x in self._col.find()]

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        return doc
