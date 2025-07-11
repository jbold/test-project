#!/bin/bash
set -e

echo "🖥️  Legal AI Toolkit - Desktop Development"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "Cargo.toml" ]; then
    echo "❌ Error: Must run from project root (where Cargo.toml exists)"
    exit 1
fi

# Check if required dependencies are available
echo "🔍 Checking desktop development dependencies..."

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

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
fi

if [ ! -d "target" ]; then
    echo "🦀 Fetching Rust dependencies..."
    cargo fetch
fi

# Set environment variables for development
export RUST_LOG=debug
export TAURI_DEBUG=true
export NODE_ENV=development

echo "✅ Dependencies ready"
echo "🚀 Starting Tauri development server..."
echo ""
echo "📱 Desktop app will open automatically"
echo "🔗 Frontend dev server: http://localhost:5173"
echo "🛠️  Tauri dev tools: http://localhost:1420"
echo ""
echo "Press Ctrl+C to stop"

# Start Tauri development server
cargo tauri dev