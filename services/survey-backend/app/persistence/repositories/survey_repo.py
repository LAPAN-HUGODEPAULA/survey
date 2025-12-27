from pymongo.database import Database
from bson import ObjectId
from typing import Any

class SurveyRepository:
    def __init__(self, db: Database):
        self._col = db["surveys"]

    def create(self, survey_dict: dict) -> dict:
        result = self._col.insert_one(survey_dict)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        return [self._normalize(x) for x in self._col.find()]

    def get_by_id(self, survey_id: str) -> dict | None:
        query = {"id": survey_id}
        found = self._col.find_one(query)
        return self._normalize(found) if found else None

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        return doc
