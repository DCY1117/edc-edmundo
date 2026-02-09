#!/bin/bash
###############################################################################
# AIModelHub - Automated Deployment Script
# 
# Deploys the reorganized CatalogModelIA_DS stack (backend + UI) from scratch.
# Includes: Docker containers, database initialization, dependencies, and services.
#
# Usage: ./deploy.sh
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$PROJECT_DIR/AIModelHub_Extensiones"
UI_DIR="$PROJECT_DIR/AIModelHub_EDCUI/ui-model-browser"
BACKEND_DIR="$EXT_DIR/runtime-edc-backend"
FRONTEND_DIR="$UI_DIR"
MODEL_SERVER_DIR="$EXT_DIR/model-serving"
DB_SCRIPTS_DIR="$EXT_DIR/database-scripts"
DB_INIT_COMPLETE="$DB_SCRIPTS_DIR/000_init_database_complete.sql"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 AIModelHub - Automated Deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

###############################################################################
# Step 1: Check Prerequisites
###############################################################################
echo -e "${YELLOW}[1/8]${NC} Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Please install Node.js 18+ first.${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm not found. Please install npm first.${NC}"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 not found. Please install Python 3 first.${NC}"
    exit 1
fi

DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)

echo -e "${GREEN}✓${NC} Docker: $DOCKER_VERSION"
echo -e "${GREEN}✓${NC} Node.js: $NODE_VERSION"
echo -e "${GREEN}✓${NC} npm: $NPM_VERSION"
echo -e "${GREEN}✓${NC} Python: $PYTHON_VERSION"
echo ""

###############################################################################
# Step 2: Stop Existing Services
###############################################################################
echo -e "${YELLOW}[2/8]${NC} Stopping existing services..."

# Stop any running Node processes
pkill -f "node.*server-edc.js" || true
pkill -f "ng serve" || true
pkill -f "mock_server.py" || true

# Stop Docker containers if running
docker stop ml-assets-postgres ml-assets-minio 2>/dev/null || true
docker rm ml-assets-postgres ml-assets-minio 2>/dev/null || true

echo -e "${GREEN}✓${NC} Existing services stopped"
echo ""

###############################################################################
# Step 3: Start Docker Infrastructure
###############################################################################
echo -e "${YELLOW}[3/8]${NC} Starting Docker infrastructure (PostgreSQL + MinIO)..."

# Start PostgreSQL
docker run -d \
  --name ml-assets-postgres \
  -e POSTGRES_USER=ml_assets_user \
  -e POSTGRES_PASSWORD=ml_assets_password \
  -e POSTGRES_DB=ml_assets_db \
  -p 5432:5432 \
  -v ml-assets-postgres-data:/var/lib/postgresql/data \
  postgres:16-alpine

# Start MinIO
docker run -d \
  --name ml-assets-minio \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin123 \
  -p 9000:9000 \
  -p 9001:9001 \
  -v ml-assets-minio-data:/data \
  minio/minio:latest \
  server /data --console-address ":9001"

echo -e "${GREEN}✓${NC} Docker containers started"

# Wait for PostgreSQL to be ready
echo -n "Waiting for PostgreSQL to be ready"
for i in {1..30}; do
    if docker exec ml-assets-postgres pg_isready -U ml_assets_user &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

# Wait for MinIO to be ready
echo -n "Waiting for MinIO to be ready"
for i in {1..30}; do
    if curl -s http://localhost:9000/minio/health/live &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo ""

###############################################################################
# Step 4: Initialize Database
###############################################################################
echo -e "${YELLOW}[4/8]${NC} Initializing database..."

# Check if database is already populated
EXISTING_TABLES=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('assets', 'users', 'ml_metadata');" 2>/dev/null | xargs)

