"""Repository for builder audit records."""

from datetime import datetime, timedelta
from typing import List, Optional

from bson import ObjectId
from pymongo import IndexModel, ASCENDING, DESCENDING
from pymongo.database import Database

from app.domain.models.audit_models import BuilderAuditLog, BuilderAuditCreate


class BuilderAuditRepository:
    """Repository for managing builder audit records."""

    def __init__(self, db: Database):
        self._collection = db["builder_audit"]

    async def initialize_indexes(self) -> None:
        """Create optimized indexes for audit queries."""
        indexes = [
            IndexModel([("correlation_id", ASCENDING)]),
            IndexModel([("actor.id", ASCENDING)]),
            IndexModel([("resource.id", ASCENDING)]),
            IndexModel([("resource.type", ASCENDING)]),
            IndexModel([("created_at", DESCENDING)]),
            IndexModel([("namespace", ASCENDING), ("operation", ASCENDING)]),
            IndexModel([("event_type", ASCENDING)]),
        ]
        await self._collection.create_indexes(indexes)

    async def create(self, audit_data: dict) -> BuilderAuditLog:
        """Create a new audit record."""
        result = await self._collection.insert_one(audit_data)
        audit_data["_id"] = str(result.inserted_id)
        return BuilderAuditLog.model_validate(audit_data)

    async def list_by_correlation_id(self, correlation_id: str) -> List[BuilderAuditLog]:
        """List all audit records for a correlation ID."""
        cursor = self._collection.find({"correlation_id": correlation_id})
        return [BuilderAuditLog.model_validate(doc) async for doc in cursor]

    async def list_by_actor(self, actor_id: str, limit: int = 100) -> List[BuilderAuditLog]:
        """List audit records for a specific actor."""
        cursor = self._collection.find({"actor.id": actor_id}).limit(limit)
        return [BuilderAuditLog.model_validate(doc) async for doc in cursor]

    async def list_by_resource(
        self,
        resource_type: str,
        resource_id: str,
        limit: int = 100
    ) -> List[BuilderAuditLog]:
        """List audit records for a specific resource."""
        cursor = self._collection.find({
            "resource.type": resource_type,
            "resource.id": resource_id
        }).limit(limit)
        return [BuilderAuditLog.model_validate(doc) async for doc in cursor]

    async def find_by_id(self, audit_id: str) -> Optional[BuilderAuditLog]:
        """Find an audit record by ID."""
        doc = await self._collection.find_one({"_id": ObjectId(audit_id)})
        return BuilderAuditLog.model_validate(doc) if doc else None

    async def cleanup_old_records(self, retention_days: int = 90) -> int:
        """Clean up audit records older than retention period."""
        cutoff_date = datetime.utcnow() - timedelta(days=retention_days)
        result = await self._collection.delete_many({
            "created_at": {"$lt": cutoff_date}
        })
        return result.deleted_count

    async def get_statistics(self) -> dict:
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
        results = await self._collection.aggregate(pipeline).to_list(None)

        # Total records
        total = await self._collection.count_documents({})

        # Records in last 24 hours
        yesterday = datetime.utcnow() - timedelta(hours=24)
        recent = await self._collection.count_documents({
            "created_at": {"$gte": yesterday}
        })

        return {
            "total_records": total,
            "recent_records_24h": recent,
            "operation_stats": results
        }