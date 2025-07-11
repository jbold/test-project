#!/bin/bash

# Context preservation script for conversation compaction
# Saves critical architectural decisions and development state

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
CONTEXT_DIR="/home/dev/code/test-project/.claude/preserved-context"
CONTEXT_FILE="$CONTEXT_DIR/context-$(date +%Y%m%d-%H%M%S).md"

# Create context directory
mkdir -p "$CONTEXT_DIR"

echo "💾 Preserving context before compaction at $TIMESTAMP"

cat > "$CONTEXT_FILE" << EOF
# Preserved Context - $TIMESTAMP

## Current Development State
- Working Directory: $(pwd)
- Git Branch: $(git branch --show-current 2>/dev/null || echo "unknown")
- Git Status: $(git status --porcelain 2>/dev/null | wc -l || echo "0") files modified

## Recent Architecture Decisions
EOF

# Preserve recent commit messages (architectural decisions)
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "## Recent Commits" >> "$CONTEXT_FILE"
    git log --oneline -5 >> "$CONTEXT_FILE" 2>/dev/null || echo "No recent commits" >> "$CONTEXT_FILE"
fi

# Preserve TODO items and technical debt
echo "" >> "$CONTEXT_FILE"
echo "## Technical Debt & TODOs" >> "$CONTEXT_FILE"
rg -n "TODO|FIXME|XXX|HACK" --type rust --type python --type typescript . >> "$CONTEXT_FILE" 2>/dev/null || echo "No technical debt markers found" >> "$CONTEXT_FILE"

# Preserve API contracts and interfaces
echo "" >> "$CONTEXT_FILE"
echo "## API Contracts" >> "$CONTEXT_FILE"
find . -name "*.rs" -o -name "*.py" -o -name "*.ts" | xargs rg -n "pub fn|def |interface |export " | head -20 >> "$CONTEXT_FILE" 2>/dev/null || echo "No API contracts found" >> "$CONTEXT_FILE"

# Preserve configuration changes
echo "" >> "$CONTEXT_FILE"
echo "## Configuration State" >> "$CONTEXT_FILE"
echo "- Tauri Config: $(ls -la tauri.conf.json 2>/dev/null || echo "not found")" >> "$CONTEXT_FILE"
echo "- Package.json: $(ls -la package.json 2>/dev/null || echo "not found")" >> "$CONTEXT_FILE"
echo "- Cargo.toml: $(ls -la Cargo.toml 2>/dev/null || echo "not found")" >> "$CONTEXT_FILE"

# Preserve multi-instance coordination state
echo "" >> "$CONTEXT_FILE"
echo "## Multi-Instance Coordination" >> "$CONTEXT_FILE"
if [ -f "$CONTEXT_DIR/../instance-coordination.log" ]; then
    echo "Recent coordination events:" >> "$CONTEXT_FILE"
    tail -10 "$CONTEXT_DIR/../instance-coordination.log" >> "$CONTEXT_FILE" 2>/dev/null || echo "No coordination log" >> "$CONTEXT_FILE"
fi

# Clean up old context files (keep last 10)
find "$CONTEXT_DIR" -name "context-*.md" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true

echo "✅ Context preserved to $CONTEXT_FILE"
echo "📊 Total preserved contexts: $(ls -1 "$CONTEXT_DIR"/context-*.md 2>/dev/null | wc -l)"