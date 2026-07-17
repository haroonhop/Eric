@echo off
REM ==================== JARVIS AI Start Script for Windows ====================
REM This script starts both backend and frontend servers
REM ============================================================================

setlocal enabledelayedexpansion

REM Color codes
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

REM Set console to UTF-8
chcp 65001 >nul 2>&1

echo %GREEN%
echo ╔═══════════════════════════════════════════════════════════╗
echo ║              JARVIS AI - Starting Servers                 ║
echo ╚═══════════════════════════════════════════════════════════╝
echo %RESET%

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check if virtual environment exists
if not exist "backend\venv\Scripts\activate.bat" (
    echo %RED%Error: Virtual environment not found in backend folder%RESET%
    echo Please run setup.bat first to install dependencies
    pause
    exit /b 1
)

REM Check if node_modules exists
if not exist "frontend\node_modules" (
    echo %RED%Error: Node modules not found in frontend folder%RESET%
    echo Please run setup.bat first to install dependencies
    pause
    exit /b 1
)

echo %BLUE%Starting JARVIS AI Assistant...%RESET%
echo.

REM Start backend in a new window
echo %GREEN%Starting Backend Server...%RESET%
start "JARVIS Backend" cmd /k "cd backend && venv\Scripts\activate && python main.py"

REM Wait a moment for backend to initialize
timeout /t 3 /nobreak >nul

REM Start frontend in a new window
echo %GREEN%Starting Frontend Server...%RESET%
start "JARVIS Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo %GREEN%================================================================%RESET%
echo %GREEN%              SERVERS STARTING...                               %RESET%
echo %GREEN%================================================================%RESET%
echo.
echo %BLUE%Backend:%RESET%  http://localhost:8000
echo %BLUE%Frontend:%RESET% http://localhost:5173
echo.
echo %YELLOW%Both servers are starting in separate windows.%RESET%
echo %YELLOW%You can close this window once both servers are running.%RESET%
echo.
echo %BLUE%To stop the servers:%RESET%
echo   - Close the backend and frontend command windows
echo   - Or press Ctrl+C in each window
echo.
echo %YELLOW%Opening browser in 5 seconds...%RESET%

timeout /t 5 /nobreak >nul

REM Try to open browser
start http://localhost:5173

echo.
echo %GREEN%Done!%RESET%
pause
