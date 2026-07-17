@echo off
REM ==================== JARVIS AI - Advanced Setup & Management ====================
REM This script provides complete system management for JARVIS AI Assistant
REM Features: Update from GitHub, Setup, Start, Stop, Configuration
REM ============================================================================

setlocal enabledelayedexpansion

REM Color codes
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "CYAN=[96m"
set "MAGENTA=[95m"
set "RESET=[0m"

REM Set console to UTF-8
chcp 65001 >nul 2>&1

REM Get the script directory
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Check if we're in the jarvis folder
if exist "backend" (
    echo %GREEN%✓ Found jarvis folder%RESET%
) else (
    echo %RED%Error: Please place this setup file in the jarvis folder%RESET%
    echo Current directory: %CD%
    pause
    exit /b 1
)

:MAIN_MENU
cls
echo %GREEN%
echo ╔═══════════════════════════════════════════════════════════╗
echo ║           JARVIS AI - Management Console                  ║
echo ║        Hybrid Online/Offline Personal Assistant           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo %RESET%
echo.
echo %BLUE%[1]%RESET% Setup System (First-time installation)
echo %BLUE%[2]%RESET% Update from GitHub
echo %BLUE%[3]%RESET% Update Python Dependencies
echo %BLUE%[4]%RESET% Start JARVIS
echo %BLUE%[5]%RESET% Stop JARVIS
echo %BLUE%[6]%RESET% Configure Environment
echo %BLUE%[7]%RESET% Check System Status
echo %BLUE%[8]%RESET% View Logs
echo %BLUE%[9]%RESET% Exit
echo.
echo %CYAN%Enter your choice (1-9):%RESET%
set /p CHOICE=

if "%CHOICE%"=="1" goto SETUP_SYSTEM
if "%CHOICE%"=="2" goto UPDATE_GITHUB
if "%CHOICE%"=="3" goto UPDATE_DEPS
if "%CHOICE%"=="4" goto START_JARVIS
if "%CHOICE%"=="5" goto STOP_JARVIS
if "%CHOICE%"=="6" goto CONFIGURE_ENV
if "%CHOICE%"=="7" goto CHECK_STATUS
if "%CHOICE%"=="8" goto VIEW_LOGS
if "%CHOICE%"=="9" goto EXIT
goto MAIN_MENU

:SETUP_SYSTEM
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          SYSTEM SETUP WIZARD                      %RESET%
echo %BLUE%===================================================%RESET%
echo.

REM Check Python installation
call :CHECK_PYTHON
if %ERRORLEVEL% neq 0 (
    echo %RED%Python is required but not found.%RESET%
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    goto MAIN_MENU
)

REM Check Node.js installation
call :CHECK_NODEJS
if %ERRORLEVEL% neq 0 (
    echo %RED%Node.js is required but not found.%RESET%
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    goto MAIN_MENU
)

echo.
echo %BLUE%Setting up Backend...%RESET%
cd backend

if not exist "venv" (
    echo Creating Python virtual environment...
    python -m venv venv
    if %ERRORLEVEL% neq 0 (
        echo %RED%Error: Failed to create virtual environment%RESET%
        pause
        goto MAIN_MENU
    )
    echo %GREEN%✓ Virtual environment created%RESET%
) else (
    echo %GREEN%✓ Virtual environment already exists%RESET%
)

call venv\Scripts\activate.bat
echo Upgrading pip...
python -m pip install --upgrade pip --quiet

echo Installing Python dependencies...
pip install -r requirements.txt
if %ERRORLEVEL% neq 0 (
    echo %YELLOW%Warning: Some packages may have failed to install%RESET%
) else (
    echo %GREEN%✓ Backend dependencies installed%RESET%
)

cd ..

echo.
echo %BLUE%Setting up Frontend...%RESET%
cd frontend

echo Installing Node.js dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
    echo %RED%Error: Failed to install frontend dependencies%RESET%
    pause
    goto MAIN_MENU
) else (
    echo %GREEN%✓ Frontend dependencies installed%RESET%
)

cd ..

echo.
echo %BLUE%Creating Environment Files...%RESET%
call :CREATE_ENV_FILES

echo.
echo %BLUE%Installing Playwright Browsers...%RESET%
cd backend
call venv\Scripts\activate.bat
python -m playwright install chromium 2>nul
if %ERRORLEVEL% equ 0 (
    echo %GREEN%✓ Playwright browsers installed%RESET%
) else (
    echo %YELLOW%Note: Playwright will be installed on first run%RESET%
)
cd ..

echo.
echo %GREEN%===================================================%RESET%
echo %GREEN%              SETUP COMPLETE!                      %RESET%
echo %GREEN%===================================================%RESET%
echo.
pause
goto MAIN_MENU

:UPDATE_GITHUB
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          UPDATING FROM GITHUB                     %RESET%
echo %BLUE%===================================================%RESET%
echo.

REM Check if git is available
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%Error: Git is not installed or not in PATH%RESET%
    echo Please install Git from https://git-scm.com/
    pause
    goto MAIN_MENU
)

REM Check if we're in a git repository
if exist ".git" (
    echo Fetching latest changes from GitHub...
    git fetch origin
    
    echo Checking for updates...
    git status
    
    echo.
    set /p CONFIRM="Do you want to pull the latest changes? (Y/N): "
    if /i "!CONFIRM!"=="Y" (
        echo Pulling latest changes...
        git pull origin main
        if %ERRORLEVEL% equ 0 (
            echo %GREEN%✓ Repository updated successfully%RESET%
            echo.
            echo %YELLOW%Note: You may need to update dependencies after pulling changes%RESET%
        ) else (
            echo %RED%Error: Failed to pull changes%RESET%
            echo You may have local modifications that conflict with remote changes
        )
    ) else (
        echo Update cancelled.
    )
) else (
    echo %YELLOW%Note: This is not a Git repository%RESET%
    echo To enable GitHub updates, clone the repository using:
    echo git clone ^<repository-url^> jarvis
    echo.
    echo Alternatively, you can download updates manually from GitHub
)
echo.
pause
goto MAIN_MENU

:UPDATE_DEPS
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          UPDATING DEPENDENCIES                    %RESET%
echo %BLUE%===================================================%RESET%
echo.

echo %BLUE%Updating Python Dependencies...%RESET%
cd backend
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    echo Upgrading pip...
    python -m pip install --upgrade pip --quiet
    echo Updating packages...
    pip install -r requirements.txt --upgrade
    echo %GREEN%✓ Python dependencies updated%RESET%
) else (
    echo %RED%Error: Virtual environment not found. Run setup first.%RESET%
)
cd ..

echo.
echo %BLUE%Updating Node.js Dependencies...%RESET%
cd frontend
if exist "node_modules" (
    call npm update
    echo %GREEN%✓ Node.js dependencies updated%RESET%
) else (
    echo %RED%Error: node_modules not found. Run setup first.%RESET%
)
cd ..

echo.
echo %GREEN%===================================================%RESET%
echo %GREEN%           DEPENDENCIES UPDATED                    %RESET%
echo %GREEN%===================================================%RESET%
echo.
pause
goto MAIN_MENU

:START_JARVIS
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          STARTING JARVIS                          %RESET%
echo %BLUE%===================================================%RESET%
echo.

REM Check if virtual environment exists
if not exist "backend\venv\Scripts\activate.bat" (
    echo %RED%Error: Virtual environment not found%RESET%
    echo Please run setup first (Option 1)
    pause
    goto MAIN_MENU
)

REM Check if node_modules exists
if not exist "frontend\node_modules" (
    echo %RED%Error: Node modules not found%RESET%
    echo Please run setup first (Option 1)
    pause
    goto MAIN_MENU
)

REM Check if backend .env exists
if not exist "backend\.env" (
    echo %YELLOW%Backend .env file not found. Creating default configuration...%RESET%
    call :CREATE_ENV_FILES
)

REM Check if frontend .env exists
if not exist "frontend\.env" (
    echo Creating frontend .env file...
    (
        echo VITE_API_URL=http://localhost:8000
        echo VITE_WS_URL=ws://localhost:8000/ws
        echo VITE_APP_NAME=JARVIS
        echo VITE_APP_VERSION=1.0.0
    ) > frontend\.env
)

echo %BLUE%Starting Backend Server...%RESET%
start "JARVIS Backend" cmd /k "cd backend && venv\Scripts\activate && python main.py"

echo Waiting for backend to initialize...
timeout /t 3 /nobreak >nul

