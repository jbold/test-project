#!/bin/bash
set -e

echo "🚀 Legal AI Toolkit - Full Development Environment"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "Cargo.toml" ] || [ ! -d "web-portal" ]; then
    echo "❌ Error: Must run from project root"
    exit 1
fi

# Function to start services
start_services() {
    echo "🐳 Starting backing services..."
    docker compose -f docker-compose.dev.yml up -d postgres redis ipfs vector-db minio
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to start..."
    sleep 10
    
    echo "✅ Backing services ready"
}

# Function to start web portal
start_web() {
    echo "🌐 Starting web portal..."
    cd web-portal/backend
    
    # Create virtual environment if needed
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    
    # Install requirements if needed
    if [ ! -f ".deps_installed" ]; then
        pip install -r requirements.txt
        touch .deps_installed
    fi
    
    # Set environment variables
    export PYTHON_ENV=development
    export DATABASE_URL="postgresql://legal_user:legal_dev_password@localhost:5432/legal_toolkit"
    export JWT_SECRET_KEY="development-secret-key-change-in-production"
    export STRIPE_SECRET_KEY="sk_test_..."
    
    uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
    WEB_BACKEND_PID=$!
    cd ../..
    
    # Start web frontend
    cd web-portal/frontend
    if [ ! -d "node_modules" ]; then
        npm install
    fi
    
    export NODE_ENV=development
    export VITE_API_URL="http://localhost:8000"
    
    npm run dev -- --host 0.0.0.0 --port 3001 &
    WEB_FRONTEND_PID=$!
    cd ../..
}

# Function to start desktop app
start_desktop() {
    echo "🖥️  Starting desktop app..."
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        npm install
    fi
    
    if [ ! -d "target" ]; then
        cargo fetch
    fi
    
    # Set environment variables
    export RUST_LOG=debug
    export TAURI_DEBUG=true
    export NODE_ENV=development
    
    cargo tauri dev &
    DESKTOP_PID=$!
}

# Function to start AI services
start_ai() {
    echo "🤖 Starting AI services..."
    
    # Start IPFS daemon if not running
    if ! pgrep -f "ipfs daemon" > /dev/null; then
        ipfs daemon &
        IPFS_PID=$!
    fi
    
    # TODO: Start LlamaEdge when implemented
    echo "💡 AI agents will be started in next development phase"
}

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping all services..."
    
    # Kill all development processes
    [ ! -z "$WEB_BACKEND_PID" ] && kill $WEB_BACKEND_PID 2>/dev/null || true
    [ ! -z "$WEB_FRONTEND_PID" ] && kill $WEB_FRONTEND_PID 2>/dev/null || true
    [ ! -z "$DESKTOP_PID" ] && kill $DESKTOP_PID 2>/dev/null || true
    [ ! -z "$IPFS_PID" ] && kill $IPFS_PID 2>/dev/null || true
    
    # Stop docker services
    echo "🐳 Stopping Docker services..."
    docker compose -f docker-compose.dev.yml down
    
    echo "✅ Full cleanup complete"
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Check dependencies
echo "🔍 Checking development dependencies..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker first."
    exit 1
fi

# Check Docker Compose (try both old and new syntax)
if ! (command -v docker-compose &> /dev/null || docker compose version &> /dev/null); then
    echo "❌ Docker Compose not found. Install Docker Compose."
    exit 1
fi

# Check Rust
if ! command -v cargo &> /dev/null; then
    echo "❌ Cargo not found. Install Rust first."
    exit 1
fi

# Check Node.js
if ! command -v npm &> /dev/null; then
    echo "❌ Node.js/npm not found. Install Node.js first."
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Install Python first."
    exit 1
fi

echo "✅ All dependencies ready"
echo ""

# Start all services
start_services
sleep 3
start_web
sleep 3
start_ai
sleep 3

echo "🌟 Full development environment ready!"
echo ""
echo "📊 Services Running:"
echo "  🌐 Web Backend:     http://localhost:8000"
echo "  🌐 Web Frontend:    http://localhost:3001"
echo "  🖥️  Desktop App:     Starting Tauri window"
echo "  🗄️  PostgreSQL:     localhost:5432"
echo "  🗄️  Redis:          localhost:6379"
echo "  🌐 IPFS API:        localhost:5001"
echo "  🤖 Vector DB:       localhost:6333"
echo ""
echo "📚 Documentation:"
echo "  • API Docs:         http://localhost:8000/docs"
echo "  • IPFS Gateway:     http://localhost:8080"
echo "  • Vector DB UI:     http://localhost:6333/dashboard"
echo ""
echo "⚡ Ultra-Rapid Development Mode Active!"
echo ""
echo "🚀 To start desktop app:"
echo "  cargo tauri dev"
echo ""
echo "Press Ctrl+C to stop all services"

# Keep services running
while true; do
    sleep 1
done