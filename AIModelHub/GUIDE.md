# 🚀 AIModelHub - Complete Guide

**AI Model Management Platform for Data Spaces**

Complete platform for managing AI models with EDC-compatible runtime in Node.js and Angular frontend for exploring, registering, and executing IA assets with S3 storage, rich metadata, and model execution capabilities.

---

## 📋 Table of Contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Quick Start](#quick-start)
5. [Project Structure](#project-structure)
6. [Services](#services)
7. [Model Execution Feature](#model-execution-feature)
8. [Testing Guide](#testing-guide)
9. [Advanced Configuration](#advanced-configuration)
10. [Troubleshooting](#troubleshooting)
11. [Contributing](#contributing)

---

## 🎯 Features

### Core Features
- ✅ **EDC-Compatible Backend** - Node.js runtime with modular extensions
- ✅ **Asset Management** - Register, browse, and manage AI models
- ✅ **ML Metadata** - Rich metadata for models (algorithm, framework, metrics)
- ✅ **S3 Storage** - MinIO integration for artifact storage
- ✅ **Authentication** - User management and access control
- ✅ **Angular UI** - Modern, responsive interface for asset exploration
- ✅ **Contract Definitions** - EDC-style policies and contracts
- ✅ **Catalog Federation** - Discover assets from multiple connectors

### Model Execution (NEW)
- ✅ **HTTP Model Invocation** - Execute models through REST API endpoints
- ✅ **Execution Dashboard** - Visual interface for model execution
- ✅ **Input Editor** - JSON editor with validation
- ✅ **Result Visualization** - View execution results and errors
- ✅ **Execution History** - Track all model executions
- ✅ **Mock Server** - Test environment with 3 sample models
- ✅ **Real-time Monitoring** - Dashboard showing live execution logs

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AIModelHub                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────┐            │
│  │  Angular Frontend│◄────────┤  Backend EDC API │            │
│  │  (Port 4200)     │  HTTP   │  (Port 3000)     │            │
│  └──────────────────┘         └─────────┬────────┘            │
│           │                              │                      │
│           │                              │                      │
│           │                    ┌─────────▼────────┐            │
│           │                    │   PostgreSQL     │            │
│           │                    │   (Port 5432)    │            │
│           │                    └──────────────────┘            │
│           │                                                     │
│           │                    ┌──────────────────┐            │
│           └────────────────────┤  MinIO S3        │            │
│                                │  (Port 9000/9001)│            │
│                                └──────────────────┘            │
│                                                                 │
│  ┌──────────────────┐         ┌──────────────────┐            │
│  │  Mock AI Server  │◄────────┤ Model Execution  │            │
│  │  (Port 8080)     │  HTTP   │  Extension       │            │
│  └──────────────────┘         └──────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

### Components

1. **Frontend (Angular 18+)**
   - Asset browser and catalog
   - Asset creation forms
   - Model execution interface
   - Contract management

2. **Backend (Node.js + Express)**
   - EDC-compatible runtime
   - Extension-based architecture
   - REST API endpoints
   - Model execution orchestrator

3. **Database (PostgreSQL 16)**
   - Assets, users, contracts
   - ML metadata
   - Execution history

4. **Storage (MinIO)**
   - Model artifacts
   - Training data
   - Documentation files

5. **Mock Server (Python + Flask)**
   - 3 sample AI models
   - Real-time dashboard
   - Execution logging

---

## 📋 Prerequisites

| Component | Minimum Version | Check Command |
|-----------|-----------------|---------------|
| **Docker** | 20.10+ | `docker --version` |
| **Node.js** | 18+ | `node --version` |
| **npm** | 9+ | `npm --version` |
| **Python** | 3.8+ | `python3 --version` |
| **Git** | 2.0+ | `git --version` |

**Recommended Resources:**
- CPU: 2 cores
- RAM: 4 GB
- Disk: 10 GB free space

---

## ⚡ Quick Start

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd AIModelHub
```

### 2. Deploy Everything (Recommended)

```bash
./deploy.sh
```

This script automatically:
- ✅ Checks prerequisites
- ✅ Stops existing services
- ✅ Starts PostgreSQL + MinIO containers
- ✅ Restores database with sample data
- ✅ Installs all dependencies (Node.js + Python)
- ✅ Starts backend, frontend, and mock server
- ✅ Verifies all services are running

**Estimated time:** 3-5 minutes

### 3. Access the Application

Once deployment completes:

1. **Open Frontend**: http://localhost:4200 (**Important: Use `localhost`, NOT `127.0.0.1`**)
2. **Login**: `user-conn-user1-demo` / `user1123`
3. **Explore the interface**

> ⚠️ **Important**: Always access the application using `http://localhost:4200`. Do NOT use `http://127.0.0.1:4200` as this will cause CORS errors due to origin mismatch.

---

## 📁 Project Structure

```
AIModelHub/
├── deploy.sh                           # Automated deployment script
├── GUIDE.md                            # This file
├── .gitignore                          # Git ignore rules
│
├── AIModelHub_Extensiones/             # Backend logic
│   ├── backend/                        # Main backend (symlink → runtime-edc-backend)
│   │   ├── src/                        # Source code
│   │   │   ├── server-edc.js          # Main server
│   │   │   └── routes/                # API routes
│   │   ├── edc-extensions/            # EDC extensions
│   │   │   ├── asset-management/      # Asset CRUD
│   │   │   ├── ml-metadata/           # ML-specific metadata
│   │   │   └── model-execution/       # Model execution (NEW)
│   │   └── package.json               # Backend dependencies
│   │
│   ├── database-scripts/               # Database initialization scripts
│   │   ├── 000_init_database_complete.sql  # Complete DB dump (PRIMARY)
│   │   ├── init-database.sql          # Schema initialization (FALLBACK)
│   │   ├── full-backup.sql            # Sample data (FALLBACK)
│   │   ├── deploy_system.sh           # Standalone deployment
│   │   └── generate-password-hash.js  # Password utility
│   │
│   ├── database/                       # Database (symlink → database-scripts)
│   │
│   ├── model-server/                   # Mock server (symlink → model-serving)
│   │   ├── mock_server.py             # Flask server
│   │   ├── requirements.txt           # Python dependencies
│   │   ├── start-mock-server.sh       # Startup script
│   │   └── venv/                      # Python virtual environment
│   │
│   └── docker-compose.yml              # PostgreSQL + MinIO
│
└── AIModelHub_EDCUI/                   # Frontend
    └── ml-browser-app/                 # Angular app (symlink → ui-model-browser)
        ├── src/
        │   ├── app/
        │   │   ├── pages/             # Page components
        │   │   │   ├── ml-assets-browser/
        │   │   │   ├── asset-detail/
        │   │   │   ├── asset-create/
        │   │   │   ├── model-execution/  # NEW
        │   │   │   ├── catalog/
        │   │   │   └── contracts/
        │   │   ├── shared/
        │   │   │   ├── components/    # Navigation, etc.
        │   │   │   └── services/      # API services
        │   │   └── app.routes.ts      # Routing configuration
        │   └── environments/
        └── package.json                # Frontend dependencies
```

---

## 🌐 Services

### Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:4200 | Angular application (⚠️ Use `localhost` only) |
| **Backend API** | http://localhost:3000 | EDC + Management API |
| **Mock Server** | http://localhost:8080 | Model execution dashboard |
| **MinIO Console** | http://localhost:9001 | S3 web interface |
| **PostgreSQL** | localhost:5432 | Database |

> ⚠️ **Important**: The frontend is configured to run on `localhost:4200` specifically. Using `127.0.0.1:4200` will cause CORS authentication errors.

### Default Credentials

**Application Login:**
```
User: user-conn-user1-demo
Password: user1123

User: user-conn-user2-demo  
Password: user2123
```

**MinIO Console:**
```
User: minioadmin
Password: minioadmin123
```

**PostgreSQL:**
```
User: ml_assets_user
Password: ml_assets_password
Database: ml_assets_db
```

---

## 🚀 Model Execution Feature

The Model Execution feature allows you to execute AI models through HTTP endpoints directly from the AIModelHub interface.

### Key Components

#### 1. Backend Extension (`edc-extensions/model-execution/`)
- **extension.manifest.js** - Main extension with REST endpoints
- **ExecutionService.js** - HTTP invocation service

**REST API Endpoints:**
```
POST   /v3/models/execute              # Execute a model
GET    /v3/models/executions/:id       # Get execution status
GET    /v3/models/executions           # Get execution history
GET    /v3/models/executable           # List executable models
GET    /v3/assets/:id/executable       # Check if asset is executable
```

#### 2. Frontend Component (`pages/model-execution/`)
- **model-execution.component.ts** - Main execution logic
- **model-execution.component.html** - UI with tabs
- **model-execution.component.scss** - Styled interface

**Features:**
- Model selection dropdown
- JSON input editor with validation
- Result visualization (success/error/timeout)
- Execution history per model
- Direct access from asset detail page

#### 3. Database Schema
- **model_executions** table - Execution tracking
- **executable_assets** view - Quick access to executable models
- **data_addresses** extensions - Execution endpoint, method, timeout

#### 4. Mock Server (`model-server/`)
- **3 Sample Models:**
  - Iris Classifier (POST /api/v1/predict)
  - Sentiment Analyzer (POST /api/v1/sentiment)
  - Image Classifier (POST /api/v1/classify-image)

- **Visual Dashboard** (http://localhost:8080):
  - Real-time execution logs
  - Model cards with endpoints
  - Statistics (total requests, available models)
  - Auto-refresh every 5 seconds

### How to Use

#### Option A: From Asset Browser
1. Go to "AI Assets Browser"
2. Find an executable asset (e.g., "Iris Classifier Demo API")
3. Click on the asset to open details
4. Click the purple "▶ Execute Model" button

#### Option B: Direct Access
1. Click "IA Execution" in the navigation menu
2. Or navigate to: http://localhost:4200/models/execute
3. Select a model from the dropdown
4. Enter input JSON
5. Click "Execute Model"

#### Example: Execute Iris Classifier

1. Select "Iris Classifier Demo API"
2. Input JSON (pre-filled):
```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```
3. Click "Execute Model"
4. View result:
```json
{
  "model": "Iris Classifier",
  "prediction": "setosa",
  "confidence": 0.95,
  "execution_time_ms": 1234
}
```
5. Check execution in history tab
6. See real-time log on http://localhost:8080

### API Usage Example

```bash
# Get executable models
curl http://localhost:3000/v3/models/executable

# Execute a model
curl -X POST http://localhost:3000/v3/models/execute \
  -H "Content-Type: application/json" \
  -d '{
    "assetId": "asset-executable-demo-iris-classifier",
    "input": {
      "sepal_length": 5.1,
      "sepal_width": 3.5,
      "petal_length": 1.4,
      "petal_width": 0.2
    }
  }'

# Get execution status
curl http://localhost:3000/v3/models/executions/{execution_id}

# Get execution history
curl http://localhost:3000/v3/models/executions?assetId=asset-executable-demo-iris-classifier
```

---

## 🧪 Testing Guide

### Complete Testing Workflow

#### 1. Verify All Services

```bash
# Check running processes
ps aux | grep -E "server-edc|ng serve|mock_server"

# Check Docker containers
docker ps | grep ml-assets

# Test backend health
curl http://localhost:3000/health

# Test mock server
curl http://localhost:8080
```

#### 2. Test Model Execution UI

**Step-by-step:**

1. **Open Frontend**: http://localhost:4200
2. **Login**: user-conn-user1-demo / user1123
3. **Navigate**: Click "IA Execution" in menu
4. **Select Model**: Choose "Iris Classifier Demo API"
5. **Execute**: Click "Execute Model"
6. **View Results**: Check Output tab
7. **View History**: Check History tab
8. **Monitor**: Open http://localhost:8080 in another tab

#### 3. Test All Models

**Iris Classifier (fastest):**
```json
{
  "sepal_length": 5.1,
  "sepal_width": 3.5,
  "petal_length": 1.4,
  "petal_width": 0.2
}
```

**Sentiment Analyzer:**
```json
{
  "text": "I love this amazing product! It's wonderful!"
}
```

**Image Classifier:**
```json
{
  "image_url": "https://example.com/image.jpg",
  "image_size": "1920x1080"
}
```

#### 4. Test Error Handling

**Simulate Timeout:**
1. Stop mock server: Press Ctrl+C in mock server terminal
2. Try to execute a model
3. Should see timeout error
4. Restart mock server: `cd AIModelHub_Extensiones/model-server && ./start-mock-server.sh`

**Invalid JSON:**
1. Enter malformed JSON in input editor
2. Should see validation error
3. Fix JSON and retry

---

## 🔧 Advanced Configuration

### Manual Deployment

If you prefer manual control over deployment:

#### 1. Start Infrastructure

```bash
cd AIModelHub

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
  -p 9000:9000 -p 9001:9001 \
  -v ml-assets-minio-data:/data \
  minio/minio:latest server /data --console-address ":9001"
```

#### 2. Initialize Database

```bash
# Option 1: Complete database with all data (RECOMMENDED)
docker exec -i ml-assets-postgres psql -U ml_assets_user -d ml_assets_db \
  < AIModelHub_Extensiones/database-scripts/000_init_database_complete.sql

# Option 2: Sample data only (fallback)
docker exec -i ml-assets-postgres psql -U ml_assets_user -d ml_assets_db \
  < AIModelHub_Extensiones/database-scripts/full-backup.sql

# Option 3: Minimal schema (fallback)
docker exec -i ml-assets-postgres psql -U ml_assets_user -d ml_assets_db \
  < AIModelHub_Extensiones/database-scripts/init-database.sql
```

**Note**: The `000_init_database_complete.sql` includes:
- Complete schema with all tables, indexes, and constraints
- 2 demo users (user1-demo, user2-demo)
- 14 AI models (4 HTTP + 10 S3)
- 8+ contracts with policies
- All metadata and data addresses

#### 3. Install Dependencies

```bash
# Backend
cd AIModelHub_Extensiones/backend
npm install

# Frontend
cd ../../AIModelHub_EDCUI/ml-browser-app
npm install

# Mock Server
cd ../../AIModelHub_Extensiones/model-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
```

#### 4. Start Services

**Terminal 1 - Backend:**
```bash
cd AIModelHub_Extensiones/backend
node src/server-edc.js
```

**Terminal 2 - Frontend:**
```bash
cd AIModelHub_EDCUI/ml-browser-app
npm run start
```

**Terminal 3 - Mock Server:**
```bash
cd AIModelHub_Extensiones/model-server
./start-mock-server.sh
```

### Environment Variables

Create `.env` files for custom configuration:

**Backend (.env):**
```bash
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ml_assets_db
DB_USER=ml_assets_user
DB_PASSWORD=ml_assets_password

S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin123
S3_BUCKET=ml-assets

MODEL_EXECUTION_TIMEOUT=30000
```

**Frontend (environment.ts):**
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000',
  // ... other config
};
```

### Database Regeneration

To regenerate the complete database dump after making changes:

```bash
# Generate new complete dump
docker exec ml-assets-postgres pg_dump -U ml_assets_user -d ml_assets_db \
  --clean --if-exists --no-owner --no-acl \
  > AIModelHub_Extensiones/database-scripts/000_init_database_complete.sql

# Verify the dump
wc -l AIModelHub_Extensiones/database-scripts/000_init_database_complete.sql
```

**Note**: The complete init script (`000_init_database_complete.sql`) replaces the need for incremental migrations. After any database changes, regenerate this file to maintain a single source of truth.

---

## 🐛 Troubleshooting

### Common Issues

#### Port Already in Use

**Problem:** Port 5432, 3000, 4200, or 8080 already in use

**Solution:**
```bash
# Find process using port
sudo lsof -i :5432

# Kill process
kill -9 <PID>

# Or change port in configuration
```

#### Database Connection Failed

**Problem:** Backend can't connect to PostgreSQL

**Solution:**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check logs
docker logs ml-assets-postgres

# Test connection
docker exec -it ml-assets-postgres psql -U ml_assets_user -d ml_assets_db

# Restart container
docker restart ml-assets-postgres
```

#### Frontend Compilation Errors

**Problem:** Angular build fails

**Solution:**
```bash
cd AIModelHub_EDCUI/ml-browser-app

# Clean install
rm -rf node_modules package-lock.json
npm install

# Check Node version (must be 18+)
node --version

# Clear Angular cache
rm -rf .angular/cache
```

#### CORS Authentication Errors

**Problem:** "Invalid username or password" despite correct credentials, or OPTIONS preflight fails

**Solution:**
```bash
# CRITICAL: Use localhost, NOT 127.0.0.1
# Open browser with: http://localhost:4200
# NOT: http://127.0.0.1:4200

# The system is configured for localhost origin only
# Check that Angular is serving on localhost
ps aux | grep "ng serve"

# Verify CORS configuration in backend logs
grep "CORS" backend.log

# If needed, restart frontend
pkill -f "ng serve"
cd AIModelHub_EDCUI/ml-browser-app
npm run start
```

#### Model Execution Fails

**Problem:** "Cannot connect to model endpoint"

**Solution:**
```bash
# Check if mock server is running
curl http://localhost:8080

# Check logs
tail -f model-server.log

# Restart mock server
cd AIModelHub_Extensiones/model-server
./start-mock-server.sh

# Verify executable assets in database
docker exec ml-assets-postgres psql -U ml_assets_user -d ml_assets_db \
  -c "SELECT * FROM executable_assets;"
```

#### Backend Extension Not Loading

**Problem:** Model execution extension doesn't load

**Solution:**
```bash
# Check backend logs
tail -f backend.log

# Look for extension initialization
grep "Model Execution Extension" backend.log

# Verify extension file exists
ls -la AIModelHub_Extensiones/backend/edc-extensions/model-execution/

# Restart backend
pkill -f "server-edc.js"
cd AIModelHub_Extensiones/backend
node src/server-edc.js
```

### Log Files

```bash
# Backend
tail -f backend.log

# Frontend
tail -f frontend.log

# Mock Server
tail -f model-server.log

# Deployment
tail -f deploy-output.log

# PostgreSQL
docker logs ml-assets-postgres

# MinIO
docker logs ml-assets-minio
```

### Stop All Services

```bash
# Stop Node processes
pkill -f "server-edc.js"
pkill -f "ng serve"
pkill -f "mock_server.py"

# Stop Docker containers
docker stop ml-assets-postgres ml-assets-minio

# Remove containers (keeps data)
docker rm ml-assets-postgres ml-assets-minio

# Remove everything including data (CAUTION!)
docker rm -f ml-assets-postgres ml-assets-minio
docker volume rm ml-assets-postgres-data ml-assets-minio-data
```

---

## 🤝 Contributing

### Development Workflow

1. **Create Feature Branch**
```bash
git checkout -b feature/my-new-feature
```

2. **Make Changes**
- Follow existing code structure
- Add comments for complex logic
- Update documentation

3. **Test Changes**
```bash
# Run backend tests (if available)
cd AIModelHub_Extensiones/backend
npm test

# Run frontend tests
cd AIModelHub_EDCUI/ml-browser-app
npm test
```

4. **Commit and Push**
```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/my-new-feature
```

5. **Create Pull Request**

### Code Style

- **Backend (Node.js)**: ESLint + Prettier
- **Frontend (Angular)**: Angular style guide
- **Python**: PEP 8

### Adding New Features

#### New Backend Extension

1. Create extension directory:
```bash
mkdir -p AIModelHub_Extensiones/backend/edc-extensions/my-extension
```

2. Create manifest file:
```javascript
// extension.manifest.js
module.exports = {
  name: 'MyExtension',
  version: '1.0.0',
  initialize: (context) => {
    // Extension initialization
  }
};
```

3. Register in bootstrap:
```javascript
// src/bootstrap.js
const MyExtension = require('./edc-extensions/my-extension/extension.manifest');
```

#### New Frontend Page

1. Generate component:
```bash
cd AIModelHub_EDCUI/ml-browser-app
ng generate component pages/my-page
```

2. Add route:
```typescript
// app.routes.ts
{
  path: 'my-page',
  component: MyPageComponent,
  canActivate: [authGuard]
}
```

3. Add menu item:
```typescript
// shared/components/navigation/navigation.component.ts
menuItems = [
  // ... existing items
  {
    path: '/my-page',
    label: 'My Page',
    icon: 'star'
  }
];
```

---

## 📝 License

[Add your license here]

---

## 🙏 Acknowledgments

This project was developed as part of [project/initiative name].

**Funding:**
- [Funding source 1]
- [Funding source 2]

---

## 📞 Support

For issues, questions, or contributions:
- **Issues**: [GitHub Issues URL]
- **Discussions**: [GitHub Discussions URL]
- **Email**: [contact email]

---

**Last Updated:** January 22, 2026
**Version:** 2.0.0
