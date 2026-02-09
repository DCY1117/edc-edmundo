#!/bin/bash
###############################################################################
# Start Mock Model Server
# Inicia el servidor mock de modelos con interfaz web
###############################################################################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🤖 Starting AI Model Mock Server${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠ Python 3 not found. Please install Python 3.${NC}"
    exit 1
fi

# Navigate to model-server directory
cd "$(dirname "$0")"

# Install dependencies if needed
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}[1/3]${NC} Creating virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} Virtual environment created"
fi

echo -e "${YELLOW}[2/3]${NC} Installing dependencies..."
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo -e "${GREEN}✓${NC} Dependencies installed"

echo -e "${YELLOW}[3/3]${NC} Starting server..."
echo ""

# Start the server
python3 mock_server.py
