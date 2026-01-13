from pymongo.database import Database
from bson import ObjectId


class ClinicalWriterRunLogRepository:
    def __init__(self, db: Database):
        self._col = db["clinical_writer_run_logs"]

    def create(self, doc: dict) -> dict:
        result = self._col.insert_one(doc)
        created = self._col.find_one({"_id": result.inserted_id})
        return self._normalize(created)

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        return doc
