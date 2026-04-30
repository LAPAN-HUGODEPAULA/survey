"""Repository for global system settings stored in MongoDB."""

from datetime import datetime, timezone

from pymongo.database import Database


class SystemSettingsRepository:
    """Read/write access for global system settings."""

    COLLECTION_NAME = "system_settings"

    def __init__(self, db: Database):
        self._col = db[self.COLLECTION_NAME]
        self._col.create_index("key", unique=True)

    def get_value(self, key: str) -> str | None:
        """Return the setting value for a key."""
        found = self._col.find_one({"key": key})
        if not found:
            return None
        value = found.get("value")
        if value is None:
            return None
        normalized = str(value).strip()
        return normalized if normalized else None

    def set_value(self, key: str, value: str) -> None:
        """Create or update a global setting value."""
        now = datetime.now(timezone.utc)
        payload = {
            "key": key,
            "value": value.strip(),
            "modifiedAt": now,
        }
        self._col.update_one(
            {"key": key},
            {
                "$set": payload,
                "$setOnInsert": {"createdAt": now},
            },
            upsert=True,
        )
