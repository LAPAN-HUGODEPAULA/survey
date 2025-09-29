import os
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
from .system_settings import settings
from .logging_config import logger

try:
    logger.info(f"Attempting to connect to MongoDB at: {settings.mongodb_uri.split('@')[1] if '@' in settings.mongodb_uri else settings.mongodb_uri}")
    client = MongoClient(settings.mongodb_uri, serverSelectionTimeoutMS=5000)
    
    # Test the connection
    client.admin.command('ping')
    logger.info(f"Successfully connected to MongoDB at: {settings.mongodb_uri.split('@')[1] if '@' in settings.mongodb_uri else settings.mongodb_uri}")
    
    db = client.get_database("survey_db")
    logger.info("Database 'survey_db' selected successfully")
    
except ServerSelectionTimeoutError as e:
    logger.error(f"MongoDB server selection timeout: {e}")
    raise
except ConnectionFailure as e:
    logger.error(f"Failed to connect to MongoDB: {e}")
    raise
except Exception as e:
    logger.error(f"Unexpected error connecting to MongoDB: {e}")
    raise
