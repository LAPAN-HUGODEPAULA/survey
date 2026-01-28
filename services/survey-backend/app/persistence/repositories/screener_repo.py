from datetime import datetime
from typing import Optional

from bson import ObjectId
from pymongo import ReturnDocument
from pymongo.database import Database
from pymongo.errors import DuplicateKeyError

from app.config.logging_config import logger
from app.domain.models.screener_model import Address, ProfessionalCouncil, ScreenerModel

SYSTEM_SCREENER_ID = "000000000000000000000001"
SYSTEM_SCREENER_EMAIL = "lapan.hugodepaula@gmail.com"


class ScreenerRepository:
    def __init__(self, db: Database):
        self._col = db["screeners"]
        self._col.create_index("cpf", unique=True)
        self._col.create_index("email", unique=True)

    def create(self, screener: ScreenerModel) -> ScreenerModel:
        try:
            doc = self._prepare_doc(screener)
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

    def find_by_id(self, screener_id: str) -> Optional[ScreenerModel]:
        try:
            obj_id = ObjectId(screener_id)
        except Exception:
            return None
        screener_data = self._col.find_one({"_id": obj_id})
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
        update_doc = dict(data_to_update)
        update_doc["updatedAt"] = datetime.utcnow()
        result = self._col.find_one_and_update(
            {"_id": obj_id},
            {"$set": update_doc},
            return_document=ReturnDocument.AFTER,
        )
        if result:
            return ScreenerModel.model_validate(self._normalize(result))
        return None

    def ensure_system_screener(self, password_hash: str) -> ScreenerModel:
        existing = self._col.find_one({"_id": ObjectId(SYSTEM_SCREENER_ID)}) or self._col.find_one(
            {"email": SYSTEM_SCREENER_EMAIL}
        )
        if existing:
            return ScreenerModel.model_validate(self._normalize(existing))

        now = datetime.utcnow()
        system_screener = ScreenerModel(
            id=SYSTEM_SCREENER_ID,
            cpf="00000000000",
            firstName="LAPAN",
            surname="System Screener",
            email=SYSTEM_SCREENER_EMAIL,
            password=password_hash,
            phone="31984831284",
            address=Address(
                postalCode="34000000",
                street="Rua da Paisagem",
                number="220",
                complement="",
                neighborhood="Vale do Sereno",
                city="Nova Lima",
                state="MG",
            ),
            professionalCouncil=ProfessionalCouncil(type="none", registrationNumber=""),
            jobTitle="",
            degree="",
            darvCourseYear=None,
            createdAt=now,
            updatedAt=now,
        )
        doc = self._prepare_doc(system_screener)
        self._col.insert_one(doc)
        created = self._col.find_one({"_id": doc["_id"]})
        logger.info("System screener created with id=%s", SYSTEM_SCREENER_ID)
        return ScreenerModel.model_validate(self._normalize(created))

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        if "_id" in doc and isinstance(doc["_id"], ObjectId):
            doc["_id"] = str(doc["_id"])
        return doc

    def _prepare_doc(self, screener: ScreenerModel) -> dict:
        doc = screener.model_dump(by_alias=True, exclude_unset=True)
        if "_id" in doc and isinstance(doc["_id"], str):
            doc["_id"] = ObjectId(doc["_id"])
        now = datetime.utcnow()
        doc.setdefault("createdAt", now)
        doc["updatedAt"] = now
        return doc
