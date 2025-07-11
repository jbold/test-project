#!/bin/bash

# Session cleanup script for development coordination
# Runs before Claude concludes response - saves state and validates

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_LOG="/home/dev/code/test-project/.claude/session-state.log"
COORDINATION_LOG="/home/dev/code/test-project/.claude/instance-coordination.log"

# Create log directories
mkdir -p "$(dirname "$SESSION_LOG")"

echo "🧹 Running session cleanup at $TIMESTAMP"

# Save current session state
echo "[$TIMESTAMP] SESSION_END: $(pwd)" >> "$SESSION_LOG"

# Check if any critical files were modified
MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "none")
if [ "$MODIFIED_FILES" != "none" ]; then
    echo "[$TIMESTAMP] MODIFIED_FILES: $MODIFIED_FILES" >> "$SESSION_LOG"
fi

# Log current git status for coordination
GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "not_git_repo")
if [ "$GIT_STATUS" != "not_git_repo" ]; then
    echo "[$TIMESTAMP] GIT_STATUS: $GIT_STATUS" >> "$SESSION_LOG"
fi

# Update coordination log for other instances
echo "[$TIMESTAMP] INSTANCE_COMPLETE: $(basename "$PWD")" >> "$COORDINATION_LOG"

# Validate development environment is still clean
if [ -f "./scripts/validate-env.sh" ]; then
    echo "📋 Final environment validation..."
    ./scripts/validate-env.sh >/dev/null 2>&1 || echo "⚠️  Environment validation failed"
fi

# Keep logs manageable
tail -n 500 "$SESSION_LOG" > "$SESSION_LOG.tmp" && mv "$SESSION_LOG.tmp" "$SESSION_LOG"

echo "✅ Session cleanup complete"