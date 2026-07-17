#!/bin/bash

# ============================================================================
# JARVIS AI - Intelligent Personal Assistant
# Setup, Install, Update, and Run Script for Linux/macOS/WSL
# Supports both Online and Offline modes
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
PYTHON_VERSION="3.11"
NODE_VERSION="20"
VENV_DIR="venv"
BACKEND_DIR="jarvis/backend"
FRONTEND_DIR="jarvis/frontend"
DESKTOP_DIR="jarvis/desktop"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="auto"  # auto, online, offline

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo "============================================"
    echo " $1"
    echo "============================================"
    echo ""
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/debian_version ]; then
            PKG_MANAGER="apt"
        elif [ -f /etc/redhat-release ]; then
            PKG_MANAGER="dnf"
        elif [ -f /etc/arch-release ]; then
            PKG_MANAGER="pacman"
        else
            PKG_MANAGER="apt"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

detect_internet() {
    if ping -c 1 8.8.8.8 &>/dev/null; then
        INTERNET_AVAILABLE=true
    else
        INTERNET_AVAILABLE=false
    fi
}

determine_mode() {
    if [ "$MODE" == "auto" ]; then
        if [ "$INTERNET_AVAILABLE" = true ]; then
            CURRENT_MODE="online"
            print_success "Internet detected: Running in ONLINE mode"
        else
            CURRENT_MODE="offline"
            print_warning "No internet: Running in OFFLINE mode"
        fi
    else
        CURRENT_MODE="$MODE"
        print_success "Running in forced $CURRENT_MODE mode"
    fi
}

wait_for_completion() {
    if [ $? -ne 0 ]; then
        print_error "Command failed with error code $?"
        if [ "$1" == "critical" ]; then
            pause
            exit 1
        fi
    fi
}

pause() {
    if [ "$CI" != "true" ]; then
        read -p "Press Enter to continue..."
    fi
}

# ============================================================================
# Installation Functions
# ============================================================================

install_system_dependencies() {
    print_header "Installing System Dependencies"
    
    case $PKG_MANAGER in
        apt)
            print_success "Updating package lists..."
            sudo apt update
            print_success "Installing required packages..."
            sudo apt install -y python3 python3-pip python3-venv python3-dev \
                              nodejs npm git curl wget build-essential \
                              libssl-dev libffi-dev python3-setuptools
            ;;
        dnf)
            print_success "Updating package lists..."
            sudo dnf check-update
            print_success "Installing required packages..."
            sudo dnf install -y python3 python3-pip python3-devel \
                              nodejs npm git curl wget gcc gcc-c++ \
                              openssl-devel libffi-devel
            ;;
        pacman)
            print_success "Updating package lists..."
            sudo pacman -Syu --noconfirm
            print_success "Installing required packages..."
            sudo pacman -S --noconfirm python python-pip python-virtualenv \
                          python-setuptools nodejs npm git curl wget \
                          base-devel openssl
            ;;
        brew)
            print_success "Updating Homebrew..."
            brew update
            print_success "Installing required packages..."
            brew install python@3.11 node git
            ;;
        *)
            print_warning "Unknown package manager. Please install Python 3.11, Node.js 20, and Git manually."
            return 1
            ;;
    esac
    
    print_success "System dependencies installed"
}

setup_python_venv() {
    print_header "Setting Up Python Virtual Environment"
    
    if [ ! -d "$VENV_DIR" ]; then
        print_success "Creating virtual environment..."
        python3 -m venv $VENV_DIR
        wait_for_completion critical
    else
        print_success "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    source "$VENV_DIR/bin/activate"
    print_success "Virtual environment activated"
}

install_python_dependencies() {
    print_header "Installing Python Dependencies"
    
    if [ -f "$BACKEND_DIR/requirements.txt" ]; then
        print_success "Installing backend dependencies..."
        pip install --upgrade pip
        
        # Install based on mode
        if [ "$CURRENT_MODE" == "online" ]; then
            print_success "Installing ONLINE mode dependencies (OpenAI, ElevenLabs, etc.)"
            pip install -r "$BACKEND_DIR/requirements.txt"
        else
            print_success "Installing OFFLINE mode dependencies (Ollama, local TTS, etc.)"
            # Add offline-specific packages if not in requirements.txt
            pip install -r "$BACKEND_DIR/requirements.txt"
            pip install ollama piper-tts chromadb sqlite-utils
        fi
        
        wait_for_completion
    else
        print_warning "Backend requirements.txt not found. Creating default..."
        mkdir -p "$BACKEND_DIR"
        cat > "$BACKEND_DIR/requirements.txt" << EOF
# Core Framework
fastapi==0.109.0
uvicorn[standard]==0.27.0
python-dotenv==1.0.0
pydantic==2.5.3
websockets==12.0

# Authentication
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# File Handling
aiofiles==23.2.1
pillow==10.2.0
numpy==1.26.3

# AI & Language
langchain==0.1.0
langgraph==0.0.1

# Online Mode (will be skipped in offline mode)
openai==1.10.0
elevenlabs==0.2.0

# Offline Mode Alternatives
chromadb==0.4.22
sentence-transformers==2.3.0

# Speech Recognition
speechrecognition==3.10.1
pyaudio==0.2.14

# Text-to-Speech
pyttsx3==2.90

# Database
sqlalchemy==2.0.25
alembic==1.13.1
psycopg2-binary==2.9.9
redis==5.0.1

# Utilities
requests==2.31.0
aiohttp==3.9.1
EOF
        pip install -r "$BACKEND_DIR/requirements.txt"
        wait_for_completion
    fi
}

