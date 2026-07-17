"""
JARVIS AI Main Application Entry Point
Refactored for hybrid online/offline operation
"""
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncio
import json
import logging

from api.routes import chat, voice, automation, memory, agents, plugins, auth
from core.config import settings, OperationMode
from core.websocket_manager import ConnectionManager
from core.connectivity import get_connectivity_manager

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager with connectivity monitoring"""
    # Startup
    logger.info(f"🚀 Starting JARVIS AI Assistant v{settings.VERSION}...")
    logger.info(f"📡 Running on: {settings.HOST}:{settings.PORT}")
    logger.info(f"🔧 Operation Mode: {settings.OPERATION_MODE.value}")
    
    # Initialize connectivity manager
    connectivity = get_connectivity_manager()
    await connectivity.check_connectivity()
    
    # Start periodic connectivity checks in auto mode
    if settings.OPERATION_MODE == OperationMode.AUTO:
        await connectivity.start_periodic_checks(interval_seconds=60)
    
    logger.info(f"🌐 Connectivity Status: {'Online' if connectivity.is_online else 'Offline'}")
    
    yield
    
    # Shutdown
    logger.info("👋 Shutting down JARVIS AI Assistant...")
    await connectivity.stop_periodic_checks()
    await manager.disconnect_all()


app = FastAPI(
    title="JARVIS AI",
    description="Intelligent Personal Assistant API with Online/Offline Support",
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# WebSocket Manager
manager = ConnectionManager()

# Include Routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(chat.router, prefix="/api/chat", tags=["Chat"])
app.include_router(voice.router, prefix="/api/voice", tags=["Voice"])
app.include_router(automation.router, prefix="/api/automation", tags=["Automation"])
app.include_router(memory.router, prefix="/api/memory", tags=["Memory"])
app.include_router(agents.router, prefix="/api/agents", tags=["Agents"])
app.include_router(plugins.router, prefix="/api/plugins", tags=["Plugins"])


@app.get("/")
async def root():
    """Root endpoint with system status"""
    connectivity = get_connectivity_manager()
    return {
        "name": settings.APP_NAME,
        "version": settings.VERSION,
        "status": "running",
        "operation_mode": connectivity.current_mode.value,
        "is_online": connectivity.is_online,
        "message": "Welcome to JARVIS AI Assistant"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint with connectivity status"""
    connectivity = get_connectivity_manager()
    return {
        "status": "healthy",
        "operation_mode": connectivity.current_mode.value,
        "is_online": connectivity.is_online,
        "connectivity": connectivity.get_status_dict()
    }


@app.get("/status")
async def system_status():
    """Detailed system status including connectivity and features"""
    connectivity = get_connectivity_manager()
    return {
        "application": {
            "name": settings.APP_NAME,
            "version": settings.VERSION,
            "debug": settings.DEBUG,
        },
        "connectivity": connectivity.get_status_dict(),
        "features": {
            "agents": settings.FEATURE_AGENTS,
            "plugins": settings.FEATURE_PLUGINS,
            "browser_automation": settings.FEATURE_BROWSER_AUTOMATION,
            "voice": settings.FEATURE_VOICE,
            "vision": settings.FEATURE_VISION,
        },
        "ai_models": {
            "online": {
                "provider": "openai" if settings.OPENAI_API_KEY else None,
                "model": settings.OPENAI_MODEL,
                "tts": "elevenlabs" if settings.ELEVENLABS_API_KEY else None,
            },
            "offline": {
                "provider": "ollama" if settings.OLLAMA_BASE_URL else None,
                "model": settings.OLLAMA_MODEL,
                "embedding": settings.OLLAMA_EMBEDDING_MODEL,
            }
        },
        "database": {
            "provider": "postgresql" if "postgresql" in settings.DATABASE_URL else "sqlite",
            "vector_db": "chromadb" if not settings.PINECONE_API_KEY else "pinecone",
        }
    }


@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    """WebSocket endpoint for real-time communication"""
    await manager.connect(websocket, client_id)
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # Process message based on type
            msg_type = message.get("type", "chat")
            
            if msg_type == "chat":
                # Send to chat processor
                response = await process_chat_message(message, client_id)
                await manager.send_personal_message(response, client_id)
            
            elif msg_type == "voice":
                # Send to voice processor
                response = await process_voice_message(message, client_id)
                await manager.send_personal_message(response, client_id)
            
            elif msg_type == "command":
                # Execute automation command
                response = await execute_command(message, client_id)
                await manager.send_personal_message(response, client_id)
            
            elif msg_type == "status":
                # Return current system status
                connectivity = get_connectivity_manager()
                response = {
                    "type": "status",
                    "data": connectivity.get_status_dict()
                }
                await manager.send_personal_message(response, client_id)
                
    except WebSocketDisconnect:
        manager.disconnect(client_id)
        logger.info(f"Client {client_id} disconnected")


async def process_chat_message(message: dict, client_id: str) -> dict:
    """Process chat messages with online/offline awareness"""
    connectivity = get_connectivity_manager()
    
    # Route to appropriate AI provider based on connectivity
    if connectivity.is_online and settings.OPENAI_API_KEY:
        # Use OpenAI
        logger.debug(f"Processing chat with OpenAI for client {client_id}")
        # TODO: Implement LangChain integration
    else:
        # Use Ollama (local)
        logger.debug(f"Processing chat with Ollama for client {client_id}")
        # TODO: Implement Ollama integration
    
    return {
        "type": "chat_response",
        "content": "Message processed",
        "mode": connectivity.current_mode.value,
        "data": message
    }


async def process_voice_message(message: dict, client_id: str) -> dict:
    """Process voice messages with online/offline awareness"""
    connectivity = get_connectivity_manager()
    
    if connectivity.is_online and settings.ELEVENLABS_API_KEY:
        # Use ElevenLabs
        logger.debug(f"Processing voice with ElevenLabs for client {client_id}")
    else:
        # Use local TTS (Piper or similar)
        logger.debug(f"Processing voice locally for client {client_id}")
    
    return {
        "type": "voice_response",
        "content": "Voice processed",
        "mode": connectivity.current_mode.value,
        "data": message
    }


async def execute_command(message: dict, client_id: str) -> dict:
    """Execute automation commands"""
    if not settings.AUTOMATION_ENABLED:
        return {
            "type": "error",
            "content": "Automation is disabled",
        }
    
    logger.debug(f"Executing command for client {client_id}: {message.get('action')}")
    
    return {
        "type": "command_response",
        "content": "Command executed",
        "data": message
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )
