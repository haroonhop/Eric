@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: JARVIS AI - Intelligent Personal Assistant
:: Setup, Install, Update, and Run Script for Windows
:: ============================================================================

title JARVIS AI Setup
color 0B

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo  ERROR: Administrator privileges required!
    echo ============================================
    echo.
    echo Please right-click this script and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: Set working directory
cd /d "%~dp0"

:: Configuration
set PYTHON_VERSION=3.11
set NODE_VERSION=20
set VENV_DIR=venv
set BACKEND_DIR=backend
set FRONTEND_DIR=frontend
set DESKTOP_DIR=desktop

:: Colors
set "GREEN=[92m"
set "BLUE=[94m"
set "YELLOW=[93m"
set "RED=[91m"
set "RESET=[0m"

:: ============================================================================
:: Helper Functions
:: ============================================================================

:print_header
echo.
echo ============================================
echo  %~1
echo ============================================
echo.
goto :eof

:print_success
echo %GREEN%%~1%RESET%
goto :eof

:print_error
echo %RED%%~1%RESET%
goto :eof

:print_warning
echo %YELLOW%%~1%RESET%
goto :eof

:check_command
where %1 >nul 2>&1
if %errorLevel% equ 0 (
    return 0
) else (
    return 1
)

:wait_for_completion
if %errorLevel% neq 0 (
    call :print_error "Command failed with error code %errorLevel%"
    if "%~1"=="critical" (
        pause
        exit /b 1
    )
)
goto :eof

:: ============================================================================
:: Main Menu
:: ============================================================================

:main_menu
cls
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                                                          ║
echo ║           JARVIS AI - Intelligent Personal Assistant     ║
echo ║                                                          ║
echo ║   [1] Full Installation (First Time Setup)               ║
echo ║   [2] Update System                                      ║
echo ║   [3] Run JARVIS                                         ║
echo ║   [4] Run Backend Only                                   ║
echo ║   [5] Run Frontend Only                                  ║
echo ║   [6] Run Desktop App                                    ║
echo ║   [7] Check Dependencies                                 ║
echo ║   [8] Clean Environment                                  ║
echo ║   [9] Uninstall                                          ║
echo ║   [0] Exit                                               ║
echo ║                                                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto install_all
if "%choice%"=="2" goto update_system
if "%choice%"=="3" goto run_jarvis
if "%choice%"=="4" goto run_backend
if "%choice%"=="5" goto run_frontend
if "%choice%"=="6" goto run_desktop
if "%choice%"=="7" goto check_dependencies
if "%choice%"=="8" goto clean_environment
if "%choice%"=="9" goto uninstall
if "%choice%"=="0" goto exit_script

call :print_warning "Invalid choice. Please try again."
timeout /t 2 >nul
goto main_menu

:: ============================================================================
:: Installation Functions
:: ============================================================================

:install_all
call :print_header "JARVIS AI - Full Installation"

:: Step 1: Check Python
call :print_header "Step 1: Checking Python Installation"
python --version >nul 2>&1
if %errorLevel% neq 0 (
    call :print_warning "Python not found. Installing Python..."
    winget install Python.Python.3.11 --silent
    call :wait_for_completion critical
) else (
    call :print_success "Python is installed"
    python --version
)
timeout /t 2 >nul

:: Step 2: Check Node.js
call :print_header "Step 2: Checking Node.js Installation"
node --version >nul 2>&1
if %errorLevel% neq 0 (
    call :print_warning "Node.js not found. Installing Node.js..."
    winget install OpenJS.NodeJS.LTS --silent
    call :wait_for_completion critical
) else (
    call :print_success "Node.js is installed"
    node --version
)
timeout /t 2 >nul

:: Step 3: Check Git
call :print_header "Step 3: Checking Git Installation"
git --version >nul 2>&1
if %errorLevel% neq 0 (
    call :print_warning "Git not found. Installing Git..."
    winget install Git.Git --silent
    call :wait_for_completion critical
) else (
    call :print_success "Git is installed"
    git --version
)
timeout /t 2 >nul

:: Step 4: Setup Python Virtual Environment
call :print_header "Step 4: Setting Up Python Virtual Environment"
if not exist "%VENV_DIR%" (
    call :print_success "Creating virtual environment..."
    python -m venv %VENV_DIR%
    call :wait_for_completion critical
) else (
    call :print_success "Virtual environment already exists"
)

:: Activate virtual environment
call %VENV_DIR%\Scripts\activate.bat
call :print_success "Virtual environment activated"
timeout /t 2 >nul