echo %BLUE%Starting Frontend Server...%RESET%
start "JARVIS Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo %GREEN%===================================================%RESET%
echo %GREEN%              SERVERS STARTING                     %RESET%
echo %GREEN%===================================================%RESET%
echo.
echo %BLUE%Backend:%RESET%  http://localhost:8000
echo %BLUE%Frontend:%RESET% http://localhost:5173
echo.
echo %YELLOW%Both servers are starting in separate windows.%RESET%
echo %YELLOW%You can close this window once both servers are running.%RESET%
echo.
echo %CYAN%Opening browser in 5 seconds...%RESET%

timeout /t 5 /nobreak >nul

start http://localhost:5173

echo.
echo %GREEN%Done! Enjoy using JARVIS!%RESET%
echo.
pause
goto MAIN_MENU

:STOP_JARVIS
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          STOPPING JARVIS                          %RESET%
echo %BLUE%===================================================%RESET%
echo.

echo Stopping JARVIS processes...
taskkill /FI "WINDOWTITLE eq JARVIS Backend" /IM cmd.exe /T >nul 2>&1
taskkill /FI "WINDOWTITLE eq JARVIS Frontend" /IM cmd.exe /T >nul 2>&1

REM Also kill any python processes running main.py
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq python.exe" /FO CSV ^| find "main.py"') do (
    taskkill /PID %%i /F >nul 2>&1
)

REM Kill node processes on port 5173
for /f "tokens=5" %%a in ('netstat -aon ^| find ":5173" ^| find "LISTENING"') do (
    for /f "tokens=2" %%b in ('tasklist /FI "PID eq %%a" /FO CSV') do (
        if "%%b"=="node.exe" taskkill /PID %%a /F >nul 2>&1
    )
)

echo %GREEN%✓ JARVIS stopped successfully%RESET%
echo.
pause
goto MAIN_MENU

:CONFIGURE_ENV
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          ENVIRONMENT CONFIGURATION                %RESET%
echo %BLUE%===================================================%RESET%
echo.

echo Current configuration:
if exist "backend\.env" (
    echo.
    echo %CYAN%Backend .env settings:%RESET%
    findstr /V "^#" backend\.env | findstr /V "^$"
) else (
    echo %YELLOW%Backend .env file not found%RESET%
)

echo.
echo %BLUE%Select action:%RESET%
echo [1] Recreate backend .env with defaults
echo [2] Edit backend .env manually
echo [3] Back to menu
echo.
set /p CONFIG_CHOICE=Enter choice (1-3): 

if "%CONFIG_CHOICE%"=="1" (
    call :CREATE_ENV_FILES
    echo %GREEN%✓ Backend .env recreated%RESET%
) else if "%CONFIG_CHOICE%"=="2" (
    if exist "backend\.env" (
        notepad backend\.env
    ) else (
        echo %RED%.env file not found%RESET%
    )
)

goto MAIN_MENU

:CHECK_STATUS
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          SYSTEM STATUS CHECK                      %RESET%
echo %BLUE%===================================================%RESET%
echo.

echo %CYAN%Python Version:%RESET%
python --version 2>&1 | findstr /V "^"
python --version

echo.
echo %CYAN%Node.js Version:%RESET%
node --version 2>&1 | findstr /V "^"
node --version

echo.
echo %CYAN%npm Version:%RESET%
npm --version 2>&1 | findstr /V "^"
npm --version

echo.
echo %CYAN%Git Version:%RESET%
git --version 2>&1 | findstr /V "^"
git --version

echo.
echo %CYAN%Virtual Environment:%RESET%
if exist "backend\venv\Scripts\python.exe" (
    echo %GREEN%✓ Exists%RESET%
    backend\venv\Scripts\python.exe --version
) else (
    echo %RED%✗ Not found%RESET%
)

echo.
echo %CYAN%Node Modules:%RESET%
if exist "frontend\node_modules" (
    echo %GREEN%✓ Installed%RESET%
) else (
    echo %RED%✗ Not found%RESET%
)

echo.
echo %CYAN%Environment Files:%RESET%
if exist "backend\.env" (
    echo %GREEN%✓ Backend .env exists%RESET%
) else (
    echo %RED%✗ Backend .env missing%RESET%
)

if exist "frontend\.env" (
    echo %GREEN%✓ Frontend .env exists%RESET%
) else (
    echo %RED%✗ Frontend .env missing%RESET%
)

