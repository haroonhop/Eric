"""
JARVIS AI Core Connectivity Manager
Handles online/offline detection and mode switching
"""
import asyncio
import aiohttp
from typing import Optional, Callable, List
from datetime import datetime, timedelta
import logging

from .config import settings, OperationMode

logger = logging.getLogger(__name__)


class ConnectivityStatus:
    """Represents the current connectivity status"""
    
    def __init__(self):
        self.is_online: bool = False
        self.last_check: Optional[datetime] = None
        self.check_duration_ms: Optional[int] = None
        self.failed_urls: List[str] = []
        self.mode: OperationMode = settings.OPERATION_MODE
    
    def to_dict(self) -> dict:
        return {
            "is_online": self.is_online,
            "last_check": self.last_check.isoformat() if self.last_check else None,
            "check_duration_ms": self.check_duration_ms,
            "failed_urls": self.failed_urls,
            "mode": self.mode.value,
        }


class ConnectivityManager:
    """
    Manages connectivity detection and operation mode switching.
    Supports automatic fallback between online and offline modes.
    """
    
    _instance: Optional["ConnectivityManager"] = None
    _status: ConnectivityStatus = ConnectivityStatus()
    _listeners: List[Callable[[ConnectivityStatus], None]] = []
    _check_task: Optional[asyncio.Task] = None
    
    def __new__(cls) -> "ConnectivityManager":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, "_initialized"):
            self._initialized = True
            self._status.mode = settings.OPERATION_MODE
    
    @property
    def status(self) -> ConnectivityStatus:
        return self._status
    
    @property
    def is_online(self) -> bool:
        """Check if currently online"""
        if self._status.mode == OperationMode.OFFLINE:
            return False
        if self._status.mode == OperationMode.ONLINE:
            return True
        
        # Auto mode - use cached status or check now
        if self._status.last_check is None or \
           datetime.now() - self._status.last_check > timedelta(seconds=30):
            asyncio.create_task(self.check_connectivity())
        
        return self._status.is_online
    
    @property
    def current_mode(self) -> OperationMode:
        """Get current operation mode"""
        return self._status.mode
    
    def set_mode(self, mode: OperationMode) -> None:
        """Set operation mode manually"""
        old_mode = self._status.mode
        self._status.mode = mode
        
        if mode == OperationMode.OFFLINE:
            self._status.is_online = False
        elif mode == OperationMode.ONLINE:
            self._status.is_online = True
        else:
            # Auto mode - check immediately
            asyncio.create_task(self.check_connectivity())
        
        logger.info(f"Operation mode changed: {old_mode.value} -> {mode.value}")
        self._notify_listeners()
    
    async def check_connectivity(self, urls: Optional[List[str]] = None) -> bool:
        """
        Check internet connectivity by testing multiple URLs.
        Returns True if at least one URL is reachable.
        """
        if self._status.mode == OperationMode.OFFLINE:
            self._status.is_online = False
            return False
        
        if self._status.mode == OperationMode.ONLINE:
            self._status.is_online = True
            return True
        
        # Auto mode - actually check
        test_urls = urls or [
            settings.CONNECTIVITY_CHECK_URL,
            "https://www.cloudflare.com",
            "https://www.github.com",
        ]
        
        self._status.last_check = datetime.now()
        self._status.failed_urls = []
        
        start_time = datetime.now()
        
        async with aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=settings.CONNECTIVITY_TIMEOUT)
        ) as session:
            tasks = [self._check_url(session, url) for url in test_urls]
            results = await asyncio.gather(*tasks, return_exceptions=True)
        
        successful = sum(1 for r in results if r is True)
        self._status.is_online = successful > 0
        
        end_time = datetime.now()
        self._status.check_duration_ms = int((end_time - start_time).total_seconds() * 1000)
        
        logger.info(
            f"Connectivity check: {'online' if self._status.is_online else 'offline'} "
            f"({successful}/{len(test_urls)} URLs reachable, "
            f"{self._status.check_duration_ms}ms)"
        )
        
        self._notify_listeners()
        return self._status.is_online
    
    async def _check_url(self, session: aiohttp.ClientSession, url: str) -> bool:
        """Check a single URL for connectivity"""
        try:
            async with session.get(url, allow_redirects=False) as response:
                if response.status < 400:
                    return True
                self._status.failed_urls.append(url)
                return False
        except Exception as e:
            self._status.failed_urls.append(url)
            logger.debug(f"URL {url} unreachable: {e}")
            return False
    
    def add_listener(self, callback: Callable[[ConnectivityStatus], None]) -> None:
        """Add a listener for connectivity changes"""
        self._listeners.append(callback)
    
    def remove_listener(self, callback: Callable[[ConnectivityStatus], None]) -> None:
        """Remove a connectivity listener"""
        if callback in self._listeners:
            self._listeners.remove(callback)
    
    def _notify_listeners(self) -> None:
        """Notify all listeners of connectivity status change"""
        for listener in self._listeners:
            try:
                listener(self._status)
            except Exception as e:
                logger.error(f"Error notifying listener: {e}")
    
    async def start_periodic_checks(self, interval_seconds: int = 60) -> None:
        """Start periodic connectivity checks"""
        if self._check_task is not None:
            self._check_task.cancel()
        
        async def check_loop():
            while True:
                try:
                    await asyncio.sleep(interval_seconds)
                    await self.check_connectivity()
                except asyncio.CancelledError:
                    break
                except Exception as e:
                    logger.error(f"Periodic connectivity check failed: {e}")
        
        self._check_task = asyncio.create_task(check_loop())
        logger.info(f"Started periodic connectivity checks (interval: {interval_seconds}s)")
    
    async def stop_periodic_checks(self) -> None:
        """Stop periodic connectivity checks"""
        if self._check_task:
            self._check_task.cancel()
            try:
                await self._check_task
            except asyncio.CancelledError:
                pass
            self._check_task = None
            logger.info("Stopped periodic connectivity checks")
    
    def get_status_dict(self) -> dict:
        """Get current status as dictionary"""
        return self._status.to_dict()


# Global instance
connectivity_manager = ConnectivityManager()


def get_connectivity_manager() -> ConnectivityManager:
    """Get the global connectivity manager instance"""
    return connectivity_manager