install_frontend_dependencies() {
    print_header "Installing Frontend Dependencies"
    
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        cd "$FRONTEND_DIR"
        print_success "Installing frontend dependencies..."
        npm install
        wait_for_completion
        cd "$SCRIPT_DIR"
    else
        print_warning "Frontend package.json not found. Skipping..."
    fi
}

install_desktop_dependencies() {
    print_header "Installing Desktop App Dependencies"
    
    if [ -f "$DESKTOP_DIR/package.json" ]; then
        cd "$DESKTOP_DIR"
        print_success "Installing desktop dependencies..."
        npm install
        wait_for_completion
        cd "$SCRIPT_DIR"
    else
        print_warning "Desktop package.json not found. Skipping..."
    fi
}

create_env_file() {
    print_header "Creating Environment Configuration"
    
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        cat > "$BACKEND_DIR/.env" << EOF
# JARVIS AI Environment Configuration
# Generated on $(date)

# Operation Mode: auto, online, offline
OPERATION_MODE=auto

# API Keys (Required for ONLINE mode)
OPENAI_API_KEY=your_openai_api_key_here
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
GOOGLE_API_KEY=your_google_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Local AI Settings (Required for OFFLINE mode)
OLLAMA_HOST=http://localhost:11434
LOCAL_MODEL=mistral:7b
EMBEDDING_MODEL=all-MiniLM-L6-v2

# Database Configuration
# PostgreSQL for online mode, SQLite for offline mode
DATABASE_URL=postgresql://jarvis:jarvis@localhost:5432/jarvis
SQLITE_DB_PATH=./jarvis.db
REDIS_URL=redis://localhost:6379

# Vector Database
# Pinecone for online, ChromaDB for offline
VECTOR_DB_TYPE=chroma  # Options: pinecone, chroma
PINECONE_API_KEY=your_pinecone_api_key
CHROMA_DB_PATH=./chroma_db

# Security
SECRET_KEY=your_secret_key_here_change_in_production_$(openssl rand -hex 32 2>/dev/null || echo "random_string")
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Application
APP_NAME=JARVIS AI
DEBUG=True
HOST=0.0.0.0
PORT=8000

# Voice Settings
WAKE_WORD=hey jarvis
VOICE_MODEL=en_US
TTS_ENGINE=piper  # Options: elevenlabs, piper, pyttsx3

# Memory Settings
MEMORY_ENABLED=True
LONG_TERM_MEMORY=True
CONTEXT_WINDOW=4096

# Feature Flags
ENABLE_ONLINE_FEATURES=True
ENABLE_OFFLINE_FEATURES=True
ENABLE_LOCAL_INFERENCE=False
ENABLE_CLOUD_INFERENCE=True
EOF
        print_success "Created .env file in backend directory"
        print_warning "IMPORTANT: Update the .env file with your API keys for ONLINE mode!"
        print_warning "For OFFLINE mode: Install Ollama (https://ollama.ai) and run: ollama pull mistral:7b"
    else
        print_success ".env file already exists"
    fi
}

install_ollama() {
    if [ "$CURRENT_MODE" == "offline" ] || [ "$CURRENT_MODE" == "auto" ]; then
        print_header "Setting Up Ollama for Offline Mode"
        
        if ! command -v ollama &>/dev/null; then
            print_warning "Ollama not found. Installing..."
            curl -fsSL https://ollama.ai/install.sh | sh
            wait_for_completion
            
            print_success "Starting Ollama service..."
            ollama serve &
            sleep 5
            
            print_success "Pulling default model (mistral:7b)..."
            ollama pull mistral:7b
        else
            print_success "Ollama is already installed"
        fi
    fi
}

