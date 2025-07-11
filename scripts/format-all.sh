#!/bin/bash

# Multi-language code formatter for legal AI toolkit
# Formats Rust, Python, JavaScript/TypeScript files

set -e

echo "🎨 Running code formatters..."

# Format Rust code
if command -v cargo >/dev/null 2>&1; then
    echo "  📦 Formatting Rust files..."
    cargo fmt --all
fi

# Format Python code
if command -v black >/dev/null 2>&1; then
    echo "  🐍 Formatting Python files..."
    black --quiet web-portal/backend/ scripts/ || true
fi

# Format JavaScript/TypeScript
if command -v prettier >/dev/null 2>&1; then
    echo "  ✨ Formatting JS/TS files..."
    prettier --write "src/**/*.{js,ts,svelte}" "web-portal/frontend/src/**/*.{js,ts,svelte}" || true
fi

echo "✅ Code formatting complete"