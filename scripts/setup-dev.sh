#!/bin/bash

# Super-Architect AI Agent Development Environment Setup
# This script sets up the development environment for the Super-Architect project

set -e

echo "🚀 Setting up Super-Architect AI Agent development environment..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if [[ $(echo "$PYTHON_VERSION < 3.9" | bc -l) -eq 1 ]]; then
    echo "❌ Python 3.9+ is required, found $PYTHON_VERSION"
    exit 1
fi
echo "✅ Python $PYTHON_VERSION found"

# Check Node.js version
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed"
    exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//')
if [[ $(echo "$NODE_VERSION < 18.0" | bc -l) -eq 1 ]]; then
    echo "❌ Node.js 18+ is required, found $NODE_VERSION"
    exit 1
fi
echo "✅ Node.js $NODE_VERSION found"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
    exit 1
fi
echo "✅ Docker found"

# Create virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt || echo "⚠️  requirements.txt not found, skipping Python dependencies"

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install || echo "⚠️  package.json not found, skipping Node.js dependencies"

# Set up pre-commit hooks
echo "🔧 Setting up pre-commit hooks..."
pip install pre-commit
pre-commit install || echo "⚠️  .pre-commit-config.yaml not found, skipping pre-commit setup"

# Create necessary directories
echo "📁 Creating project directories..."
mkdir -p logs
mkdir -p data
mkdir -p config
mkdir -p .env.local

# Set up environment variables template
echo "🔧 Creating environment template..."
cat > .env.template << EOF
# Super-Architect AI Agent Configuration Template
# Copy this file to .env.local and fill in your values

# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/super_architect
MONGODB_URL=mongodb://localhost:27017/super_architect
NEO4J_URL=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password

# AI Provider Configuration
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
AZURE_OPENAI_ENDPOINT=your_azure_endpoint_here
AZURE_OPENAI_API_KEY=your_azure_api_key_here

# Authentication Configuration
JWT_SECRET_KEY=your_jwt_secret_key_here
OAUTH_CLIENT_ID=your_oauth_client_id_here
OAUTH_CLIENT_SECRET=your_oauth_client_secret_here

# External Service Configuration
JIRA_URL=https://your-company.atlassian.net
JIRA_USERNAME=your_jira_username
JIRA_API_TOKEN=your_jira_api_token
CONFLUENCE_URL=https://your-company.atlassian.net/wiki
CONFLUENCE_USERNAME=your_confluence_username
CONFLUENCE_API_TOKEN=your_confluence_api_token

# Application Configuration
APP_ENV=development
LOG_LEVEL=INFO
DEBUG=true
PORT=8000

# Security Configuration
ENCRYPTION_KEY=your_encryption_key_here
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Monitoring Configuration
SENTRY_DSN=your_sentry_dsn_here
PROMETHEUS_ENABLED=true
JAEGER_ENDPOINT=http://localhost:14268/api/traces
EOF

# Set up Docker Compose for local development
echo "🐳 Creating Docker Compose configuration..."
cat > docker-compose.dev.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: super_architect
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mongodb:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

  neo4j:
    image: neo4j:5
    environment:
      NEO4J_AUTH: neo4j/password
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j_data:/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  mongodb_data:
  neo4j_data:
  redis_data:
EOF

# Create basic requirements.txt if it doesn't exist
if [ ! -f requirements.txt ]; then
    echo "📝 Creating basic requirements.txt..."
    cat > requirements.txt << EOF
# Super-Architect AI Agent Python Dependencies

# Web Framework
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0

# Database
sqlalchemy==2.0.23
alembic==1.13.1
psycopg2-binary==2.9.9
pymongo==4.6.0
neo4j==5.15.0
redis==5.0.1

# AI/ML
openai==1.3.7
anthropic==0.7.7
langchain==0.0.350
tiktoken==0.5.2

# Authentication & Security
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# HTTP Clients
httpx==0.25.2
aiohttp==3.9.1

# Data Processing
pandas==2.1.4
numpy==1.25.2
pydantic-settings==2.1.0

# Monitoring & Logging
structlog==23.2.0
sentry-sdk==1.38.0
prometheus-client==0.19.0

# Development
pytest==7.4.3
pytest-asyncio==0.21.1
pytest-cov==4.1.0
black==23.11.0
isort==5.12.0
flake8==6.1.0
mypy==1.7.1
pre-commit==3.6.0

# Documentation
mkdocs==1.5.3
mkdocs-material==9.4.8
EOF
fi

# Create basic package.json if it doesn't exist
if [ ! -f package.json ]; then
    echo "📝 Creating basic package.json..."
    cat > package.json << EOF
{
  "name": "super-architect-ai-agent",
  "version": "1.0.0",
  "description": "Super-Architect AI Agent - Revolutionary AI-Powered Development Assistant",
  "main": "index.js",
  "scripts": {
    "dev": "nodemon src/index.js",
    "start": "node src/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "build": "webpack --mode production",
    "build:dev": "webpack --mode development"
  },
  "keywords": [
    "ai",
    "development",
    "assistant",
    "automation",
    "architecture"
  ],
  "author": "TKT Inc",
  "license": "PROPRIETARY",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "winston": "^3.11.0",
    "dotenv": "^16.3.1",
    "axios": "^1.6.2",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "mongoose": "^8.0.3",
    "redis": "^4.6.10"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.55.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-prettier": "^5.0.1",
    "prettier": "^3.1.0",
    "webpack": "^5.89.0",
    "webpack-cli": "^5.1.4"
  }
}
EOF
fi

echo "✅ Development environment setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy .env.template to .env.local and fill in your configuration"
echo "2. Start local services: docker-compose -f docker-compose.dev.yml up -d"
echo "3. Activate virtual environment: source venv/bin/activate"
echo "4. Run the application: ./scripts/start-local.sh"
echo ""
echo "📚 Documentation:"
echo "- README.md - Project overview and getting started"
echo "- CONTRIBUTING.md - Development guidelines"
echo "- docs/ - Comprehensive project documentation"
echo ""
echo "🎉 Happy coding!"
EOF

