#!/bin/bash
set -e

echo "⚡ Legal AI Toolkit - Quick Development Mode"
echo "============================================"

# Function to show quick menu
show_menu() {
    echo ""
    echo "🚀 Quick Development Options:"
    echo "  1. Desktop App Only        (cargo tauri dev)"
    echo "  2. Web Portal Only         (FastAPI + Svelte)"
    echo "  3. Full Environment        (Everything)"
    echo "  4. Services Only           (Docker services)"
    echo "  5. Status Check            (Show what's running)"
    echo "  6. Stop Everything         (Cleanup all)"
    echo ""
    echo "  q. Quit"
    echo ""
}

# Function to wait for keypress
wait_for_key() {
    echo ""
    echo "Press any key to return to menu..."
    read -n 1 -s
}

# Function to run desktop only
run_desktop() {
    echo "🖥️  Starting Desktop App Only..."
    ./scripts/dev-desktop.sh
}

# Function to run web only
run_web() {
    echo "🌐 Starting Web Portal Only..."
    echo "💡 Make sure services are running (option 4) for full functionality"
    ./scripts/dev-web.sh
}

# Function to run everything
run_all() {
    echo "🚀 Starting Full Environment..."
    ./scripts/dev-all.sh
}

# Function to run services only
run_services() {
    echo "🐳 Managing Services..."
    ./scripts/dev-services.sh start
    wait_for_key
}

# Function to show status
show_status() {
    echo "📊 Current Status:"
    echo "=================="
    
    # Check if Tauri is running
    if pgrep -f "cargo tauri dev" > /dev/null; then
        echo "✅ Desktop App: Running"
    else
        echo "❌ Desktop App: Not running"
    fi
    
    # Check if web backend is running
    if nc -z localhost 8000; then
        echo "✅ Web Backend: Running (http://localhost:8000)"
    else
        echo "❌ Web Backend: Not running"
    fi
    
    # Check if web frontend is running
    if nc -z localhost 3001; then
        echo "✅ Web Frontend: Running (http://localhost:3001)"
    else
        echo "❌ Web Frontend: Not running"
    fi
    
    # Check services
    echo ""
    echo "🐳 Docker Services:"
    if command -v docker-compose &> /dev/null; then
        docker-compose -f docker-compose.dev.yml ps 2>/dev/null || echo "No services running"
    else
        echo "Docker Compose not available"
    fi
    
    wait_for_key
}

# Function to stop everything
stop_all() {
    echo "🛑 Stopping Everything..."
    
    # Kill development processes
    echo "Stopping development processes..."
    pkill -f "cargo tauri dev" 2>/dev/null || true
    pkill -f "uvicorn main:app" 2>/dev/null || true
    pkill -f "npm run dev" 2>/dev/null || true
    
    # Stop Docker services
    echo "Stopping Docker services..."
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    
    echo "✅ Everything stopped"
    wait_for_key
}

# Make sure we're in the right directory
if [ ! -f "Cargo.toml" ]; then
    echo "❌ Error: Must run from project root"
    exit 1
fi

# Make scripts executable
chmod +x scripts/*.sh

# Main loop
while true; do
    clear
    echo "⚡ Legal AI Toolkit - Quick Development Mode"
    echo "============================================"
    
    show_menu
    read -p "Choose an option (1-6, q): " choice
    
    case $choice in
        1)
            run_desktop
            ;;
        2)
            run_web
            ;;
        3)
            run_all
            ;;
        4)
            run_services
            ;;
        5)
            show_status
            ;;
        6)
            stop_all
            ;;
        q|Q)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please choose 1-6 or q."
            sleep 2
            ;;
    esac
done