#!/bin/bash

# Super-Architect AI Agent Local Development Startup Script

set -e

echo "🚀 Starting Super-Architect AI Agent local development environment..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run ./scripts/setup-dev.sh first"
    exit 1
fi

# Activate virtual environment
echo "🐍 Activating Python virtual environment..."
source venv/bin/activate

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "⚠️  .env.local not found. Creating from template..."
    cp .env.template .env.local
    echo "📝 Please edit .env.local with your configuration before continuing"
    echo "Press Enter when ready to continue..."
    read
fi

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose -f docker-compose.dev.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🔍 Checking service health..."
docker-compose -f docker-compose.dev.yml ps

# Start the application (placeholder - will be implemented with actual services)
echo "🎯 Starting Super-Architect AI Agent services..."

# For now, just show the status since we don't have actual services yet
echo "✅ Development environment is ready!"
echo ""
echo "📋 Available services:"
echo "- PostgreSQL: localhost:5432"
echo "- MongoDB: localhost:27017" 
echo "- Neo4j: http://localhost:7474 (browser), bolt://localhost:7687 (driver)"
echo "- Redis: localhost:6379"
echo ""
echo "📚 Next steps:"
echo "1. Implement core services in src/"
echo "2. Run tests: pytest"
echo "3. Start development: python -m src.main (when implemented)"
echo ""
echo "🛑 To stop services: docker-compose -f docker-compose.dev.yml down"
echo "🔄 To restart services: ./scripts/start-local.sh"