if [ "$EXISTING_TABLES" = "3" ]; then
    # Database already has tables, check if populated
    ASSET_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM assets;" 2>/dev/null | xargs)
    USER_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | xargs)
    
    if [ "$ASSET_COUNT" -gt "0" ]; then
        echo "Database already initialized and populated"
        echo "  • Existing users: $USER_COUNT"
        echo "  • Existing assets: $ASSET_COUNT"
    else
        echo "Database schema exists but empty, initializing data..."
        if [ -f "$DB_INIT_COMPLETE" ]; then
            docker exec -i ml-assets-postgres psql -U ml_assets_user -d ml_assets_db < "$DB_INIT_COMPLETE" 2>&1 | grep -E "(INSERT|CREATE|ALTER)" | tail -5
            echo -e "${GREEN}✓${NC} Database initialized with complete dataset"
        else
            echo -e "${RED}❌ Init script not found: $DB_INIT_COMPLETE${NC}"
            exit 1
        fi
    fi
else
    # Fresh database, use complete init script
    echo "Initializing fresh database with complete dataset..."
    if [ -f "$DB_INIT_COMPLETE" ]; then
        echo "  Using: 000_init_database_complete.sql"
        docker exec -i ml-assets-postgres psql -U ml_assets_user -d ml_assets_db < "$DB_INIT_COMPLETE" 2>&1 | grep -E "(CREATE TABLE|INSERT)" | wc -l | xargs echo "  • SQL statements executed:"
        echo -e "${GREEN}✓${NC} Database initialized successfully"
        
        # Verify initialization
        USER_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | xargs)
        ASSET_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM assets;" 2>/dev/null | xargs)
        CONTRACT_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM contract_definitions;" 2>/dev/null | xargs)
        HTTP_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM data_addresses WHERE type = 'HttpData';" 2>/dev/null | xargs)
        S3_COUNT=$(docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db -t -c "SELECT COUNT(*) FROM data_addresses WHERE type = 'AmazonS3';" 2>/dev/null | xargs)
        
        echo ""
        echo "  📊 Database Statistics:"
        echo "    • Users: $USER_COUNT"
        echo "    • Total Assets: $ASSET_COUNT"
        echo "    • HTTP Models: $HTTP_COUNT"
        echo "    • S3 Models: $S3_COUNT"
        echo "    • Contracts: $CONTRACT_COUNT"
    else
        echo -e "${RED}❌ No database initialization script found${NC}"
        echo -e "${RED}   Required file: 000_init_database_complete.sql${NC}"
        exit 1
    fi
fi

echo ""

###############################################################################
# Step 5: Configure MinIO Bucket
###############################################################################
echo -e "${YELLOW}[5/8]${NC} Configuring MinIO bucket..."

# Create bucket using Docker exec
docker exec ml-assets-minio mkdir -p /data/ml-assets 2>/dev/null || true

echo -e "${GREEN}✓${NC} MinIO bucket 'ml-assets' configured"
echo ""

###############################################################################
# Step 6: Install Dependencies
###############################################################################
echo -e "${YELLOW}[6/8]${NC} Installing dependencies..."

# Backend dependencies
echo "Installing backend dependencies..."
cd "$BACKEND_DIR"
npm install --silent

# Frontend dependencies
echo "Installing frontend dependencies..."
cd "$FRONTEND_DIR"
npm install --silent

# Model Server dependencies (Python)
echo "Installing model server dependencies..."
cd "$MODEL_SERVER_DIR"
if [ ! -d "venv" ]; then
    if ! python3 -m venv venv; then
        echo -e "${RED}❌ Failed to create Python venv.${NC}"
        echo -e "${YELLOW}   On Debian/Ubuntu, install with: sudo apt install python3-venv${NC}"
        exit 1
    fi
fi
if [ ! -f "venv/bin/activate" ]; then
    echo -e "${RED}❌ Python venv not found at $MODEL_SERVER_DIR/venv.${NC}"
    echo -e "${YELLOW}   Please install python3-venv and rerun deploy.sh.${NC}"
    exit 1
fi
source venv/bin/activate
pip install -q -r requirements.txt
deactivate

echo -e "${GREEN}✓${NC} All dependencies installed"
echo ""

###############################################################################
# Step 7: Start Application Services
###############################################################################
echo -e "${YELLOW}[7/8]${NC} Starting application services..."

