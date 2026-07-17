@echo off
REM ==================== JARVIS AI - All-in-One Setup & Start ====================
REM This script installs dependencies AND starts the application
REM Place this file in the jarvis folder and double-click to run
REM ============================================================================

setlocal enabledelayedexpansion

REM Color codes
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "CYAN=[96m"
set "RESET=[0m"

REM Set console to UTF-8
chcp 65001 >nul 2>&1

echo %GREEN%
echo ╔═══════════════════════════════════════════════════════════╗
echo ║           JARVIS AI - Setup ^& Launch Wizard              ║
echo ║        Hybrid Online/Offline Personal Assistant           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo %RESET%

REM Get the script directory and navigate to jarvis folder
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check if we're in the jarvis folder, if not try to find it
if exist "backend" (
    echo %GREEN%✓ Found jarvis folder%RESET%
) else (
    echo %RED%Error: Please place this setup file in the jarvis folder%RESET%
    echo Current directory: %CD%
    pause
    exit /b 1
)

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %YELLOW%Note: For best results, run as Administrator.%RESET%
    echo.
)

echo %BLUE%Step 1: Checking Prerequisites...%RESET%
echo ---------------------------------------------------------------

REM Check Python installation
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%Error: Python is not installed or not in PATH%RESET%
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
) else (
    python --version
    echo %GREEN%✓ Python found%RESET%
)

REM Check Node.js installation
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%Error: Node.js is not installed or not in PATH%RESET%
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
) else (
    node --version
    echo %GREEN%✓ Node.js found%RESET%
)

REM Check npm installation
npm --version >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%Error: npm is not installed%RESET%
    pause
    exit /b 1
) else (
    npm --version
    echo %GREEN%✓ npm found%RESET%
)

echo.
echo %BLUE%Step 2: Setting up Backend (Python)%RESET%
echo ---------------------------------------------------------------

cd backend

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating Python virtual environment...
    python -m venv venv
    if %errorLevel% neq 0 (
        echo %RED%Error: Failed to create virtual environment%RESET%
        pause
        exit /b 1
    )
    echo %GREEN%✓ Virtual environment created%RESET%
) else (
    echo %GREEN%✓ Virtual environment already exists%RESET%
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip --quiet

REM Install requirements
echo Installing Python dependencies (this may take a few minutes)...
pip install -r requirements.txt
if %errorLevel% neq 0 (
    echo %YELLOW%Warning: Some packages may have failed to install%RESET%
    echo Continuing with setup...
) else (
    echo %GREEN%✓ Backend dependencies installed%RESET%
)

cd ..

echo.
echo %BLUE%Step 3: Setting up Frontend (Node.js)%RESET%
echo ---------------------------------------------------------------

cd frontend

REM Install node modules
echo Installing Node.js dependencies (this may take a few minutes)...
call npm install
if %errorLevel% neq 0 (
    echo %RED%Error: Failed to install frontend dependencies%RESET%
    pause
    exit /b 1
) else (
    echo %GREEN%✓ Frontend dependencies installed%RESET%
)

cd ..

echo.
echo %BLUE%Step 4: Creating Environment Configuration%RESET%
echo ---------------------------------------------------------------

REM Create backend .env file if it doesn't exist
if not exist "backend\.env" (
    echo Creating backend environment file...
    (
        echo # ==================== JARVIS AI Configuration ====================
        echo.
        echo # Application Settings
        echo APP_NAME=JARVIS
        echo APP_VERSION=1.0.0
        echo DEBUG=True
        echo.
        echo # Server Settings
        echo HOST=0.0.0.0
        echo PORT=8000
        echo.
        echo # Database Settings
        echo DATABASE_URL=sqlite:///./jarvis.db
        echo.
        echo # Redis Settings (optional)
        echo REDIS_URL=redis://localhost:6379
        echo.
        echo # API Keys (Optional - for online mode)
        echo OPENAI_API_KEY=your_openai_api_key_here
        echo ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
        echo PINECONE_API_KEY=your_pinecone_api_key_here
        echo.
        echo # Authentication
        echo SECRET_KEY=your-secret-key-change-this-in-production
        echo ACCESS_TOKEN_EXPIRE_MINUTES=30
        echo.
        echo # Mode Settings
        echo MODE=hybrid
        echo.
        echo # Offline Model Settings
        echo OLLAMA_BASE_URL=http://localhost:11434
        echo LOCAL_MODEL=mistral
        echo.
        echo # Feature Flags
        echo ENABLE_VOICE=True
        echo ENABLE_AUTOMATION=True
        echo ENABLE_BROWSER=True
        echo ENABLE_DOCUMENT_PROCESSING=True
    ) > backend\.env
    echo %GREEN%✓ Backend .env file created%RESET%
) else (
    echo %GREEN%✓ Backend .env file already exists%RESET%
)

REM Create frontend .env file if it doesn't exist
if not exist "frontend\.env" (
    echo Creating frontend environment file...
    (
        echo VITE_API_URL=http://localhost:8000
        echo VITE_WS_URL=ws://localhost:8000/ws
        echo VITE_APP_NAME=JARVIS
        echo VITE_APP_VERSION=1.0.0
    ) > frontend\.env
    echo %GREEN%✓ Frontend .env file created%RESET%
) else (
    echo %GREEN%✓ Frontend .env file already exists%RESET%
)

echo.
echo %BLUE%Step 5: Additional Setup%RESET%
echo ---------------------------------------------------------------

REM Install Playwright browsers
echo Installing Playwright browsers (for browser automation)...
call python -m playwright install chromium 2>nul
if %errorLevel% equ 0 (
    echo %GREEN%✓ Playwright browsers installed%RESET%
) else (
    echo %YELLOW%Note: Playwright installation skipped or will be installed later%RESET%
)

echo.
echo %GREEN%================================================================%RESET%
echo %GREEN%                    SETUP COMPLETE!                             %RESET%
echo %GREEN%================================================================%RESET%
echo.
echo %CYAN%Starting JARVIS AI Assistant...%RESET%
echo.

REM Check if virtual environment exists
if not exist "backend\venv\Scripts\activate.bat" (
    echo %RED%Error: Virtual environment not found%RESET%
    pause
    exit /b 1
)

REM Check if node_modules exists
if not exist "frontend\node_modules" (
    echo %RED%Error: Node modules not found%RESET%
    pause
    exit /b 1
)

echo %BLUE%Starting Backend Server...%RESET%
start "JARVIS Backend" cmd /k "cd backend && venv\Scripts\activate && python main.py"

REM Wait for backend to initialize
timeout /t 3 /nobreak >nul

echo %BLUE%Starting Frontend Server...%RESET%
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
echo %CYAN%Opening browser in 5 seconds...%RESET%

timeout /t 5 /nobreak >nul

REM Try to open browser
start http://localhost:5173

echo.
echo %GREEN%Done! Enjoy using JARVIS!%RESET%
echo.
pause