:: Step 5: Install Python Dependencies
call :print_header "Step 5: Installing Python Dependencies"
if exist "%BACKEND_DIR%\requirements.txt" (
    call :print_success "Installing backend dependencies..."
    pip install --upgrade pip
    pip install -r %BACKEND_DIR%\requirements.txt
    call :wait_for_completion
) else (
    call :print_warning "Backend requirements.txt not found. Creating default..."
    mkdir %BACKEND_DIR% 2>nul
    (
        echo fastapi==0.109.0
        echo uvicorn[standard]==0.27.0
        echo python-dotenv==1.0.0
        echo langchain==0.1.0
        echo langgraph==0.0.1
        echo openai==1.10.0
        echo chromadb==0.4.22
        echo pydantic==2.5.3
        echo websockets==12.0
        echo python-jose[cryptography]==3.3.0
        echo passlib[bcrypt]==1.7.4
        echo python-multipart==0.0.6
        echo aiofiles==23.2.1
        echo speechrecognition==3.10.1
        echo pyttsx3==2.90
        echo pillow==10.2.0
        echo numpy==1.26.3
    ) > %BACKEND_DIR%\requirements.txt
    pip install -r %BACKEND_DIR%\requirements.txt
    call :wait_for_completion
)
timeout /t 2 >nul

:: Step 6: Install Frontend Dependencies
call :print_header "Step 6: Installing Frontend Dependencies"
if exist "%FRONTEND_DIR%\package.json" (
    cd %FRONTEND_DIR%
    call :print_success "Installing frontend dependencies..."
    call npm install
    call :wait_for_completion
    cd ..
) else (
    call :print_warning "Frontend package.json not found. Skipping..."
)
timeout /t 2 >nul

:: Step 7: Install Desktop App Dependencies
call :print_header "Step 7: Installing Desktop App Dependencies"
if exist "%DESKTOP_DIR%\package.json" (
    cd %DESKTOP_DIR%
    call :print_success "Installing desktop dependencies..."
    call npm install
    call :wait_for_completion
    cd ..
) else (
    call :print_warning "Desktop package.json not found. Skipping..."
)
timeout /t 2 >nul

:: Step 8: Create Environment Files
call :print_header "Step 8: Creating Environment Configuration"
if not exist "%BACKEND_DIR%\.env" (
    (
        echo # JARVIS AI Environment Configuration
        echo.
        echo # API Keys
        echo OPENAI_API_KEY=your_openai_api_key_here
        echo ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
        echo GOOGLE_API_KEY=your_google_api_key_here
        echo.
        echo # Database
        echo DATABASE_URL=postgresql://jarvis:jarvis@localhost:5432/jarvis
        echo REDIS_URL=redis://localhost:6379
        echo.
        echo # Security
        echo SECRET_KEY=your_secret_key_here_change_in_production
        echo ALGORITHM=HS256
        echo ACCESS_TOKEN_EXPIRE_MINUTES=30
        echo.
        echo # Application
        echo APP_NAME=JARVIS AI
        echo DEBUG=True
        echo HOST=0.0.0.0
        echo PORT=8000
        echo.
        echo # Voice Settings
        echo WAKE_WORD=hey jarvis
        echo VOICE_MODEL=en_US
        echo.
        echo # Memory
        echo VECTOR_DB_URL=http://localhost:8000
        echo MEMORY_ENABLED=True
    ) > %BACKEND_DIR%\.env
    call :print_success "Created .env file in backend directory"
    call :print_warning "IMPORTANT: Update the .env file with your API keys!"
) else (
    call :print_success ".env file already exists"
)
timeout /t 2 >nul

:: Step 9: Initialize Database
call :print_header "Step 9: Initializing Database"
call :print_warning "Note: PostgreSQL should be installed separately"
call :print_warning "Run: winget install PostgreSQL.PostgreSQL"
timeout /t 3 >nul

:: Step 10: Final Setup
call :print_header "Installation Complete!"
call :print_success "JARVIS AI has been successfully installed!"
echo.
echo Next Steps:
echo 1. Update the .env file in the backend directory with your API keys
echo 2. Install and configure PostgreSQL database
echo 3. Run JARVIS using option 3 from the main menu
echo.
pause
goto main_menu

:: ============================================================================
:: Update Functions
:: ============================================================================

:update_system
call :print_header "Updating JARVIS AI System"

:: Update Python dependencies
call :print_header "Updating Python Dependencies"
if exist "%VENV_DIR%\Scripts\activate.bat" (
    call %VENV_DIR%\Scripts\activate.bat
    if exist "%BACKEND_DIR%\requirements.txt" (
        pip install --upgrade -r %BACKEND_DIR%\requirements.txt
        call :wait_for_completion
    )
)

:: Update Frontend
call :print_header "Updating Frontend"
if exist "%FRONTEND_DIR%\package.json" (
    cd %FRONTEND_DIR%
    call npm update
    call :wait_for_completion
    cd ..
)

:: Update Desktop App
call :print_header "Updating Desktop App"
if exist "%DESKTOP_DIR%\package.json" (
    cd %DESKTOP_DIR%
    call npm update
    call :wait_for_completion
    cd ..
)

:: Pull latest code if git repository
call :print_header "Checking for Code Updates"
if exist ".git" (
    git pull origin main
    call :wait_for_completion
)

call :print_success "System update completed!"
pause
goto main_menu

:: ============================================================================
:: Run Functions
:: ============================================================================