initialize_database() {
    print_header "Initializing Database"
    
    if [ "$CURRENT_MODE" == "online" ]; then
        print_warning "PostgreSQL should be installed separately for online mode"
        case $PKG_MANAGER in
            apt)
                print_warning "Run: sudo apt install postgresql postgresql-contrib"
                ;;
            dnf)
                print_warning "Run: sudo dnf install postgresql-server postgresql-contrib"
                ;;
            brew)
                print_warning "Run: brew install postgresql"
                ;;
        esac
    else
        print_success "Using SQLite for offline mode - no additional setup required"
    fi
}

# ============================================================================
# Main Menu
# ============================================================================

main_menu() {
    clear
    detect_internet
    determine_mode
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║           JARVIS AI - Intelligent Personal Assistant     ║"
    echo "║                                                          ║"
    echo "║   Current Mode: ${CURRENT_MODE^^}                                  ║"
    echo "║   Internet: $([ "$INTERNET_AVAILABLE" = true ] && echo "Connected" || echo "Disconnected")                                           ║"
    echo "║                                                          ║"
    echo "║   [1] Full Installation (First Time Setup)               ║"
    echo "║   [2] Update System                                      ║"
    echo "║   [3] Run JARVIS                                         ║"
    echo "║   [4] Run Backend Only                                   ║"
    echo "║   [5] Run Frontend Only                                  ║"
    echo "║   [6] Run Desktop App                                    ║"
    echo "║   [7] Check Dependencies                                 ║"
    echo "║   [8] Clean Environment                                  ║"
    echo "║   [9] Uninstall                                          ║"
    echo "║   [M] Change Mode (Online/Offline/Auto)                  ║"
    echo "║   [0] Exit                                               ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Enter your choice (0-9, M): " choice
    
    case $choice in
        1) install_all ;;
        2) update_system ;;
        3) run_jarvis ;;
        4) run_backend ;;
        5) run_frontend ;;
        6) run_desktop ;;
        7) check_dependencies ;;
        8) clean_environment ;;
        9) uninstall ;;
        [mM]) change_mode ;;
        0) exit_script ;;
        *) print_warning "Invalid choice. Please try again."; sleep 2; main_menu ;;
    esac
}

change_mode() {
    print_header "Change Operation Mode"
    echo "Current mode: $MODE"
    echo ""
    echo "Select mode:"
    echo "  [1] Auto (Detect automatically)"
    echo "  [2] Online (Force cloud services)"
    echo "  [3] Offline (Force local services)"
    echo ""
    read -p "Enter choice (1-3): " mode_choice
    
    case $mode_choice in
        1) MODE="auto"; print_success "Mode set to AUTO" ;;
        2) MODE="online"; print_success "Mode set to ONLINE" ;;
        3) MODE="offline"; print_success "Mode set to OFFLINE" ;;
        *) print_warning "Invalid choice"; sleep 1; change_mode ;;
    esac
    
    sleep 1
    main_menu
}

# ============================================================================
# Installation Workflow
# ============================================================================

install_all() {
    print_header "JARVIS AI - Full Installation"
    
    detect_os
    print_success "Detected OS: $OS with package manager: $PKG_MANAGER"
    sleep 2
    
    # Step 1: Install system dependencies
    print_header "Step 1: Installing System Dependencies"
    install_system_dependencies
    sleep 2
    
    # Step 2: Setup Python virtual environment
    print_header "Step 2: Setting Up Python Virtual Environment"
    setup_python_venv
    sleep 2
    
    # Step 3: Detect mode and install Python dependencies
    detect_internet
    determine_mode
    print_header "Step 3: Installing Python Dependencies"
    install_python_dependencies
    sleep 2
    
    # Step 4: Install frontend dependencies
    print_header "Step 4: Installing Frontend Dependencies"
    install_frontend_dependencies
    sleep 2
    
    # Step 5: Install desktop dependencies
    print_header "Step 5: Installing Desktop App Dependencies"
    install_desktop_dependencies
    sleep 2
    
    # Step 6: Setup Ollama for offline mode
    print_header "Step 6: Setting Up Offline AI (Ollama)"
    install_ollama
    sleep 2
    
    # Step 7: Create environment files
    print_header "Step 7: Creating Environment Configuration"
    create_env_file
    sleep 2
    
    # Step 8: Initialize database
    print_header "Step 8: Initializing Database"
    initialize_database
    sleep 2
    
    # Completion
    print_header "Installation Complete!"
    print_success "JARVIS AI has been successfully installed!"
    echo ""
    echo "Next Steps:"
    echo "1. Update the .env file in the backend directory with your API keys (for ONLINE mode)"
    echo "2. For OFFLINE mode: Ensure Ollama is running with 'ollama serve'"
    echo "3. Install PostgreSQL separately if using online mode with full features"
    echo "4. Run JARVIS using option 3 from the main menu"
    echo ""
    pause
    main_menu
}

