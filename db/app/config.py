from pydantic import BaseSettings

class Settings(BaseSettings):
    mongodb_uri: str = "mongodb://admin:secret@mongodb:27017"

    class Config:
        env_file = ".env"

settings = Settings()
