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
        query = {"_id": ObjectId(survey_id)}
        found = self._col.find_one(query)
        return self._normalize(found) if found else None

    def update(self, survey_id: str, survey_data: dict) -> dict | None:
        query = {"_id": ObjectId(survey_id)}
        # Remove _id from survey_data if present, as it should not be updated
        survey_data.pop("_id", None)
        self._col.update_one(query, {"$set": survey_data})
        updated = self._col.find_one(query)
        return self._normalize(updated) if updated else None

    def delete(self, survey_id: str) -> bool:
        query = {"_id": ObjectId(survey_id)}
        result = self._col.delete_one(query)
        return result.deleted_count > 0

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        doc.pop("id", None)
        return doc
