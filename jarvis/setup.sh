#!/bin/bash

# ==================== JARVIS AI Setup Script for Linux/macOS ====================
# This script automates the installation and setup of JARVIS AI Assistant
# ================================================================================

set -e  # Exit on error

# Color codes
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
RED='\033[0;91m'
BLUE='\033[0;94m'
RESET='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           JARVIS AI - Installation Wizard                 ║"
echo "║        Hybrid Online/Offline Personal Assistant           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if running as root (optional warning)
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Note: Running as regular user. Some features may require sudo.${RESET}"
    echo
fi

echo -e "${BLUE}Step 1: Checking Prerequisites...${RESET}"
echo "---------------------------------------------------------------"

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed or not in PATH${RESET}"
    echo "Please install Python 3.10+ using your package manager:"
    echo "  Ubuntu/Debian: sudo apt install python3 python3-pip python3-venv"
    echo "  Fedora: sudo dnf install python3 python3-pip"
    echo "  macOS: brew install python3"
    exit 1
else
    PYTHON_VERSION=$(python3 --version)
    echo -e "$PYTHON_VERSION"
    echo -e "${GREEN}✓ Python found${RESET}"
fi

# Check Node.js installation
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed or not in PATH${RESET}"
    echo "Please install Node.js 18+ from https://nodejs.org/ or:"
    echo "  Ubuntu/Debian: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
    echo "  macOS: brew install node"
    exit 1
else
    NODE_VERSION=$(node --version)
    echo -e "$NODE_VERSION"
    echo -e "${GREEN}✓ Node.js found${RESET}"
fi

# Check npm installation
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed${RESET}"
    exit 1
else
    NPM_VERSION=$(npm --version)
    echo -e "$NPM_VERSION"
    echo -e "${GREEN}✓ npm found${RESET}"
fi

echo
echo -e "${BLUE}Step 2: Setting up Backend (Python)${RESET}"
echo "---------------------------------------------------------------"

cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${RESET}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${RESET}"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip --quiet

# Install requirements
echo "Installing Python dependencies (this may take a few minutes)..."
pip install -r requirements.txt || {
    echo -e "${YELLOW}Warning: Some packages may have failed to install${RESET}"
    echo "Continuing with setup..."
}
echo -e "${GREEN}✓ Backend dependencies installed${RESET}"

cd ..

echo
echo -e "${BLUE}Step 3: Setting up Frontend (Node.js)${RESET}"
echo "---------------------------------------------------------------"

cd frontend

# Install node modules
echo "Installing Node.js dependencies (this may take a few minutes)..."
npm install || {
    echo -e "${RED}Error: Failed to install frontend dependencies${RESET}"
    exit 1
}
echo -e "${GREEN}✓ Frontend dependencies installed${RESET}"

cd ..

echo
echo -e "${BLUE}Step 4: Creating Environment Configuration${RESET}"
echo "---------------------------------------------------------------"

# Create backend .env file if it doesn't exist
if [ ! -f "backend/.env" ]; then
    echo "Creating backend environment file..."
    cat > backend/.env << EOF
# ==================== JARVIS AI Configuration ====================

# Application Settings
APP_NAME=JARVIS
APP_VERSION=1.0.0
DEBUG=True

# Server Settings
HOST=0.0.0.0
PORT=8000

# Database Settings
DATABASE_URL=sqlite:///./jarvis.db
# For PostgreSQL: postgresql://user:password@localhost:5432/jarvis

# Redis Settings (optional, for caching)
REDIS_URL=redis://localhost:6379

# API Keys (Optional - for online mode)
OPENAI_API_KEY=your_openai_api_key_here
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
PINECONE_API_KEY=your_pinecone_api_key_here

# Authentication
SECRET_KEY=your-secret-key-change-this-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Mode Settings
MODE=hybrid
# Options: online, offline, hybrid

# Offline Model Settings
OLLAMA_BASE_URL=http://localhost:11434
LOCAL_MODEL=mistral

# Feature Flags
ENABLE_VOICE=True
ENABLE_AUTOMATION=True
ENABLE_BROWSER=True
ENABLE_DOCUMENT_PROCESSING=True
EOF
    echo -e "${GREEN}✓ Backend .env file created${RESET}"
else
    echo -e "${GREEN}✓ Backend .env file already exists${RESET}"
fi

# Create frontend .env file if it doesn't exist
if [ ! -f "frontend/.env" ]; then
    echo "Creating frontend environment file..."
    cat > frontend/.env << EOF
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000/ws
VITE_APP_NAME=JARVIS
VITE_APP_VERSION=1.0.0
EOF
    echo -e "${GREEN}✓ Frontend .env file created${RESET}"
else
    echo -e "${GREEN}✓ Frontend .env file already exists${RESET}"
fi

echo
echo -e "${BLUE}Step 5: Additional Setup${RESET}"
echo "---------------------------------------------------------------"

# Check if Playwright browsers need to be installed
if command -v python3 &> /dev/null; then
    echo "Installing Playwright browsers (for browser automation)..."
    source backend/venv/bin/activate
    python -m playwright install chromium 2>/dev/null && {
        echo -e "${GREEN}✓ Playwright browsers installed${RESET}"
    } || {
        echo -e "${YELLOW}Note: Playwright installation skipped or failed${RESET}"
    }
fi

echo
echo -e "${GREEN}================================================================${RESET}"
echo -e "${GREEN}                    SETUP COMPLETE!                             ${RESET}"
echo -e "${GREEN}================================================================${RESET}"
echo
echo -e "${BLUE}Next Steps:${RESET}"
echo
echo "1. Configure your API keys in backend/.env (optional for offline mode)"
echo "   - OpenAI API key for GPT models"
echo "   - ElevenLabs API key for voice synthesis"
echo "   - Or use local models with Ollama for offline operation"
echo
echo "2. To start JARVIS:"
echo -e "   ${YELLOW}Option A - Quick Start:${RESET}"
echo "     Run: ./start.sh"
echo
echo -e "   ${YELLOW}Option B - Manual Start:${RESET}"
echo "     Terminal 1 (Backend):"
echo "       cd backend"
echo "       source venv/bin/activate"
echo "       python main.py"
echo
echo "     Terminal 2 (Frontend):"
echo "       cd frontend"
echo "       npm run dev"
echo
echo "3. Open your browser to http://localhost:5173"
echo
echo -e "${BLUE}Documentation:${RESET}"
echo "  - README.md - General overview"
echo "  - OPTIMIZATION_SUMMARY.md - Recent improvements"
echo "  - REFACTORING_PLAN.md - Architecture details"
echo
echo -e "${YELLOW}For support, please refer to the documentation or open an issue.${RESET}"
echo