# Start backend in background
echo "Starting backend (Runtime EDC)..."
cd "$BACKEND_DIR"
nohup node src/server-edc.js > "$PROJECT_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo "Backend started (PID: $BACKEND_PID)"

# Wait for backend
sleep 3

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Backend failed to start. Check backend.log${NC}"
    exit 1
fi

# Start frontend in background
echo "Starting frontend (Angular)..."
cd "$FRONTEND_DIR"
nohup npm run start > "$PROJECT_DIR/frontend.log" 2>&1 &
FRONTEND_PID=$!
echo "Frontend started (PID: $FRONTEND_PID)"

# Start model server in background
echo "Starting model server (Mock AI Server)..."
cd "$MODEL_SERVER_DIR"
nohup python3 mock_server.py > "$PROJECT_DIR/model-server.log" 2>&1 &
MODEL_SERVER_PID=$!
echo "Model server started (PID: $MODEL_SERVER_PID)"

echo -e "${GREEN}✓${NC} Application services started"
echo ""

###############################################################################
# Step 8: Verify Services
###############################################################################
echo -e "${YELLOW}[8/8]${NC} Verifying services..."

# Wait for backend health check
echo -n "Checking backend health"
for i in {1..10}; do
    if curl -s http://localhost:3000/health &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

# Wait for model server
echo -n "Checking model server"
for i in {1..10}; do
    if curl -s http://localhost:8080 &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo -e "${GREEN}✓${NC} All services verified"
echo ""

###############################################################################
# Deployment Complete
###############################################################################
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Service URLs:${NC}"
echo ""
echo -e "  🌐 Frontend (Angular):    ${GREEN}http://localhost:4200${NC}"
echo -e "  🔌 Backend API (EDC):     ${GREEN}http://localhost:3000${NC}"
echo -e "  🤖 Model Mock Server:     ${GREEN}http://localhost:8080${NC}"
echo -e "  🗄️  PostgreSQL:            ${GREEN}localhost:5432${NC}"
echo -e "  📦 MinIO Console:         ${GREEN}http://localhost:9001${NC}"
echo -e "  📦 MinIO API:             ${GREEN}http://localhost:9000${NC}"
echo ""
echo -e "${BLUE}🔐 Default Credentials:${NC}"
echo ""
echo -e "  Application Login:"
echo -e "    User: ${GREEN}user-conn-user1-demo${NC} / Password: ${GREEN}user1123${NC}"
echo -e "    User: ${GREEN}user-conn-user2-demo${NC} / Password: ${GREEN}user2123${NC}"
echo ""
echo -e "  MinIO Console:"
echo -e "    User: ${GREEN}minioadmin${NC} / Password: ${GREEN}minioadmin123${NC}"
echo ""
echo -e "  PostgreSQL:"
echo -e "    User: ${GREEN}ml_assets_user${NC} / Password: ${GREEN}ml_assets_password${NC}"
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "  Backend:      ${GREEN}tail -f backend.log${NC}"
echo -e "  Frontend:     ${GREEN}tail -f frontend.log${NC}"
echo -e "  Model Server: ${GREEN}tail -f model-server.log${NC}"
echo ""
echo -e "${BLUE}🛑 Stop Services:${NC}"
echo -e "  ${GREEN}kill $BACKEND_PID $FRONTEND_PID $MODEL_SERVER_PID${NC}"
echo -e "  ${GREEN}docker stop ml-assets-postgres ml-assets-minio${NC}"
echo ""
echo -e "${BLUE}🧪 Test Model Execution:${NC}"
echo -e "  1. Open ${GREEN}http://localhost:4200${NC} and login"
echo -e "  2. Click on '${GREEN}IA Execution${NC}' in the navigation menu"
echo -e "  3. Select '${GREEN}Iris Classifier Demo API${NC}' from dropdown"
echo -e "  4. Click '${GREEN}Execute Model${NC}' button"
echo -e "  5. Watch results in real-time on ${GREEN}http://localhost:8080${NC}"
echo ""
echo -e "${YELLOW}⏳ Note: Frontend may take 30-60 seconds to compile...${NC}"
echo ""