:run_jarvis
call :print_header "Starting JARVIS AI"

:: Start backend in background
call :print_success "Starting Backend Server..."
start "JARVIS Backend" cmd /k "cd %CD% && call %VENV_DIR%\Scripts\activate.bat && cd %BACKEND_DIR% && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"

:: Wait for backend to start
call :print_success "Waiting for backend to initialize..."
timeout /t 5 >nul

:: Start frontend
call :print_header "Starting Frontend"
if exist "%FRONTEND_DIR%\package.json" (
    cd %FRONTEND_DIR%
    start "JARVIS Frontend" cmd /k "npm run dev"
    cd ..
) else (
    call :print_warning "Frontend not found. Opening backend only..."
)

call :print_success "JARVIS AI is starting..."
call :print_success "Backend: http://localhost:8000"
call :print_success "Frontend: http://localhost:3000 (if available)"
echo.
pause
goto main_menu

:run_backend
call :print_header "Starting JARVIS Backend"

if exist "%VENV_DIR%\Scripts\activate.bat" (
    call %VENV_DIR%\Scripts\activate.bat
    if exist "%BACKEND_DIR%" (
        cd %BACKEND_DIR%
        python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
        cd ..
    ) else (
        call :print_error "Backend directory not found!"
    )
) else (
    call :print_error "Virtual environment not found! Run installation first."
)

pause
goto main_menu

:run_frontend
call :print_header "Starting JARVIS Frontend"

if exist "%FRONTEND_DIR%\package.json" (
    cd %FRONTEND_DIR%
    npm run dev
    cd ..
) else (
    call :print_error "Frontend not found! Run installation first."
)

pause
goto main_menu

:run_desktop
call :print_header "Starting JARVIS Desktop App"

if exist "%DESKTOP_DIR%\package.json" (
    cd %DESKTOP_DIR%
    npm run electron:dev
    cd ..
) else (
    call :print_error "Desktop app not found! Run installation first."
)

pause
goto main_menu

:: ============================================================================
:: Utility Functions
:: ============================================================================

:check_dependencies
call :print_header "Checking System Dependencies"

echo.
echo === Python ===
python --version 2>&1 || call :print_error "Python not installed"

echo.
echo === Node.js ===
node --version 2>&1 || call :print_error "Node.js not installed"

echo.
echo === npm ===
npm --version 2>&1 || call :print_error "npm not installed"

echo.
echo === Git ===
git --version 2>&1 || call :print_error "Git not installed"

echo.
echo === Virtual Environment ===
if exist "%VENV_DIR%\Scripts\activate.bat" (
    call :print_success "Virtual environment exists"
) else (
    call :print_error "Virtual environment not found"
)

echo.
echo === Backend Dependencies ===
if exist "%BACKEND_DIR%\requirements.txt" (
    call :print_success "Requirements file exists"
) else (
    call :print_error "Requirements file not found"
)

echo.
echo === Frontend Dependencies ===
if exist "%FRONTEND_DIR%\package.json" (
    call :print_success "Package.json exists"
) else (
    call :print_warning "Frontend not initialized"
)

echo.
echo === Environment Configuration ===
if exist "%BACKEND_DIR%\.env" (
    call :print_success ".env file exists"
) else (
    call :print_warning ".env file not found"
)

echo.
pause
goto main_menu

:clean_environment
call :print_header "Cleaning Environment"

set /p confirm="Are you sure you want to clean the environment? (y/n): "
if /i not "%confirm%"=="y" (
    call :print_success "Operation cancelled"
    goto main_menu
)

call :print_warning "Removing virtual environment..."
if exist "%VENV_DIR%" (
    rmdir /s /q %VENV_DIR%
    call :print_success "Virtual environment removed"
)

call :print_warning "Removing node_modules folders..."
if exist "%FRONTEND_DIR%\node_modules" (
    rmdir /s /q %FRONTEND_DIR%\node_modules
)
if exist "%DESKTOP_DIR%\node_modules" (
    rmdir /s /q %DESKTOP_DIR%\node_modules
)

call :print_warning "Removing Python cache..."
for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d"

call :print_success "Environment cleaned!"
pause
goto main_menu

:uninstall
call :print_header "Uninstalling JARVIS AI"

set /p confirm="WARNING: This will remove all JARVIS files. Are you sure? (y/n): "
if /i not "%confirm%"=="y" (
    call :print_success "Operation cancelled"
    goto main_menu
)

call :clean_environment

call :print_warning "Removing configuration files..."
if exist "%BACKEND_DIR%\.env" (
    del %BACKEND_DIR%\.env
)

call :print_warning "Removing logs..."
if exist "logs" (
    rmdir /s /q logs
)

call :print_success "JARVIS AI has been uninstalled!"
call :print_warning "Note: Manual deletion may be required for some files"
pause
goto main_menu

:exit_script
call :print_success "Thank you for using JARVIS AI!"
exit /b 0

:: ============================================================================
:: Script Entry Point
:: ============================================================================

goto main_menu
