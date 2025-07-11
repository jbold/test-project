#!/bin/bash
set -e

echo "🔄 Legal AI Toolkit - Post-Start Setup"
echo "====================================="

# Start background services
echo "🚀 Starting background services..."

# Start IPFS daemon if not running
if ! pgrep -f "ipfs daemon" > /dev/null; then
    echo "Starting IPFS daemon..."
    nohup ipfs daemon > /dev/null 2>&1 &
    sleep 3
fi

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check service status
echo "📊 Service Status:"
echo "- IPFS: $(ipfs --version 2>/dev/null || echo 'Not ready')"
echo "- Rust: $(rustc --version 2>/dev/null || echo 'Not ready')"
echo "- Node: $(node --version 2>/dev/null || echo 'Not ready')"
echo "- Python: $(python3 --version 2>/dev/null || echo 'Not ready')"
echo "- WasmEdge: $(wasmedge --version 2>/dev/null || echo 'Not ready')"

# Display development commands
echo ""
echo "🎯 Quick Development Commands:"
echo "  ltdev      - Start Tauri development server"
echo "  ltbuild    - Build Tauri application"
echo "  webdev     - Start web portal development"
echo "  ipfsstart  - Start IPFS daemon"
echo ""
echo "🌟 Environment ready for superintelligent development!"