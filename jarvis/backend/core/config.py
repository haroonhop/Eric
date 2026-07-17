"""
JARVIS AI Core Configuration
Supports hybrid online/offline operation modes
"""
from pydantic_settings import BaseSettings
from typing import List, Optional, Literal
from enum import Enum


class OperationMode(str, Enum):
    """Operation mode for JARVIS"""
    AUTO = "auto"  # Automatically switch based on connectivity
    ONLINE = "online"  # Force online mode
    OFFLINE = "offline"  # Force offline mode


class Settings(BaseSettings):
    """Application settings with online/offline support"""
    
    # ==================== Application ====================
    APP_NAME: str = "JARVIS AI"
    VERSION: str = "1.0.0"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    LOG_LEVEL: str = "INFO"
    
    # ==================== Operation Mode ====================
    OPERATION_MODE: OperationMode = OperationMode.AUTO
    CONNECTIVITY_CHECK_URL: str = "https://www.google.com"
    CONNECTIVITY_TIMEOUT: int = 5
    
    # ==================== Database ====================
    # Online: PostgreSQL, Offline: SQLite
    DATABASE_URL: str = "postgresql://jarvis:jarvis@localhost:5432/jarvis"
    DATABASE_URL_OFFLINE: str = "sqlite:///./jarvis_offline.db"
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_URL_OFFLINE: str = ""  # Disabled in offline mode
    
    # ==================== Authentication ====================
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # ==================== AI Models - Online ====================
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4-turbo-preview"
    OPENAI_EMBEDDING_MODEL: str = "text-embedding-3-small"
    ELEVENLABS_API_KEY: str = ""
    ELEVENLABS_VOICE_ID: str = ""
    PINECONE_API_KEY: str = ""
    PINECONE_ENVIRONMENT: str = "us-west1-gcp"
    
    # ==================== AI Models - Offline ====================
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "llama3.1:8b"
    OLLAMA_EMBEDDING_MODEL: str = "nomic-embed-text"
    WHISPER_MODEL: str = "base"  # Can run locally
    PIPER_TTS_ENABLED: bool = False
    PIPER_TTS_VOICE: str = "en_US-lessac-medium"
    
    # ==================== Vector Database ====================
    # Online: Pinecone, Offline: ChromaDB
    VECTOR_DB_PROVIDER: Literal["pinecone", "chromadb"] = "chromadb"
    CHROMA_DB_PATH: str = "./chroma_db"
    
    # ==================== CORS ====================
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://localhost:5173",
    ]
    
    # ==================== WebSocket ====================
    WS_MAX_MESSAGE_SIZE: int = 10 * 1024 * 1024  # 10MB
    WS_PING_INTERVAL: int = 30
    WS_PING_TIMEOUT: int = 10
    
    # ==================== Automation ====================
    AUTOMATION_ENABLED: bool = True
    AUTOMATION_SAFE_MODE: bool = True  # Require confirmation for destructive actions
    
    # ==================== Storage ====================
    STORAGE_PROVIDER: Literal["local", "s3", "firebase"] = "local"
    STORAGE_PATH: str = "./storage"
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_S3_BUCKET: str = "jarvis-storage"
    AWS_REGION: str = "us-east-1"
    
    # ==================== Features ====================
    FEATURE_AGENTS: bool = True
    FEATURE_PLUGINS: bool = True
    FEATURE_BROWSER_AUTOMATION: bool = True
    FEATURE_VOICE: bool = True
    FEATURE_VISION: bool = True
    
    # ==================== Rate Limiting ====================
    RATE_LIMIT_ENABLED: bool = True
    RATE_LIMIT_REQUESTS_PER_MINUTE: int = 60
    
    # ==================== Monitoring ====================
    ENABLE_METRICS: bool = True
    ENABLE_TRACING: bool = False
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"


# Global settings instance
settings = Settings()


def get_effective_database_url() -> str:
    """Get the appropriate database URL based on operation mode"""
    from .connectivity import ConnectivityManager
    
    if settings.OPERATION_MODE == OperationMode.OFFLINE:
        return settings.DATABASE_URL_OFFLINE
    
    if settings.OPERATION_MODE == OperationMode.ONLINE:
        return settings.DATABASE_URL
    
    # Auto mode - check connectivity
    connectivity = ConnectivityManager()
    if connectivity.is_online():
        return settings.DATABASE_URL
    return settings.DATABASE_URL_OFFLINE


def get_vector_db_provider() -> str:
    """Get the appropriate vector database provider based on mode and availability"""
    if settings.OPERATION_MODE == OperationMode.OFFLINE:
        return "chromadb"
    
    if settings.VECTOR_DB_PROVIDER == "pinecone" and settings.PINECONE_API_KEY:
        return "pinecone"
    
    return "chromadb"
