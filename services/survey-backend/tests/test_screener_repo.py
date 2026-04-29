from types import SimpleNamespace

from bson import ObjectId

from app.persistence.repositories.screener_repo import (
    SYSTEM_SCREENER_EMAIL,
    SYSTEM_SCREENER_ID,
    ScreenerRepository,
)


class _FakeCollection:
    def __init__(self) -> None:
        self.docs: list[dict] = []

    def create_index(self, *args, **kwargs) -> None:  # noqa: D401 - test helper
        return None

    def find_one(self, query: dict) -> dict | None:
        for doc in self.docs:
            if all(doc.get(key) == value for key, value in query.items()):
                return dict(doc)
        return None

    def insert_one(self, doc: dict) -> SimpleNamespace:
        stored = dict(doc)
        self.docs.append(stored)
        return SimpleNamespace(inserted_id=stored["_id"])

    def find_one_and_update(
        self,
        query: dict,
        update: dict,
        return_document=None,
    ) -> dict | None:
        for index, doc in enumerate(self.docs):
            if all(doc.get(key) == value for key, value in query.items()):
                updated = dict(doc)
                updated.update(update.get("$set", {}))
                self.docs[index] = updated
                return dict(updated)
        return None


class _FakeDatabase(dict):
    def __getitem__(self, item):  # noqa: D401 - test helper
        return super().setdefault(item, _FakeCollection())


def test_ensure_system_screener_creates_builder_admin() -> None:
    repo = ScreenerRepository(_FakeDatabase())

    screener = repo.ensure_system_screener("hash-123")

    assert screener.email == SYSTEM_SCREENER_EMAIL
    assert screener.id == SYSTEM_SCREENER_ID
    assert screener.isBuilderAdmin is True


def test_ensure_system_screener_promotes_existing_record_to_builder_admin() -> None:
    db = _FakeDatabase()
    collection = db["screeners"]
    collection.docs.append(
        {
            "_id": ObjectId(SYSTEM_SCREENER_ID),
            "cpf": "00000000000",
            "firstName": "LAPAN",
            "surname": "System Screener",
            "email": SYSTEM_SCREENER_EMAIL,
            "password": "hash-123",
            "phone": "31984831284",
            "address": {
                "postalCode": "34000000",
                "street": "Rua da Paisagem",
                "number": "220",
                "complement": "",
                "neighborhood": "Vale do Sereno",
                "city": "Nova Lima",
                "state": "MG",
            },
            "professionalCouncil": {
                "type": "none",
                "registrationNumber": "",
            },
            "jobTitle": "",
            "degree": "",
            "isBuilderAdmin": False,
        }
    )
    repo = ScreenerRepository(db)

    screener = repo.ensure_system_screener("hash-123")

    assert screener.email == SYSTEM_SCREENER_EMAIL
    assert screener.isBuilderAdmin is True
    stored = collection.find_one({"email": SYSTEM_SCREENER_EMAIL})
    assert stored is not None
    assert stored["isBuilderAdmin"] is True
