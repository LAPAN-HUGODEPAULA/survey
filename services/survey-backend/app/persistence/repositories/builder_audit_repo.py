"""Repository for builder audit records."""

from datetime import datetime, timedelta
from typing import Optional

from bson import ObjectId
from pymongo import IndexModel, ASCENDING, DESCENDING
from pymongo.database import Database

from app.domain.models.audit_models import BuilderAuditLog, BuilderAuditCreate


class BuilderAuditRepository:
    """Repository for managing builder audit records."""

    def __init__(self, db: Database):
        self._collection = db["builder_audit"]

    def initialize_indexes(self) -> None:
        """Create optimized indexes for audit queries."""
        indexes = [
            IndexModel([("correlationId", ASCENDING)]),
            IndexModel([("actor.id", ASCENDING)]),
            IndexModel([("resource.id", ASCENDING)]),
            IndexModel([("resource.type", ASCENDING)]),
            IndexModel([("createdAt", DESCENDING)]),
            IndexModel([("namespace", ASCENDING), ("operation", ASCENDING)]),
            IndexModel([("eventType", ASCENDING)]),
        ]
        self._collection.create_indexes(indexes)

    def create(self, audit_data: dict) -> BuilderAuditLog:
        """Create a new audit record."""
        audit_data = {
            **audit_data,
            "namespace": audit_data.get("namespace", "builder"),
            "createdAt": audit_data.get("createdAt") or datetime.utcnow(),
        }
        result = self._collection.insert_one(audit_data)
        created = self._collection.find_one({"_id": result.inserted_id})
        return BuilderAuditLog.model_validate(self._normalize(created))

    def list_by_correlation_id(self, correlation_id: str) -> list[BuilderAuditLog]:
        """List all audit records for a correlation ID."""
        cursor = self._collection.find({"correlationId": correlation_id}).sort("createdAt", ASCENDING)
        return [BuilderAuditLog.model_validate(self._normalize(doc)) for doc in cursor]

    def list_by_actor(self, actor_id: str, limit: int = 100) -> list[BuilderAuditLog]:
        """List audit records for a specific actor."""
        cursor = self._collection.find({"actor.id": actor_id}).sort("createdAt", DESCENDING).limit(limit)
        return [BuilderAuditLog.model_validate(self._normalize(doc)) for doc in cursor]

    def list_by_resource(
        self,
        resource_type: str,
        resource_id: str,
        limit: int = 100
    ) -> list[BuilderAuditLog]:
        """List audit records for a specific resource."""
        cursor = self._collection.find(
            {
                "resource.type": resource_type,
                "resource.id": resource_id,
            }
        ).sort("createdAt", DESCENDING).limit(limit)
        return [BuilderAuditLog.model_validate(self._normalize(doc)) for doc in cursor]

    def find_by_id(self, audit_id: str) -> Optional[BuilderAuditLog]:
        """Find an audit record by ID."""
        try:
            object_id = ObjectId(audit_id)
        except Exception:
            return None
        doc = self._collection.find_one({"_id": object_id})
        return BuilderAuditLog.model_validate(self._normalize(doc)) if doc else None

    def cleanup_old_records(self, retention_days: int = 90) -> int:
        """Clean up audit records older than retention period."""
        cutoff_date = datetime.utcnow() - timedelta(days=retention_days)
        result = self._collection.delete_many(
            {
                "createdAt": {"$lt": cutoff_date},
            }
        )
        return result.deleted_count

    def get_statistics(self) -> dict:
        """Get audit statistics for monitoring."""
        pipeline = [
            {
                "$group": {
                    "_id": {
                        "operation": "$operation",
                        "status": "$status",
                        "namespace": "$namespace"
                    },
                    "count": {"$sum": 1}
                }
            },
            {
                "$sort": {"count": -1}
            }
        ]
        results = list(self._collection.aggregate(pipeline))

        # Total records
        total = self._collection.count_documents({})

        # Records in last 24 hours
        yesterday = datetime.utcnow() - timedelta(hours=24)
        recent = self._collection.count_documents(
            {
                "createdAt": {"$gte": yesterday},
            }
        )

        return {
            "total_records": total,
            "recent_records_24h": recent,
            "operation_stats": results
        }

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        return normalized
