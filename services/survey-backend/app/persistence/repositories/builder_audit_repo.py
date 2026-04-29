"""Repository for builder audit records."""

from datetime import datetime, timedelta

from bson import ObjectId
from pymongo import IndexModel, ASCENDING, DESCENDING
from pymongo.database import Database

from app.domain.models.audit_models import BuilderAuditLog


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
        audit_data["_id"] = str(result.inserted_id)
        return BuilderAuditLog.model_validate(self._normalize(audit_data))

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

    def find_by_id(self, audit_id: str) -> BuilderAuditLog | None:
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
        yesterday = datetime.utcnow() - timedelta(hours=24)
        pipeline = [
            {
                "$facet": {
                    "total": [{"$count": "count"}],
                    "recent_24h": [
                        {"$match": {"createdAt": {"$gte": yesterday}}},
                        {"$count": "count"},
                    ],
                    "operation_stats": [
                        {"$group": {
                            "_id": {
                                "operation": "$operation",
                                "status": "$status",
                                "namespace": "$namespace",
                            },
                            "count": {"$sum": 1},
                        }},
                        {"$sort": {"count": -1}},
                    ],
                }
            }
        ]
        results = list(self._collection.aggregate(pipeline))
        facet = results[0] if results else {}
        total_bucket = facet.get("total", [])
        recent_bucket = facet.get("recent_24h", [])
        return {
            "total_records": total_bucket[0]["count"] if total_bucket else 0,
            "recent_records_24h": recent_bucket[0]["count"] if recent_bucket else 0,
            "operation_stats": facet.get("operation_stats", []),
        }

    def _normalize(self, doc: dict | None) -> dict:
        if not doc:
            return {}
        normalized = dict(doc)
        if "_id" in normalized and isinstance(normalized["_id"], ObjectId):
            normalized["_id"] = str(normalized["_id"])
        return normalized
