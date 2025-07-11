#!/bin/bash
set -e

echo "🌐 Legal AI Toolkit - Web Portal Development"
echo "============================================"

# Check if we're in the right directory
if [ ! -d "web-portal" ]; then
    echo "❌ Error: Must run from project root (web-portal directory not found)"
    exit 1
fi

# Function to start backend
start_backend() {
    echo "🐍 Starting FastAPI backend..."
    cd web-portal/backend
    
    # Check if virtual environment exists, create if not
    if [ ! -d "venv" ]; then
        echo "📦 Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install requirements if needed
    if [ ! -f ".deps_installed" ]; then
        echo "📦 Installing Python dependencies..."
        pip install -r requirements.txt
        touch .deps_installed
    fi
    
    # Set environment variables
    export PYTHON_ENV=development
    export DATABASE_URL="postgresql://legal_user:legal_dev_password@localhost:5432/legal_toolkit"
    export JWT_SECRET_KEY="development-secret-key-change-in-production"
    export STRIPE_SECRET_KEY="sk_test_..."
    
    echo "🚀 Starting FastAPI server on http://localhost:8000"
    echo "📚 API docs: http://localhost:8000/docs"
    echo ""
    
    uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
    BACKEND_PID=$!
    cd ../..
}

# Function to start frontend
start_frontend() {
    echo "⚡ Starting Svelte frontend..."
    cd web-portal/frontend
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing Node.js dependencies..."
        npm install
    fi
    
    # Set environment variables
    export NODE_ENV=development
    export VITE_API_URL="http://localhost:8000"
    
    echo "🚀 Starting Svelte dev server on http://localhost:3001"
    echo ""
    
    npm run dev -- --host 0.0.0.0 --port 3001 &
    FRONTEND_PID=$!
    cd ../..
}

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping web portal servers..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    echo "✅ Cleanup complete"
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Check if services are available
echo "🔍 Checking web development dependencies..."

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Install Python first."
    exit 1
fi

# Check Node.js
if ! command -v npm &> /dev/null; then
    echo "❌ Node.js/npm not found. Install Node.js first."
    exit 1
fi

# Check if PostgreSQL is running (from docker-compose)
if ! nc -z localhost 5432; then
    echo "⚠️  PostgreSQL not detected on localhost:5432"
    echo "💡 Run './scripts/dev-services.sh start' to start database"
    echo "🔄 Continuing without database (some features may not work)..."
fi

echo "✅ Dependencies ready"
echo ""

# Start both services
start_backend
sleep 2
start_frontend

echo "🌟 Web portal development environment ready!"
echo ""
echo "📊 Services:"
echo "  • Backend API: http://localhost:8000"
echo "  • Frontend App: http://localhost:3001" 
echo "  • API Documentation: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for processes
wait