# ============================================================================
# Update Functions
# ============================================================================

update_system() {
    print_header "Updating JARVIS AI System"
    
    # Update Python dependencies
    print_header "Updating Python Dependencies"
    if [ -d "$VENV_DIR" ]; then
        source "$VENV_DIR/bin/activate"
        if [ -f "$BACKEND_DIR/requirements.txt" ]; then
            pip install --upgrade -r "$BACKEND_DIR/requirements.txt"
            wait_for_completion
        fi
    fi
    
    # Update Frontend
    print_header "Updating Frontend"
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        cd "$FRONTEND_DIR"
        npm update
        wait_for_completion
        cd "$SCRIPT_DIR"
    fi
    
    # Update Desktop App
    print_header "Updating Desktop App"
    if [ -f "$DESKTOP_DIR/package.json" ]; then
        cd "$DESKTOP_DIR"
        npm update
        wait_for_completion
        cd "$SCRIPT_DIR"
    fi
    
    # Pull latest code if git repository
    print_header "Checking for Code Updates"
    if [ -d ".git" ]; then
        git pull origin main 2>/dev/null || print_warning "Could not pull updates (not a git repo or no remote)"
    fi
    
    print_success "System update completed!"
    pause
    main_menu
}

# ============================================================================
# Run Functions
# ============================================================================

run_backend() {
    print_header "Starting JARVIS Backend"
    
    if [ -d "$VENV_DIR" ]; then
        source "$VENV_DIR/bin/activate"
        if [ -d "$BACKEND_DIR" ]; then
            cd "$BACKEND_DIR"
            print_success "Starting server on http://0.0.0.0:8000"
            print_success "Mode: $CURRENT_MODE"
            python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
            cd "$SCRIPT_DIR"
        else
            print_error "Backend directory not found!"
        fi
    else
        print_error "Virtual environment not found! Run installation first."
    fi
}

run_frontend() {
    print_header "Starting JARVIS Frontend"
    
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        cd "$FRONTEND_DIR"
        npm run dev
        cd "$SCRIPT_DIR"
    else
        print_error "Frontend not found! Run installation first."
    fi
}

run_desktop() {
    print_header "Starting JARVIS Desktop App"
    
    if [ -f "$DESKTOP_DIR/package.json" ]; then
        cd "$DESKTOP_DIR"
        npm run electron:dev
        cd "$SCRIPT_DIR"
    else
        print_error "Desktop app not found! Run installation first."
    fi
}

run_jarvis() {
    print_header "Starting JARVIS AI"
    
    detect_internet
    determine_mode
    
    # Start backend in background
    print_success "Starting Backend Server..."
    if [ -d "$VENV_DIR" ]; then
        source "$VENV_DIR/bin/activate"
        cd "$BACKEND_DIR"
        nohup python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000 > ../backend.log 2>&1 &
        BACKEND_PID=$!
        cd "$SCRIPT_DIR"
        print_success "Backend started with PID: $BACKEND_PID"
    else
        print_error "Virtual environment not found!"
        pause
        main_menu
    fi
    
    # Wait for backend to start
    print_success "Waiting for backend to initialize..."
    sleep 5
    
    # Start frontend in background
    print_header "Starting Frontend"
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        cd "$FRONTEND_DIR"
        nohup npm run dev > ../frontend.log 2>&1 &
        FRONTEND_PID=$!
        cd "$SCRIPT_DIR"
        print_success "Frontend started with PID: $FRONTEND_PID"
    else
        print_warning "Frontend not found. Running backend only..."
    fi
    
    print_success ""
    print_success "JARVIS AI is starting..."
    print_success "Backend: http://localhost:8000"
    print_success "Frontend: http://localhost:3000 (if available)"
    print_success ""
    print_warning "To stop: kill $BACKEND_PID $FRONTEND_PID"
    print_warning "Logs: tail -f backend.log frontend.log"
    echo ""
    pause
    main_menu
}

# ============================================================================
# Utility Functions
# ============================================================================

