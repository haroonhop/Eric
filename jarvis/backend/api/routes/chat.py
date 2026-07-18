from fastapi import APIRouter, HTTPException, status, BackgroundTasks
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import uuid
import asyncio

router = APIRouter()

# In-memory storage for demo (replace with database in production)
conversations_db = {}
messages_db = []


class ChatMessage(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    context: Optional[dict] = None


class ChatResponse(BaseModel):
    response: str
    conversation_id: str
    timestamp: str
    metadata: Optional[dict] = None


def generate_response(user_message: str, context: Optional[dict] = None) -> str:
    """Generate AI response based on message content"""
    message_lower = user_message.lower()
    
    # Simple rule-based responses for demonstration
    if any(word in message_lower for word in ["hello", "hi", "hey"]):
        return "Hello! I'm JARVIS, your AI assistant. How can I help you today?"
    elif any(word in message_lower for word in ["how are you", "how're you"]):
        return "I'm functioning optimally! Ready to assist you with any task."
    elif any(word in message_lower for word in ["time", "date"]):
        return f"The current time is {datetime.now().strftime('%H:%M:%S')} on {datetime.now().strftime('%B %d, %Y')}."
    elif any(word in message_lower for word in ["help", "assist"]):
        return "I can help you with chat, voice commands, automation tasks, memory management, and more. What would you like to do?"
    elif any(word in message_lower for word in ["bye", "goodbye", "exit"]):
        return "Goodbye! Feel free to return anytime you need assistance."
    elif any(word in message_lower for word in ["name", "who are you"]):
        return "I'm JARVIS, an intelligent personal assistant powered by AI. I can work both online and offline!"
    elif any(word in message_lower for word in ["thank", "thanks"]):
        return "You're welcome! Is there anything else I can help you with?"
    else:
        return f"I received your message: '{user_message}'. This is a demo response. In production, I'll connect to advanced AI models for intelligent conversations."


@router.post("/message", response_model=ChatResponse)
async def send_message(chat_message: ChatMessage):
    """Send a chat message and get AI response"""
    conversation_id = chat_message.conversation_id or str(uuid.uuid4())
    
    # Store message
    message_record = {
        "id": str(uuid.uuid4()),
        "conversation_id": conversation_id,
        "role": "user",
        "content": chat_message.message,
        "timestamp": datetime.now().isoformat(),
        "context": chat_message.context
    }
    messages_db.append(message_record)
    
    # Generate response
    response_text = generate_response(chat_message.message, chat_message.context)
    
    # Store response
    response_record = {
        "id": str(uuid.uuid4()),
        "conversation_id": conversation_id,
        "role": "assistant",
        "content": response_text,
        "timestamp": datetime.now().isoformat()
    }
    messages_db.append(response_record)
    
    # Update conversation
    if conversation_id not in conversations_db:
        conversations_db[conversation_id] = {
            "id": conversation_id,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            "message_count": 0,
            "pinned": False
        }
    
    conversations_db[conversation_id]["updated_at"] = datetime.now().isoformat()
    conversations_db[conversation_id]["message_count"] += 2
    
    return ChatResponse(
        response=response_text,
        conversation_id=conversation_id,
        timestamp=datetime.now().isoformat(),
        metadata={"model": "jarvis-lite", "tokens_used": len(chat_message.message.split())}
    )


@router.get("/conversation/{conversation_id}")
async def get_conversation(conversation_id: str):
    """Get conversation history"""
    if conversation_id not in conversations_db:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    conversation_messages = [
        msg for msg in messages_db 
        if msg["conversation_id"] == conversation_id
    ]
    
    return {
        "conversation_id": conversation_id,
        "messages": conversation_messages,
        "metadata": conversations_db[conversation_id]
    }


@router.delete("/conversation/{conversation_id}")
async def delete_conversation(conversation_id: str):
    """Delete a conversation"""
    if conversation_id not in conversations_db:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    # Remove messages
    global messages_db
    messages_db = [msg for msg in messages_db if msg["conversation_id"] != conversation_id]
    
    # Remove conversation
    del conversations_db[conversation_id]
    
    return {"status": "deleted", "conversation_id": conversation_id}


@router.get("/conversations")
async def list_conversations(limit: int = 20, offset: int = 0):
    """List all conversations"""
    sorted_convs = sorted(
        conversations_db.values(),
        key=lambda x: x["updated_at"],
        reverse=True
    )
    
    paginated = sorted_convs[offset:offset + limit]
    
    return {
        "conversations": paginated,
        "total": len(sorted_convs),
        "limit": limit,
        "offset": offset
    }


@router.post("/conversation/{conversation_id}/pin")
async def pin_conversation(conversation_id: str):
    """Pin a conversation"""
    if conversation_id not in conversations_db:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    conversations_db[conversation_id]["pinned"] = True
    return {"status": "pinned", "conversation_id": conversation_id}


@router.post("/conversation/{conversation_id}/unpin")
async def unpin_conversation(conversation_id: str):
    """Unpin a conversation"""
    if conversation_id not in conversations_db:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    conversations_db[conversation_id]["pinned"] = False
    return {"status": "unpinned", "conversation_id": conversation_id}


@router.get("/conversation/{conversation_id}/export")
async def export_conversation(conversation_id: str, format: str = "json"):
    """Export conversation in specified format"""
    if conversation_id not in conversations_db:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    conversation_messages = [
        msg for msg in messages_db 
        if msg["conversation_id"] == conversation_id
    ]
    
    return {
        "format": format,
        "conversation_id": conversation_id,
        "messages": conversation_messages,
        "download_url": f"/downloads/{conversation_id}.{format}"
    }
