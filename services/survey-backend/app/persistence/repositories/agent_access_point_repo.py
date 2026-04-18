"""Mongo-backed repository for agent access-point definitions."""

from datetime import datetime, timezone

from bson import ObjectId
from pymongo.database import Database


class AgentAccessPointRepository:
    """Handles CRUD and runtime lookups for access-point documents."""

    COLLECTION_NAME = "AgentAccessPoints"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]
        self._col.create_index("accessPointKey", unique=True)
        self._col.create_index(
            [("sourceApp", 1), ("flowKey", 1), ("surveyId", 1)],
            name="runtime_lookup_idx",
        )

    def create(self, access_point_data: dict) -> dict:
        timestamp = datetime.now(timezone.utc)
        payload = {
            **access_point_data,
            "createdAt": access_point_data.get("createdAt", timestamp),
            "modifiedAt": timestamp,
        }
        self._col.insert_one(payload)
        created = self._col.find_one({"accessPointKey": payload["accessPointKey"]})
        return self._normalize(created)

    def list_all(self) -> list[dict]:
        return [
            self._normalize(doc)
            for doc in self._col.find().sort(
                [("sourceApp", 1), ("flowKey", 1), ("name", 1), ("accessPointKey", 1)]
            )
        ]

    def get_by_key(self, access_point_key: str) -> dict | None:
        found = self._col.find_one({"accessPointKey": access_point_key})
        return self._normalize(found) if found else None

    def update(self, access_point_key: str, access_point_data: dict) -> dict | None:
        payload = {
            **access_point_data,
            "modifiedAt": datetime.now(timezone.utc),
        }
        payload.pop("createdAt", None)
        self._col.update_one({"accessPointKey": access_point_key}, {"$set": payload})
        updated = self._col.find_one({"accessPointKey": access_point_key})
        return self._normalize(updated) if updated else None

    def delete(self, access_point_key: str) -> bool:
        result = self._col.delete_one({"accessPointKey": access_point_key})
        return result.deleted_count > 0

    def list_for_runtime(
        self,
        *,
        source_app: str,
        flow_key: str,
        survey_id: str | None = None,
    ) -> list[dict]:
        docs: list[dict] = []
        if survey_id:
            docs.extend(
                self._col.find(
                    {
                        "sourceApp": source_app,
                        "flowKey": flow_key,
                        "surveyId": survey_id,
                    }
                ).sort([("name", 1), ("accessPointKey", 1)])
            )
        if not docs:
            docs.extend(
                self._col.find(
                    {
                        "sourceApp": source_app,
                        "flowKey": flow_key,
                        "$or": [{"surveyId": None}, {"surveyId": {"$exists": False}}],
                    }
                ).sort([("name", 1), ("accessPointKey", 1)])
            )
        return [self._normalize(doc) for doc in docs]

    def has_output_profile(self, output_profile: str) -> bool:
        return self._col.count_documents({"outputProfile": output_profile}, limit=1) > 0

    def has_prompt_key(self, prompt_key: str) -> bool:
        return self._col.count_documents({"promptKey": prompt_key}, limit=1) > 0

    def has_persona_skill_key(self, persona_skill_key: str) -> bool:
        return self._col.count_documents({"personaSkillKey": persona_skill_key}, limit=1) > 0

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        allowed_fields = {
            "accessPointKey",
            "name",
            "description",
            "sourceApp",
            "flowKey",
            "surveyId",
            "promptKey",
            "personaSkillKey",
            "outputProfile",
            "createdAt",
            "modifiedAt",
        }
        return {key: value for key, value in normalized.items() if key in allowed_fields}

