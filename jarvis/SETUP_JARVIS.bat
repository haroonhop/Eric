@echo off
REM JARVIS AI - Minimalist Setup & Launch Script
REM Quick commands for setup, update, and run
REM ============================================================================
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
cd /d "%~dp0"

REM Check if in jarvis folder
if not exist "backend" (
    echo Error: Please run from jarvis folder
    pause
    exit /b 1
)

REM Parse command line argument
set "CMD=%~1"

if "%CMD%"=="" goto MENU
if /i "%CMD%"=="setup" goto SETUP
if /i "%CMD%"=="update" goto UPDATE
if /i "%CMD%"=="start" goto START
if /i "%CMD%"=="stop" goto STOP
if /i "%CMD%"=="run" goto RUN
goto UNKNOWN

:MENU
cls
echo.
echo ================================
echo   JARVIS AI - Quick Commands
echo ================================
echo.
echo   setup   - First-time installation
echo   update  - Pull from GitHub ^& update deps
echo   start   - Launch backend ^& frontend
echo   stop    - Stop all processes
echo   run     - Start backend only
echo.
set /p CMD="Enter command (or press Enter for menu): "
if "!CMD!"=="" goto MENU
if /i "!CMD!"=="setup" goto SETUP
if /i "!CMD!"=="update" goto UPDATE
if /i "!CMD!"=="start" goto START
if /i "!CMD!"=="stop" goto STOP
if /i "!CMD!"=="run" goto RUN
goto MENU

:SETUP
echo.
echo [1/4] Checking Python...
python --version >nul 2>&1 || (echo Python required! & pause & exit /b 1)

echo [2/4] Setting up backend...
cd backend
if not exist "venv" python -m venv venv
call venv\Scripts\activate.bat
python -m pip install --upgrade pip -q
pip install -r requirements.txt -q
cd ..

echo [3/4] Setting up frontend...
cd frontend
call npm install --silent
cd ..

echo [4/4] Creating .env files...
if not exist "backend\.env" (
    (
        echo APP_NAME=JARVIS
        echo OPERATION_MODE=auto
        echo DATABASE_URL=sqlite:///./jarvis.db
        echo SECRET_KEY=change-in-production
        echo OPENAI_API_KEY=
        echo OLLAMA_BASE_URL=http://localhost:11434
    ) > backend\.env
)
if not exist "frontend\.env" (
    (
        echo VITE_API_URL=http://localhost:8000
        echo VITE_WS_URL=ws://localhost:8000/ws
    ) > frontend\.env
)

echo.
echo Setup complete! Run 'start' to launch.
pause
goto :EOF

:UPDATE
echo.
echo Updating from GitHub...
git --version >nul 2>&1 || (echo Git not found! & pause & exit /b 1)
if exist ".git" (
    git fetch origin -q
    git pull origin main -q
    echo Repository updated.
) else (
    echo Not a git repository.
)

echo Updating dependencies...
cd backend
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    pip install -r requirements.txt -q
)
cd ..
cd frontend
if exist "node_modules" call npm update --silent
cd ..

echo Update complete!
pause
goto :EOF

:START
echo.
echo Starting JARVIS...
if not exist "backend\venv\Scripts\python.exe" (
    echo Backend not setup. Run 'setup' first.
    pause
    exit /b 1
)
if not exist "frontend\node_modules" (
    echo Frontend not setup. Run 'setup' first.
    pause
    exit /b 1
)

REM Create .env if missing
if not exist "backend\.env" (
    (
        echo APP_NAME=JARVIS
        echo OPERATION_MODE=auto
        echo DATABASE_URL=sqlite:///./jarvis.db
    ) > backend\.env
)
if not exist "frontend\.env" (
    (
        echo VITE_API_URL=http://localhost:8000
        echo VITE_WS_URL=ws://localhost:8000/ws
    ) > frontend\.env
)

start "JARVIS Backend" cmd /k "cd backend && venv\Scripts\activate && python main.py"
timeout /t 2 /nobreak >nul
start "JARVIS Frontend" cmd /k "cd frontend && npm run dev"
timeout /t 3 /nobreak >nul
start http://localhost:5173

echo.
echo Servers starting... Browser will open shortly.
pause
goto :EOF

:STOP
echo.
echo Stopping JARVIS...
taskkill /FI "WINDOWTITLE eq JARVIS*" /IM cmd.exe /T >nul 2>&1
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq python.exe" /FO CSV ^| find "main.py"') do taskkill /PID %%i /F >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| find ":5173" ^| find "LISTENING"') do (
    taskkill /PID %%a /F >nul 2>&1
)
echo Stopped.
pause
goto :EOF

:RUN
echo.
echo Running backend only...
if not exist "backend\venv\Scripts\python.exe" (
    echo Not setup. Run 'setup' first.
    pause
    exit /b 1
)
cd backend
call venv\Scripts\activate.bat
python main.py
goto :EOF

:UNKNOWN
echo Unknown command: %CMD%
echo Valid commands: setup, update, start, stop, run
goto :EOF
