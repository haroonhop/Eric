"""
JARVIS AI Backend Package
Intelligent Personal Assistant with Online/Offline Hybrid Support
"""

__version__ = "1.0.0"
__author__ = "JARVIS Team"


from .core.config import settings
from .core.websocket_manager import ConnectionManager

__all__ = ["settings", "ConnectionManager"]