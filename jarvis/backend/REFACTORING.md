# JARVIS AI Backend Refactoring Summary

## Overview

The JARVIS AI backend has been refactored to support **hybrid online/offline operation**, enabling seamless switching between cloud-based AI services (OpenAI, ElevenLabs) and local alternatives (Ollama, Whisper, Piper TTS).

## Key Changes

### 1. Enhanced Configuration (`core/config.py`)

**New Features:**
- `OperationMode` enum: `auto`, `online`, `offline`
- Dual database URLs (PostgreSQL for online, SQLite for offline)
- Local AI model configuration (Ollama, Piper TTS)
- Feature flags for modular functionality
- Rate limiting and monitoring settings

**Key Settings:**
```python
OPERATION_MODE = "auto"  # Auto-switch based on connectivity
DATABASE_URL_OFFLINE = "sqlite:///./jarvis_offline.db"
OLLAMA_BASE_URL = "http://localhost:11434"
OLLAMA_MODEL = "llama3.1:8b"
VECTOR_DB_PROVIDER = "chromadb"  # Works offline
```

### 2. Connectivity Manager (`core/connectivity.py`) - NEW

**Purpose:** Manages internet connectivity detection and mode switching.

**Features:**
- Automatic connectivity checking with multiple URL fallbacks
- Periodic health checks (configurable interval)
- Listener pattern for reactive mode changes
- Status reporting API

**Usage:**
```python
from core.connectivity import get_connectivity_manager

connectivity = get_connectivity_manager()
is_online = connectivity.is_online
status = connectivity.get_status_dict()
```

### 3. Updated Main Application (`main.py`)

**Enhancements:**
- Proper logging configuration
- Connectivity initialization on startup
- New `/status` endpoint with detailed system information
- WebSocket status message type for real-time updates
- Online/offline-aware message processing

**New Endpoints:**
- `GET /status` - Detailed system status including connectivity, features, and AI models
- `GET /health` - Enhanced with connectivity status
- `GET /` - Now includes operation mode and online status

### 4. Updated Requirements (`requirements.txt`)

**New Dependencies:**
- `aiohttp` - For async HTTP connectivity checks
- `ollama` - Python client for local LLM inference

**Organized Sections:**
- Core Framework
- HTTP & WebSockets
- AI & LangChain (Online)
- AI - Offline (Local Models)
- Vector Databases
- Databases
- Authentication
- Utilities
- Automation
- Browser Automation
- Document Processing
- Image Processing
- Testing
- Development

### 5. Environment Configuration (`.env.example`)

**Comprehensive Template:**
- All configuration options documented
- Clear separation between online and offline settings
- URLs for obtaining API keys
- Secure defaults with reminders to change production values

## Architecture

### Online Mode
```
User → FastAPI → OpenAI GPT-4 → ElevenLabs TTS → Pinecone Vector DB → PostgreSQL
```

### Offline Mode
```
User → FastAPI → Ollama (Llama 3.1) → Piper TTS → ChromaDB → SQLite
```

### Auto Mode
```
┌─────────────────────────────────────────────┐
│         Connectivity Manager                │
│  ┌─────────────────────────────────────┐    │
│  │  Check Internet Every 60 Seconds    │    │
│  └─────────────────────────────────────┘    │
│              ↓                               │
│  ┌─────────────────┐  ┌──────────────────┐  │
│  │    Online       │  │     Offline      │  │
│  │  • OpenAI       │  │  • Ollama        │  │
│  │  • ElevenLabs   │  │  • Piper TTS     │  │
│  │  • Pinecone     │  │  • ChromaDB      │  │
│  │  • PostgreSQL   │  │  • SQLite        │  │
│  └─────────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────┘
```

## Migration Guide

### For Existing Deployments

1. **Update `.env` file:**
   ```bash
   cp backend/.env.example backend/.env
   # Edit with your existing values + new settings
   ```

2. **Install new dependencies:**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

3. **Start Ollama (for offline support):**
   ```bash
   # Install from https://ollama.ai
   ollama pull llama3.1:8b
   ollama pull nomic-embed-text
   ```

4. **Run the application:**
   ```bash
   python main.py
   ```

### Configuration Examples

**Cloud-Only (Original Behavior):**
```env
OPERATION_MODE=online
OPENAI_API_KEY=sk-...
ELEVENLABS_API_KEY=...
PINECONE_API_KEY=...
DATABASE_URL=postgresql://...
```

**Offline-Only (Privacy-Focused):**
```env
OPERATION_MODE=offline
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.1:8b
PIPER_TTS_ENABLED=true
DATABASE_URL_OFFLINE=sqlite:///./jarvis.db
```

**Hybrid (Recommended):**
```env
OPERATION_MODE=auto
# Set both online and offline credentials
OPENAI_API_KEY=sk-...
OLLAMA_BASE_URL=http://localhost:11434
```

## API Changes

### Response Format Updates

All endpoints now include connectivity context where relevant:

**Root Endpoint (`GET /`):**
```json
{
  "name": "JARVIS AI",
  "version": "1.0.0",
  "status": "running",
  "operation_mode": "auto",
  "is_online": true,
  "message": "Welcome to JARVIS AI Assistant"
}
```

**Health Check (`GET /health`):**
```json
{
  "status": "healthy",
  "operation_mode": "auto",
  "is_online": true,
  "connectivity": {
    "is_online": true,
    "last_check": "2024-01-01T12:00:00Z",
    "check_duration_ms": 245,
    "failed_urls": [],
    "mode": "auto"
  }
}
```

**System Status (`GET /status`):**
```json
{
  "application": {
    "name": "JARVIS AI",
    "version": "1.0.0",
    "debug": true
  },
  "connectivity": {...},
  "features": {
    "agents": true,
    "plugins": true,
    "browser_automation": true,
    "voice": true,
    "vision": true
  },
  "ai_models": {
    "online": {
      "provider": "openai",
      "model": "gpt-4-turbo-preview",
      "tts": "elevenlabs"
    },
    "offline": {
      "provider": "ollama",
      "model": "llama3.1:8b",
      "embedding": "nomic-embed-text"
    }
  },
  "database": {
    "provider": "postgresql",
    "vector_db": "chromadb"
  }
}
```

## Benefits

1. **Resilience:** Continues working during internet outages
2. **Privacy:** Can run entirely locally when needed
3. **Cost Optimization:** Use local models for routine tasks, cloud for complex queries
4. **Flexibility:** Switch modes without code changes
5. **Transparency:** Real-time visibility into system status and mode

## Next Steps

1. Implement LangChain integration for online chat processing
2. Add Ollama integration for offline chat processing
3. Implement ElevenLabs/Piper TTS routing
4. Add vector database abstraction layer
5. Create database models for SQLAlchemy
6. Implement proper authentication with dual-mode support

## Testing

```bash
# Run tests
pytest tests/ -v

# Test connectivity manager
python -c "from core.connectivity import get_connectivity_manager; print(get_connectivity_manager().get_status_dict())"

# Test configuration
python -c "from core.config import settings; print(settings.OPERATION_MODE)"
```

## Support

For issues or questions:
- Check the updated `.env.example` for configuration options
- Review `core/config.py` for all available settings
- Monitor logs for connectivity status messages
