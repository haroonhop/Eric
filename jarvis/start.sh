#!/bin/bash

# ==================== JARVIS AI Start Script for Linux/macOS ====================
# This script starts both backend and frontend servers
# ================================================================================

# Color codes
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
RESET='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              JARVIS AI - Starting Servers                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if virtual environment exists
if [ ! -d "backend/venv" ]; then
    echo -e "${RED}Error: Virtual environment not found in backend folder${RESET}"
    echo "Please run setup.sh first to install dependencies"
    exit 1
fi

# Check if node_modules exists
if [ ! -d "frontend/node_modules" ]; then
    echo -e "${RED}Error: Node modules not found in frontend folder${RESET}"
    echo "Please run setup.sh first to install dependencies"
    exit 1
fi

echo -e "${BLUE}Starting JARVIS AI Assistant...${RESET}"
echo

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down servers...${RESET}"
    if [ -n "$BACKEND_PID" ] && kill -0 $BACKEND_PID 2>/dev/null; then
        kill $BACKEND_PID
    fi
    if [ -n "$FRONTEND_PID" ] && kill -0 $FRONTEND_PID 2>/dev/null; then
        kill $FRONTEND_PID
    fi
    echo -e "${GREEN}Servers stopped.${RESET}"
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Start backend
echo -e "${GREEN}Starting Backend Server...${RESET}"
cd backend
source venv/bin/activate
python main.py &
BACKEND_PID=$!
cd ..

# Wait for backend to initialize
sleep 3

# Start frontend
echo -e "${GREEN}Starting Frontend Server...${RESET}"
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo
echo -e "${GREEN}================================================================${RESET}"
echo -e "${GREEN}              SERVERS RUNNING                                   ${RESET}"
echo -e "${GREEN}================================================================${RESET}"
echo
echo -e "${BLUE}Backend:${RESET}  http://localhost:8000 (PID: $BACKEND_PID)"
echo -e "${BLUE}Frontend:${RESET} http://localhost:5173 (PID: $FRONTEND_PID)"
echo
echo -e "${YELLOW}Press Ctrl+C to stop all servers${RESET}"
echo

# Try to open browser
if command -v xdg-open &> /dev/null; then
    # Linux
    sleep 2
    xdg-open http://localhost:5173 &
elif command -v open &> /dev/null; then
    # macOS
    sleep 2
    open http://localhost:5173 &
fi

# Wait for processes
wait
