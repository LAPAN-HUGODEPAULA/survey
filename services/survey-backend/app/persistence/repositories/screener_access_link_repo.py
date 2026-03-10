from pymongo.database import Database

from app.domain.models.screener_access_link_model import ScreenerAccessLinkModel


class ScreenerAccessLinkRepository:
    def __init__(self, db: Database):
        self._col = db["screener_access_links"]

    def create(self, link: ScreenerAccessLinkModel) -> ScreenerAccessLinkModel:
        doc = link.model_dump(by_alias=True)
        self._col.insert_one(doc)
        created = self._col.find_one({"_id": link.id})
        return ScreenerAccessLinkModel.model_validate(created)

    def find_by_token(self, token: str) -> ScreenerAccessLinkModel | None:
        doc = self._col.find_one({"_id": token})
        if not doc:
            return None
        return ScreenerAccessLinkModel.model_validate(doc)
