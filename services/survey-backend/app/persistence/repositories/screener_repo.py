from typing import Optional
from pymongo.database import Database
from pymongo.errors import DuplicateKeyError
from bson import ObjectId
from services.survey_backend.app.domain.models.screener_model import ScreenerModel


class ScreenerRepository:
    def __init__(self, db: Database):
        self._col = db["screeners"]
        self._col.create_index("cpf", unique=True)
        self._col.create_index("email", unique=True)

    def create(self, screener: ScreenerModel) -> ScreenerModel:
        try:
            doc = screener.model_dump(by_alias=True, exclude_unset=True)
            result = self._col.insert_one(doc)
            created_screener = self._col.find_one({"_id": result.inserted_id})
            return ScreenerModel.model_validate(self._normalize(created_screener))
        except DuplicateKeyError as e:
            if "cpf" in str(e):
                raise ValueError("CPF já registrado.")
            if "email" in str(e):
                raise ValueError("E-mail já registrado.")
            raise

    def find_by_email(self, email: str) -> Optional[ScreenerModel]:
        screener_data = self._col.find_one({"email": email})
        if screener_data:
            return ScreenerModel.model_validate(self._normalize(screener_data))
        return None

    def update(self, screener_id: str, data_to_update: dict) -> Optional[ScreenerModel]:
        """
        Updates a screener in the database.
        :param screener_id: The ID of the screener to update.
        :param data_to_update: A dictionary containing the fields to update.
        :return: The updated ScreenerModel instance, or None if not found.
        """
        obj_id = ObjectId(screener_id)
        result = self._col.find_one_and_update(
            {"_id": obj_id},
            {"$set": data_to_update},
            return_document=True  # Return the updated document
        )
        if result:
            return ScreenerModel.model_validate(self._normalize(result))
        return None

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        return doc
