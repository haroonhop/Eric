# JARVIS AI - Setup Guide

## Quick Start

### Windows

1. **Run the setup script:**
   ```cmd
   setup.bat
   ```

2. **Start JARVIS:**
   ```cmd
   start.bat
   ```

3. **Access the application:**
   - Open your browser to http://localhost:5173

### Linux/macOS

1. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

2. **Start JARVIS:**
   ```bash
   ./start.sh
   ```

3. **Access the application:**
   - Open your browser to http://localhost:5173

---

## Prerequisites

### Required Software

- **Python 3.10+** - [Download](https://www.python.org/downloads/)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **Git** (optional, for cloning) - [Download](https://git-scm.com/)

### Installation Commands by OS

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### Fedora
```bash
sudo dnf install python3 python3-pip
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs
```

#### macOS
```bash
brew install python3
brew install node
```

#### Windows
- Download Python from https://www.python.org/downloads/
  - ⚠️ **Important:** Check "Add Python to PATH" during installation
- Download Node.js from https://nodejs.org/

---

## What the Setup Scripts Do

### setup.bat / setup.sh

1. **Check Prerequisites**
   - Verifies Python installation
   - Verifies Node.js installation
   - Verifies npm installation

2. **Setup Backend**
   - Creates Python virtual environment
   - Installs all Python dependencies
   - Configures environment variables

3. **Setup Frontend**
   - Installs Node.js dependencies
   - Configures environment variables

4. **Additional Setup**
   - Installs Playwright browsers (for automation)
   - Creates `.env` configuration files

### start.bat / start.sh

1. **Validates Installation**
   - Checks for virtual environment
   - Checks for node_modules

2. **Starts Servers**
   - Launches backend server (FastAPI on port 8000)
   - Launches frontend server (Vite on port 5173)
   - Opens browser automatically

3. **Cleanup** (Linux/macOS only)
   - Gracefully shuts down servers on Ctrl+C

---

## Manual Installation

If you prefer manual setup:

### Backend

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
python main.py
```

### Frontend

```bash
cd frontend

# Install dependencies
npm install

# Run development server
npm run dev
```

---

## Configuration

### Backend (.env)

Edit `backend/.env` to configure:

```env
# API Keys (Optional for offline mode)
OPENAI_API_KEY=your_key_here
ELEVENLABS_API_KEY=your_key_here

# Database
DATABASE_URL=sqlite:///./jarvis.db

# Mode (online, offline, or hybrid)
MODE=hybrid

# Local model settings
OLLAMA_BASE_URL=http://localhost:11434
LOCAL_MODEL=mistral
```

### Frontend (.env)

Edit `frontend/.env` to configure:

```env
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000/ws
```

---

## Troubleshooting

### Common Issues

#### Python not found
- **Windows:** Reinstall Python and check "Add Python to PATH"
- **Linux/macOS:** Use `python3` instead of `python`

#### Permission denied (Linux/macOS)
```bash
chmod +x setup.sh start.sh
./setup.sh
```

#### Port already in use
- Backend (8000): Change `PORT` in `backend/.env`
- Frontend (5173): Change port in `frontend/vite.config.ts`

#### npm install fails
```bash
# Clear npm cache
npm cache clean --force
npm install
```

#### Virtual environment issues
```bash
# Delete and recreate
rm -rf backend/venv
python -m venv backend/venv
```

---

## Next Steps

After successful setup:

1. **Configure API Keys** (optional)
   - Edit `backend/.env` with your API keys
   - Or use local models with Ollama for offline operation

2. **Install Ollama** (for offline mode)
   - Download from https://ollama.ai
   - Run: `ollama pull mistral`

3. **Explore Features**
   - Chat interface
   - Voice commands
   - Browser automation
   - Document processing

4. **Read Documentation**
   - README.md - Overview
   - OPTIMIZATION_SUMMARY.md - Recent improvements
   - REFACTORING_PLAN.md - Architecture

---

## Support

For issues or questions:
- Check the documentation files
- Review error messages carefully
- Ensure all prerequisites are installed
- Try running setup scripts as administrator/root
