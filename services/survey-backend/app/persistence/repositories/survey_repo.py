import logging

from pymongo.database import Database
from bson import ObjectId
from typing import Any


logger = logging.getLogger(__name__)


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
        query = self._build_id_query(survey_id)
        found = self._col.find_one(query)
        return self._normalize(found) if found else None

    def update(self, survey_id: str, survey_data: dict) -> dict | None:
        query = self._build_id_query(survey_id)
        # Remove _id from survey_data if present, as it should not be updated
        survey_data.pop("_id", None)
        self._col.update_one(query, {"$set": survey_data})
        updated = self._col.find_one(query)
        return self._normalize(updated) if updated else None

    def delete(self, survey_id: str) -> bool:
        query = self._build_id_query(survey_id)
        result = self._col.delete_one(query)
        return result.deleted_count > 0

    def _build_id_query(self, survey_id: str) -> dict[str, Any]:
        try:
            object_id = ObjectId(survey_id)
        except Exception:
            return {"_id": survey_id}
        return {"_id": {"$in": [object_id, survey_id]}}

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        normalized = dict(doc)
        original_id = normalized.get("_id")
        if isinstance(original_id, ObjectId):
            normalized["_id"] = str(original_id)
        normalized.pop("id", None)
        return self._normalize_prompt_shape(normalized, original_id)

    def _normalize_prompt_shape(self, doc: dict, original_id: Any) -> dict:
        prompt = doc.get("prompt")
        if isinstance(prompt, dict):
            doc["prompt"] = {
                "promptKey": prompt.get("promptKey", ""),
                "name": prompt.get("name", ""),
            }
            doc.pop("promptAssociations", None)
            return doc

        raw_associations = doc.get("promptAssociations")
        if not isinstance(raw_associations, list):
            doc["prompt"] = None
            return doc

        associations = [item for item in raw_associations if isinstance(item, dict)]
        if len(associations) == 1:
            association = associations[0]
            normalized_prompt = {
                "promptKey": association.get("promptKey", ""),
                "name": association.get("name", ""),
            }
            if normalized_prompt["promptKey"] and normalized_prompt["name"]:
                doc["prompt"] = normalized_prompt
                if original_id is not None:
                    self._col.update_one(
                        {"_id": original_id},
                        {
                            "$set": {"prompt": normalized_prompt},
                            "$unset": {"promptAssociations": "", "promptMigrationRequired": ""},
                        },
                    )
            else:
                doc["prompt"] = None
            doc.pop("promptAssociations", None)
            return doc

        if len(associations) > 1:
            doc["prompt"] = None
            if original_id is not None:
                self._col.update_one(
                    {"_id": original_id},
                    {"$set": {"prompt": None, "promptMigrationRequired": True}},
                )
            logger.warning(
                "Survey %s requires manual prompt migration because it still has %d legacy prompt associations",
                doc.get("_id"),
                len(associations),
            )
            doc.pop("promptAssociations", None)
            return doc

        doc["prompt"] = None
        if original_id is not None:
            self._col.update_one(
                {"_id": original_id},
                {
                    "$set": {"prompt": None},
                    "$unset": {"promptAssociations": "", "promptMigrationRequired": ""},
                },
            )
        doc.pop("promptAssociations", None)
        return doc
