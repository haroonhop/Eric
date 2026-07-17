from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncio
import json

from api.routes import chat, voice, automation, memory, agents, plugins, auth
from core.config import settings
from core.websocket_manager import ConnectionManager


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    # Startup
    print(f"🚀 Starting JARVIS AI Assistant...")
    print(f"📡 Running on: {settings.HOST}:{settings.PORT}")
    yield
    # Shutdown
    print(f"👋 Shutting down JARVIS AI Assistant...")


app = FastAPI(
    title="JARVIS AI",
    description="Intelligent Personal Assistant API",
    version="1.0.0",
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
    """Root endpoint"""
    return {
        "name": "JARVIS AI",
        "version": "1.0.0",
        "status": "running",
        "message": "Welcome to JARVIS AI Assistant"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


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
                response = await process_chat_message(message)
                await manager.send_personal_message(response, client_id)
            
            elif msg_type == "voice":
                # Send to voice processor
                response = await process_voice_message(message)
                await manager.send_personal_message(response, client_id)
            
            elif msg_type == "command":
                # Execute automation command
                response = await execute_command(message)
                await manager.send_personal_message(response, client_id)
                
    except WebSocketDisconnect:
        manager.disconnect(client_id)
        print(f"Client {client_id} disconnected")


async def process_chat_message(message: dict) -> dict:
    """Process chat messages"""
    # Implementation will use LangChain and LLM
    return {
        "type": "chat_response",
        "content": "Message processed",
        "data": message
    }


async def process_voice_message(message: dict) -> dict:
    """Process voice messages"""
    # Implementation will use Whisper and TTS
    return {
        "type": "voice_response",
        "content": "Voice processed",
        "data": message
    }


async def execute_command(message: dict) -> dict:
    """Execute automation commands"""
    # Implementation will use automation module
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
        reload=settings.DEBUG
    )
