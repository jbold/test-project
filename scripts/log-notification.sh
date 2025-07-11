#!/bin/bash

# Notification logging script for multi-instance coordination
# Tracks notifications across parallel development instances

set -e

LOG_FILE="$HOME/.claude/notifications.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Log notification with timestamp and context
echo "[$TIMESTAMP] NOTIFICATION: $*" >> "$LOG_FILE"

# For coordination between instances, also log to project-specific file
PROJECT_LOG="/home/dev/code/test-project/.claude/instance-coordination.log"
mkdir -p "$(dirname "$PROJECT_LOG")"
echo "[$TIMESTAMP] Instance $(basename "$PWD"): $*" >> "$PROJECT_LOG"

# Keep logs manageable (last 1000 lines)
tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
tail -n 1000 "$PROJECT_LOG" > "$PROJECT_LOG.tmp" && mv "$PROJECT_LOG.tmp" "$PROJECT_LOG"