check_dependencies() {
    print_header "Checking System Dependencies"
    
    echo ""
    echo "=== Python ==="
    if command -v python3 &>/dev/null; then
        python3 --version
        print_success "Python is installed"
    else
        print_error "Python not installed"
    fi
    
    echo ""
    echo "=== Node.js ==="
    if command -v node &>/dev/null; then
        node --version
        print_success "Node.js is installed"
    else
        print_error "Node.js not installed"
    fi
    
    echo ""
    echo "=== npm ==="
    if command -v npm &>/dev/null; then
        npm --version
        print_success "npm is installed"
    else
        print_error "npm not installed"
    fi
    
    echo ""
    echo "=== Git ==="
    if command -v git &>/dev/null; then
        git --version
        print_success "Git is installed"
    else
        print_error "Git not installed"
    fi
    
    echo ""
    echo "=== Virtual Environment ==="
    if [ -d "$VENV_DIR" ]; then
        print_success "Virtual environment exists"
    else
        print_error "Virtual environment not found"
    fi
    
    echo ""
    echo "=== Backend Dependencies ==="
    if [ -f "$BACKEND_DIR/requirements.txt" ]; then
        print_success "Requirements file exists"
    else
        print_error "Requirements file not found"
    fi
    
    echo ""
    echo "=== Frontend Dependencies ==="
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        print_success "Package.json exists"
    else
        print_warning "Frontend not initialized"
    fi
    
    echo ""
    echo "=== Environment Configuration ==="
    if [ -f "$BACKEND_DIR/.env" ]; then
        print_success ".env file exists"
    else
        print_warning ".env file not found"
    fi
    
    echo ""
    echo "=== Ollama (Offline Mode) ==="
    if command -v ollama &>/dev/null; then
        print_success "Ollama is installed"
        ollama list 2>/dev/null || print_warning "Ollama service not running"
    else
        print_warning "Ollama not installed (required for offline mode)"
    fi
    
    echo ""
    echo "=== Internet Connectivity ==="
    detect_internet
    if [ "$INTERNET_AVAILABLE" = true ]; then
        print_success "Internet connection available"
    else
        print_warning "No internet connection"
    fi
    
    echo ""
    pause
    main_menu
}

clean_environment() {
    print_header "Cleaning Environment"
    
    read -p "Are you sure you want to clean the environment? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_success "Operation cancelled"
        main_menu
    fi
    
    print_warning "Removing virtual environment..."
    if [ -d "$VENV_DIR" ]; then
        rm -rf "$VENV_DIR"
        print_success "Virtual environment removed"
    fi
    
    print_warning "Removing node_modules folders..."
    if [ -d "$FRONTEND_DIR/node_modules" ]; then
        rm -rf "$FRONTEND_DIR/node_modules"
    fi
    if [ -d "$DESKTOP_DIR/node_modules" ]; then
        rm -rf "$DESKTOP_DIR/node_modules"
    fi
    
    print_warning "Removing Python cache..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    
    print_warning "Removing build artifacts..."
    rm -rf build dist *.egg-info 2>/dev/null || true
    
    print_success "Environment cleaned!"
    pause
    main_menu
}

uninstall() {
    print_header "Uninstalling JARVIS AI"
    
    read -p "WARNING: This will remove all JARVIS files. Are you sure? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_success "Operation cancelled"
        main_menu
    fi
    
    clean_environment
    
    print_warning "Removing configuration files..."
    if [ -f "$BACKEND_DIR/.env" ]; then
        rm "$BACKEND_DIR/.env"
    fi
    
    print_warning "Removing logs..."
    rm -f backend.log frontend.log 2>/dev/null || true
    rm -rf logs 2>/dev/null || true
    
    print_warning "Removing database files..."
    rm -f jarvis.db 2>/dev/null || true
    rm -rf chroma_db 2>/dev/null || true
    
    print_success "JARVIS AI has been uninstalled!"
    print_warning "Note: You may need to manually remove some directories"
    pause
    main_menu
}

exit_script() {
    print_success "Thank you for using JARVIS AI!"
    exit 0
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Check if running in CI mode
if [ "$1" == "--ci" ]; then
    CI=true
    shift
fi

# Handle command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --install)
            detect_os
            detect_internet
            determine_mode
            install_all
            exit 0
            ;;
        --run)
            detect_internet
            determine_mode
            run_jarvis
            exit 0
            ;;
        --backend)
            detect_internet
            determine_mode
            run_backend
            exit 0
            ;;
        --update)
            update_system
            exit 0
            ;;
        --help)
            echo "JARVIS AI Setup Script"
            echo ""
            echo "Usage: ./setup.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --mode [auto|online|offline]  Set operation mode"
            echo "  --install                     Run full installation"
            echo "  --run                         Start JARVIS (backend + frontend)"
            echo "  --backend                     Start backend only"
            echo "  --update                      Update system"
            echo "  --help                        Show this help message"
            echo "  --ci                          Run in CI mode (no prompts)"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Start main menu if no command line arguments
main_menu
