#!/bin/bash

# Subagent logging script for multi-agent AI coordination
# Tracks Task tool usage and subagent results

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SUBAGENT_LOG="/home/dev/code/test-project/.claude/subagent-activity.log"

# Create log directory
mkdir -p "$(dirname "$SUBAGENT_LOG")"

echo "🤖 Logging subagent activity at $TIMESTAMP"

# Log subagent completion with context
echo "[$TIMESTAMP] SUBAGENT_COMPLETE: PWD=$(pwd)" >> "$SUBAGENT_LOG"

# If Task tool was used, log the context
if [ -n "${TASK_DESCRIPTION:-}" ]; then
    echo "[$TIMESTAMP] TASK_DESC: $TASK_DESCRIPTION" >> "$SUBAGENT_LOG"
fi

# Log any search/research activity patterns
RECENT_SEARCHES=$(grep -o "search\|find\|grep\|rg" "$SUBAGENT_LOG" 2>/dev/null | tail -5 | tr '\n' ' ' || echo "none")
if [ "$RECENT_SEARCHES" != "none" ]; then
    echo "[$TIMESTAMP] SEARCH_PATTERNS: $RECENT_SEARCHES" >> "$SUBAGENT_LOG"
fi

# For multi-agent coordination, track agent specialization
AGENT_ROLE="general"
if echo "$PWD" | grep -q "web-portal"; then
    AGENT_ROLE="web-portal"
elif echo "$PWD" | grep -q "desktop"; then
    AGENT_ROLE="desktop-app"
elif echo "$PWD" | grep -q "ai-agents"; then
    AGENT_ROLE="ai-system"
fi

echo "[$TIMESTAMP] AGENT_ROLE: $AGENT_ROLE" >> "$SUBAGENT_LOG"

# Keep logs manageable (last 200 entries)
tail -n 200 "$SUBAGENT_LOG" > "$SUBAGENT_LOG.tmp" && mv "$SUBAGENT_LOG.tmp" "$SUBAGENT_LOG"

echo "✅ Subagent activity logged"