@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM JARVIS AI - Minimalist Launcher
REM Commands: setup, update, start, stop, run

if "%~1"=="" goto MENU
goto %~1 2>nul || echo Unknown: %~1 & goto EOF

:MENU
cls
echo.
echo  [1] Setup  [2] Update  [3] Start  [4] Stop  [5] Run  [6] Exit
echo.
set /p "c=Choice: "
if "!c!"=="1" goto SETUP
if "!c!"=="2" goto UPDATE
if "!c!"=="3" goto START
if "!c!"=="4" goto STOP
if "!c!"=="5" goto RUN
if "!c!"=="6" exit /b
goto MENU

:SETUP
echo Checking Python... & python --version >nul 2>&1 || (echo Python required! & pause & exit /b 1)
echo Setting up backend...
cd backend
if not exist "venv" python -m venv venv
call venv\Scripts\activate.bat
pip install --upgrade pip -q
pip install -r requirements.txt -q
cd ..
echo Setting up frontend...
cd frontend & call npm install --silent & cd ..
echo Creating .env files...
if not exist "backend\.env" (echo APP_NAME=JARVIS^
echo OPERATION_MODE=auto^
echo DATABASE_URL=sqlite:///./jarvis.db^
echo SECRET_KEY=change-in-production^
echo OPENAI_API_KEY=^
echo OLLAMA_BASE_URL=http://localhost:11434) > backend\.env
if not exist "frontend\.env" (echo VITE_API_URL=http://localhost:8000^
echo VITE_WS_URL=ws://localhost:8000/ws) > frontend\.env
echo Done! Run 'start' to launch. & pause & goto EOF

:UPDATE
echo Updating from GitHub...
git fetch origin -q && git pull origin main -q && echo Updated. || echo Not a git repo.
echo Updating dependencies...
cd backend && if exist "venv\Scripts\activate.bat" (call venv\Scripts\activate.bat && pip install -r requirements.txt -q) & cd ..
cd frontend && if exist "node_modules" call npm update --silent & cd ..
echo Done! & pause & goto EOF

:START
echo Starting JARVIS...
if not exist "backend\venv\Scripts\python.exe" (echo Run 'setup' first! & pause & exit /b 1)
if not exist "frontend\node_modules" (echo Run 'setup' first! & pause & exit /b 1)
if not exist "backend\.env" (echo APP_NAME=JARVIS^
echo OPERATION_MODE=auto^
echo DATABASE_URL=sqlite:///./jarvis.db) > backend\.env
if not exist "frontend\.env" (echo VITE_API_URL=http://localhost:8000^
echo VITE_WS_URL=ws://localhost:8000/ws) > frontend\.env
start "JARVIS Backend" cmd /k "cd backend && venv\Scripts\activate && python main.py"
timeout /t 2 /nobreak >nul
start "JARVIS Frontend" cmd /k "cd frontend && npm run dev"
timeout /t 3 /nobreak >nul
start http://localhost:5173
echo Servers starting... & pause & goto EOF

:STOP
echo Stopping JARVIS...
taskkill /FI "WINDOWTITLE eq JARVIS*" /IM cmd.exe /T >nul 2>&1
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq python.exe" /FO CSV ^| find "main.py"') do taskkill /PID %%i /F >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| find ":5173" ^| find "LISTENING"') do taskkill /PID %%a /F >nul 2>&1
echo Stopped. & pause & goto EOF

:RUN
echo Running backend...
if not exist "backend\venv\Scripts\python.exe" (echo Run 'setup' first! & pause & exit /b 1)
cd backend && call venv\Scripts\activate.bat && python main.py
goto EOF

:EOF
