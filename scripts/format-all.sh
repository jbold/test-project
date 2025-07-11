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
    if ! black --quiet web-portal/backend/ scripts/; then
        echo "  ⚠️  Warning: Python formatting failed"
    fi
fi

# Format JavaScript/TypeScript
if command -v prettier >/dev/null 2>&1; then
    echo "  ✨ Formatting JS/TS files..."
    if ! prettier --write "src/**/*.{js,ts,svelte}" "web-portal/frontend/src/**/*.{js,ts,svelte}"; then
        echo "  ⚠️  Warning: JS/TS formatting failed"
    fi
fi

echo "✅ Code formatting complete"