#!/bin/bash

# Development environment validation script
# Ensures consistency across development instances

set -e

echo "🔧 Validating development environment..."

# Check required tools
REQUIRED_TOOLS=(
    "cargo"
    "node"
    "npm"
    "python3"
    "docker"
    "rg"
)

MISSING_TOOLS=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "❌ Missing required tools: ${MISSING_TOOLS[*]}"
    exit 1
fi

# Check Rust toolchain
if ! cargo --version | grep -q "cargo"; then
    echo "❌ Rust/Cargo not properly installed"
    exit 1
fi

# Check Node.js version (require 18+)
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version must be 18 or higher (current: $NODE_VERSION)"
    exit 1
fi

# Check Python version (require 3.8+)
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
if ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"; then
    echo "❌ Python version must be 3.8 or higher (current: $PYTHON_VERSION)"
    exit 1
fi

# Check Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "❌ Docker is not running or not accessible"
    exit 1
fi

echo "✅ Development environment validated"