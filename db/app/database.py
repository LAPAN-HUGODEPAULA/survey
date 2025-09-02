import os
from pymongo import MongoClient
from .config import settings

client = MongoClient(settings.mongodb_uri)
db = client.get_database("survey_db")
