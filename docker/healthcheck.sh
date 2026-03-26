#!/bin/bash
# Cindy AI Orchestrator - Health Check
# Verifies orchestrator is running and responsive

set -e

# ============================================
# Health Check Configuration
# ============================================
STATE_FILE="/app/state/orchestrator.json"
MAX_ERROR_RATE=0.3
MAX_AGE_SECONDS=300

# ============================================
# Check 1: State File Exists
# ============================================
if [ ! -f "$STATE_FILE" ]; then
  echo "[HEALTHCHECK] FAIL: State file not found"
  exit 1
fi

# ============================================
# Check 2: Process is Running
# ============================================
if ! pgrep -f "node.*telegram-bot.js" > /dev/null; then
  echo "[HEALTHCHECK] FAIL: Orchestrator process not running"
  exit 1
fi

# ============================================
# Check 3: Error Rate (Optional)
# ============================================
if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
  MESSAGES=$(jq -r '.stats.messages_processed // 0' "$STATE_FILE")
  ERRORS=$(jq -r '.stats.errors_count // 0' "$STATE_FILE")
  
  if [ "$MESSAGES" -gt 10 ]; then
    ERROR_RATE=$(echo "scale=2; $ERRORS / $MESSAGES" | bc 2>/dev/null || echo "0")
    THRESHOLD=$(echo "$MAX_ERROR_RATE" | bc)
    
    if [ "$(echo "$ERROR_RATE > $THRESHOLD" | bc)" -eq 1 ]; then
      echo "[HEALTHCHECK] WARN: Error rate too high: ${ERROR_RATE} (threshold: ${MAX_ERROR_RATE})"
      # Not fatal, just warning
    fi
  fi
fi

# ============================================
# Check 4: Log Activity (Optional)
# ============================================
LOG_DIR="/app/logs"
if [ -d "$LOG_DIR" ]; then
  LATEST_LOG=$(find "$LOG_DIR" -name "orchestrator-*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
  
  if [ -n "$LATEST_LOG" ] && [ -f "$LATEST_LOG" ]; then
    LOG_AGE=$(( $(date +%s) - $(stat -c %Y "$LATEST_LOG") ))
    
    if [ "$LOG_AGE" -gt "$MAX_AGE_SECONDS" ]; then
      echo "[HEALTHCHECK] WARN: Log file is stale (${LOG_AGE}s old)"
      # Not fatal, just warning
    fi
  fi
fi

# ============================================
# Success
# ============================================
echo "[HEALTHCHECK] OK: All checks passed"
exit 0
