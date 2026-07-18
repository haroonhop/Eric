from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import Optional, Dict, Any
import os
import subprocess
import platform
from datetime import datetime

router = APIRouter()


class AutomationCommand(BaseModel):
    action: str
    parameters: Optional[Dict[str, Any]] = None


def get_system_info():
    """Get current system information"""
    return {
        "platform": platform.system(),
        "platform_release": platform.release(),
        "platform_version": platform.version(),
        "architecture": platform.machine(),
        "hostname": platform.node(),
        "processor": platform.processor(),
    }


@router.post("/execute")
async def execute_command(command: AutomationCommand):
    """Execute an automation command"""
    action_handlers = {
        "open_app": open_application_handler,
        "close_app": close_application_handler,
        "screenshot": take_screenshot_handler,
        "get_clipboard": get_clipboard_handler,
        "set_clipboard": set_clipboard_handler,
        "create_file": create_file_handler,
        "delete_file": delete_file_handler,
        "create_folder": create_folder_handler,
        "set_volume": set_volume_handler,
        "shutdown": shutdown_handler,
        "restart": restart_handler,
    }
    
    if command.action not in action_handlers:
        raise HTTPException(status_code=400, detail=f"Unknown action: {command.action}")
    
    try:
        result = await action_handlers[command.action](command.parameters)
        return {
            "status": "success",
            "action": command.action,
            "result": result,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def open_application_handler(params: Optional[Dict] = None):
    """Open an application"""
    if not params or "app_name" not in params:
        raise ValueError("app_name parameter required")
    
    app_name = params["app_name"]
    system = platform.system()
    
    try:
        if system == "Windows":
            os.startfile(app_name)
        elif system == "Darwin":
            subprocess.run(["open", "-a", app_name], check=True)
        else:
            subprocess.Popen([app_name])
        
        return {"app": app_name, "action": "opened"}
    except Exception as e:
        raise Exception(f"Failed to open {app_name}: {str(e)}")


async def close_application_handler(params: Optional[Dict] = None):
    """Close an application"""
    if not params or "app_name" not in params:
        raise ValueError("app_name parameter required")
    
    app_name = params["app_name"]
    system = platform.system()
    
    try:
        if system == "Windows":
            subprocess.run(["taskkill", "/IM", f"{app_name}.exe", "/F"], check=False)
        elif system == "Darwin":
            subprocess.run(["pkill", "-f", app_name], check=False)
        else:
            subprocess.run(["pkill", "-f", app_name], check=False)
        
        return {"app": app_name, "action": "closed"}
    except Exception as e:
        return {"app": app_name, "action": "close_attempted", "note": str(e)}


async def take_screenshot_handler(params: Optional[Dict] = None):
    """Take a screenshot"""
    try:
        from PIL import ImageGrab
        screenshot_dir = "./screenshots"
        os.makedirs(screenshot_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"screenshot_{timestamp}.png"
        filepath = os.path.join(screenshot_dir, filename)
        
        screenshot = ImageGrab.grab()
        screenshot.save(filepath)
        
        return {
            "screenshot_path": filepath,
            "timestamp": datetime.now().isoformat(),
            "size": screenshot.size
        }
    except ImportError:
        raise Exception("PIL library not installed. Run: pip install pillow")
    except Exception as e:
        raise Exception(f"Screenshot failed: {str(e)}")


async def get_clipboard_handler(params: Optional[Dict] = None):
    """Get clipboard content"""
    try:
        import pyperclip
        content = pyperclip.paste()
        return {"content": content, "type": "text", "length": len(content)}
    except Exception as e:
        raise Exception(f"Clipboard access failed: {str(e)}")


async def set_clipboard_handler(params: Optional[Dict] = None):
    """Set clipboard content"""
    if not params or "content" not in params:
        raise ValueError("content parameter required")
    
    try:
        import pyperclip
        content = params["content"]
        pyperclip.copy(content)
        return {"status": "success", "content_length": len(content)}
    except Exception as e:
        raise Exception(f"Clipboard write failed: {str(e)}")


async def create_file_handler(params: Optional[Dict] = None):
    """Create a file"""
    if not params or "path" not in params:
        raise ValueError("path parameter required")
    
    path = params["path"]
    content = params.get("content", "")
    
    try:
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return {"path": path, "action": "created", "size": len(content)}
    except Exception as e:
        raise Exception(f"File creation failed: {str(e)}")


async def delete_file_handler(params: Optional[Dict] = None):
    """Delete a file"""
    if not params or "path" not in params:
        raise ValueError("path parameter required")
    
    path = params["path"]
    
    try:
        if os.path.exists(path):
            os.remove(path)
            return {"path": path, "action": "deleted"}
        else:
            return {"path": path, "action": "not_found"}
    except Exception as e:
        raise Exception(f"File deletion failed: {str(e)}")


async def create_folder_handler(params: Optional[Dict] = None):
    """Create a folder"""
    if not params or "path" not in params:
        raise ValueError("path parameter required")
    
    path = params["path"]
    
    try:
        os.makedirs(path, exist_ok=True)
        return {"path": path, "action": "created"}
    except Exception as e:
        raise Exception(f"Folder creation failed: {str(e)}")


async def set_volume_handler(params: Optional[Dict] = None):
    """Set system volume (0-100)"""
    if not params or "level" not in params:
        raise ValueError("level parameter required (0-100)")
    
    level = params["level"]
    if not 0 <= level <= 100:
        raise ValueError("Volume must be between 0 and 100")
    
    system = platform.system()
    
    try:
        if system == "Windows":
            # Use nircmd or PowerShell for Windows volume control
            script = f"""
            Add-Type -TypeDefinition @"
            using System.Runtime.InteropServices;
            public class Volume {{
                [DllImport(\"user32.dll\")]
                public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);
            }}
"@
            """
            # Note: Full implementation requires additional libraries
            return {"volume": level, "note": "Volume control requires additional setup on Windows"}
        elif system == "Darwin":
            subprocess.run(["osascript", "-e", f"set volume output volume {level}"], check=True)
        else:
            # Linux - use amixer
            subprocess.run(["amixer", "set", "Master", f"{level}%"], check=False)
        
        return {"volume": level, "action": "set"}
    except Exception as e:
        return {"volume": level, "note": f"Volume control limited: {str(e)}"}


async def shutdown_handler(params: Optional[Dict] = None):
    """Shutdown the system"""
    delay = params.get("delay", 0) if params else 0
    
    system = platform.system()
    
    async def delayed_shutdown():
        if delay > 0:
            import asyncio
            await asyncio.sleep(delay)
        
        try:
            if system == "Windows":
                subprocess.run(["shutdown", "/s", "/t", "0"], check=False)
            elif system == "Darwin":
                subprocess.run(["sudo", "shutdown", "-h", "now"], check=False)
            else:
                subprocess.run(["sudo", "shutdown", "-h", "now"], check=False)
        except Exception as e:
            print(f"Shutdown failed: {e}")
    
    # Don't actually execute shutdown in API context
    return {"status": "simulated", "action": "shutdown", "delay_seconds": delay, "note": "Shutdown command prepared but not executed for safety"}


async def restart_handler(params: Optional[Dict] = None):
    """Restart the system"""
    delay = params.get("delay", 0) if params else 0
    
    system = platform.system()
    
    async def delayed_restart():
        if delay > 0:
            import asyncio
            await asyncio.sleep(delay)
        
        try:
            if system == "Windows":
                subprocess.run(["shutdown", "/r", "/t", "0"], check=False)
            elif system == "Darwin":
                subprocess.run(["sudo", "shutdown", "-r", "now"], check=False)
            else:
                subprocess.run(["sudo", "shutdown", "-r", "now"], check=False)
        except Exception as e:
            print(f"Restart failed: {e}")
    
    # Don't actually execute restart in API context
    return {"status": "simulated", "action": "restart", "delay_seconds": delay, "note": "Restart command prepared but not executed for safety"}


@router.post("/app/open")
async def open_application(app_name: str):
    """Open an application"""
    return await open_application_handler({"app_name": app_name})


@router.post("/app/close")
async def close_application(app_name: str):
    """Close an application"""
    return await close_application_handler({"app_name": app_name})


@router.post("/screenshot")
async def take_screenshot():
    """Take a screenshot"""
    return await take_screenshot_handler()


@router.get("/clipboard")
async def get_clipboard():
    """Get clipboard content"""
    return await get_clipboard_handler()


@router.post("/clipboard")
async def set_clipboard(content: str):
    """Set clipboard content"""
    return await set_clipboard_handler({"content": content})


@router.post("/file/create")
async def create_file(path: str, content: Optional[str] = None):
    """Create a file"""
    return await create_file_handler({"path": path, "content": content or ""})


@router.post("/file/delete")
async def delete_file(path: str):
    """Delete a file"""
    return await delete_file_handler({"path": path})


@router.post("/folder/create")
async def create_folder(path: str):
    """Create a folder"""
    return await create_folder_handler({"path": path})


@router.post("/system/volume")
async def set_volume(level: int):
    """Set system volume (0-100)"""
    return await set_volume_handler({"level": level})


@router.post("/system/shutdown")
async def shutdown_system(delay: int = 0):
    """Shutdown the system"""
    return await shutdown_handler({"delay": delay})


@router.post("/system/restart")
async def restart_system(delay: int = 0):
    """Restart the system"""
    return await restart_handler({"delay": delay})


@router.get("/system/info")
async def get_system_information():
    """Get detailed system information"""
    return get_system_info()


@router.post("/mouse/move")
async def move_mouse(x: int, y: int):
    """Move mouse to coordinates"""
    try:
        import pyautogui
        pyautogui.moveTo(x, y, duration=0.5)
        return {"status": "success", "position": {"x": x, "y": y}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Mouse movement failed: {str(e)}")


@router.post("/mouse/click")
async def click_mouse(button: str = "left", x: Optional[int] = None, y: Optional[int] = None):
    """Click mouse button"""
    try:
        import pyautogui
        if x is not None and y is not None:
            pyautogui.click(x, y, button=button)
        else:
            pyautogui.click(button=button)
        return {"status": "success", "button": button, "position": {"x": x, "y": y}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Mouse click failed: {str(e)}")


@router.post("/keyboard/type")
async def type_text(text: str):
    """Type text using keyboard"""
    try:
        import pyautogui
        pyautogui.write(text, interval=0.05)
        return {"status": "success", "text": text, "length": len(text)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Keyboard typing failed: {str(e)}")


@router.post("/keyboard/press")
async def press_key(key: str):
    """Press a keyboard key"""
    try:
        import pyautogui
        pyautogui.press(key)
        return {"status": "success", "key": key}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Key press failed: {str(e)}")


@router.post("/keyboard/hotkey")
async def press_hotkey(keys: list):
    """Press a keyboard hotkey combination"""
    try:
        import pyautogui
        pyautogui.hotkey(*keys)
        return {"status": "success", "keys": keys}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Hotkey failed: {str(e)}")