echo.
echo %CYAN%Running Processes:%RESET%
tasklist /FI "WINDOWTITLE eq JARVIS*" 2>nul | findstr /V "^INFO:"
echo.

echo %GREEN%===================================================%RESET%
echo.
pause
goto MAIN_MENU

:VIEW_LOGS
echo.
echo %BLUE%===================================================%RESET%
echo %BLUE%          VIEW LOGS                                %RESET%
echo %BLUE%===================================================%RESET%
echo.

if exist "logs" (
    echo Available log files:
    dir /b logs\*.log 2>nul
    if %ERRORLEVEL% equ 0 (
        echo.
        set /p LOGFILE="Enter log file name to view (or press Enter to cancel): "
        if defined LOGFILE (
            if exist "logs\%LOGFILE%" (
                type "logs\%LOGFILE%"
            ) else (
                echo %RED%File not found%RESET%
            )
        )
    ) else (
        echo %YELLOW%No log files found%RESET%
    )
) else (
    echo %YELLOW%No logs directory found%RESET%
    echo Logs will be created when the application runs
)
echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo %GREEN%Thank you for using JARVIS AI Management Console%RESET%
echo.
exit /b 0

REM ==================== Helper Functions ====================

:CHECK_PYTHON
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    exit /b 1
)
echo %GREEN%✓ Python found:%RESET%
python --version
exit /b 0

:CHECK_NODEJS
node --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    exit /b 1
)
echo %GREEN%✓ Node.js found:%RESET%
node --version
exit /b 0

:CREATE_ENV_FILES
echo Creating backend environment file...
(
    echo # ==================== JARVIS AI Configuration ====================
    echo.
    echo # Application Settings
    echo APP_NAME=JARVIS
    echo APP_VERSION=1.0.0
    echo DEBUG=True
    echo HOST=0.0.0.0
    echo PORT=8000
    echo LOG_LEVEL=INFO
    echo.
    echo # Operation Mode: auto, online, offline
    echo OPERATION_MODE=auto
    echo CONNECTIVITY_CHECK_URL=https://www.google.com
    echo CONNECTIVITY_TIMEOUT=5
    echo.
    echo # Database Settings
    echo DATABASE_URL=sqlite:///./jarvis.db
    echo DATABASE_URL_OFFLINE=sqlite:///./jarvis_offline.db
    echo REDIS_URL=redis://localhost:6379/0
    echo.
    echo # Authentication
    echo SECRET_KEY=change-this-secret-key-in-production
    echo ALGORITHM=HS256
    echo ACCESS_TOKEN_EXPIRE_MINUTES=30
    echo.
    echo # Online AI Models (Optional)
    echo OPENAI_API_KEY=
    echo OPENAI_MODEL=gpt-4-turbo-preview
    echo ELEVENLABS_API_KEY=
    echo PINECONE_API_KEY=
    echo.
    echo # Offline AI Models
    echo OLLAMA_BASE_URL=http://localhost:11434
    echo OLLAMA_MODEL=llama3.1:8b
    echo OLLAMA_EMBEDDING_MODEL=nomic-embed-text
    echo.
    echo # Vector Database
    echo VECTOR_DB_PROVIDER=chromadb
    echo CHROMA_DB_PATH=./chroma_db
    echo.
    echo # Feature Flags
    echo FEATURE_AGENTS=True
    echo FEATURE_PLUGINS=True
    echo FEATURE_BROWSER_AUTOMATION=True
    echo FEATURE_VOICE=True
    echo FEATURE_VISION=True
    echo AUTOMATION_ENABLED=True
    echo AUTOMATION_SAFE_MODE=True
    echo.
    echo # CORS
    echo ALLOWED_ORIGINS=["http://localhost:3000","http://localhost:5173"]
) > backend\.env
echo %GREEN%✓ Backend .env created%RESET%

if not exist "frontend\.env" (
    echo Creating frontend environment file...
    (
        echo VITE_API_URL=http://localhost:8000
        echo VITE_WS_URL=ws://localhost:8000/ws
        echo VITE_APP_NAME=JARVIS
        echo VITE_APP_VERSION=1.0.0
    ) > frontend\.env
    echo %GREEN%✓ Frontend .env created%RESET%
)
goto :EOF
