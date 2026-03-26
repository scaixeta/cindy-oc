#!/bin/bash
# Cindy AI Orchestrator - Entrypoint
# DOC2.5 compliant initialization with skills discovery

set -e

# ============================================
# Environment & Defaults
# ============================================
export NODE_ENV="${NODE_ENV:-production}"
export ORCHESTRATOR_MODE="${ORCHESTRATOR_MODE:-docker}"
export DOC25_GOVERNANCE="${DOC25_GOVERNANCE:-enabled}"
export SKILLS_DISCOVERY="${SKILLS_DISCOVERY:-auto}"
export LOG_LEVEL="${LOG_LEVEL:-info}"

# ============================================
# Banner
# ============================================
echo "========================================"
echo "Cindy AI Orchestrator - Docker Runtime"
echo "Mode: ${ORCHESTRATOR_MODE}"
echo "Governance: ${DOC25_GOVERNANCE}"
echo "Skills Discovery: ${SKILLS_DISCOVERY}"
echo "Startup: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "========================================"

# ============================================
# Pre-flight Checks
# ============================================
echo "[PREFLIGHT] Running health checks..."

# Check required directories
for dir in /app/logs /app/state /app/cache; do
  if [ ! -d "$dir" ]; then
    echo "[ERROR] Required directory not found: $dir"
    exit 1
  fi
done

# Check required files
if [ ! -f "/app/package.json" ]; then
  echo "[ERROR] package.json not found"
  exit 1
fi

if [ ! -f "/app/telegram-bot.js" ]; then
  echo "[ERROR] telegram-bot.js not found"
  exit 1
fi

# Check environment variables
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "[ERROR] TELEGRAM_BOT_TOKEN not set"
  exit 1
fi

echo "[PREFLIGHT] ✅ All checks passed"

# ============================================
# Skills Discovery
# ============================================
if [ "$SKILLS_DISCOVERY" = "auto" ]; then
  echo "[DISCOVERY] Starting skills discovery..."
  
  if [ -f "/app/skills-index.json" ]; then
    SKILLS_COUNT=$(jq -r '.skills | length' /app/skills-index.json 2>/dev/null || echo "0")
    echo "[DISCOVERY] Found ${SKILLS_COUNT} skills"
  fi
  
  if [ -f "/app/kb-index.json" ]; then
    KB_COUNT=$(jq -r '.kb | length' /app/kb-index.json 2>/dev/null || echo "0")
    echo "[DISCOVERY] Found ${KB_COUNT} KB entries"
  fi
  
  if [ -f "/app/docs-index.json" ]; then
    DOCS_COUNT=$(jq -r '.docs | length' /app/docs-index.json 2>/dev/null || echo "0")
    echo "[DISCOVERY] Found ${DOCS_COUNT} documentation files"
  fi
  
  echo "[DISCOVERY] ✅ Discovery complete"
fi

# ============================================
# DOC2.5 Governance Check
# ============================================
if [ "$DOC25_GOVERNANCE" = "enabled" ]; then
  echo "[GOVERNANCE] DOC2.5 governance enabled"
  
  # Check for required governance files
  if [ -f "/app/Cindy_Contract.md" ]; then
    echo "[GOVERNANCE] ✅ Cindy_Contract.md found"
  else
    echo "[GOVERNANCE] ⚠️  Cindy_Contract.md not found"
  fi
  
  if [ -f "/app/rules/WORKSPACE_RULES.md" ]; then
    echo "[GOVERNANCE] ✅ WORKSPACE_RULES.md found"
  else
    echo "[GOVERNANCE] ⚠️  WORKSPACE_RULES.md not found"
  fi
fi

# ============================================
# n8n Connectivity Check
# ============================================
echo "[N8N] Checking connectivity to ${N8N_URL}..."

MAX_WAIT=60
COUNTER=0
N8N_READY=false

while [ $COUNTER -lt $MAX_WAIT ]; do
  if curl -sf "${N8N_URL}/healthz" > /dev/null 2>&1; then
    echo "[N8N] ✅ n8n is ready"
    N8N_READY=true
    break
  fi
  echo "[N8N] Waiting for n8n... ($COUNTER/$MAX_WAIT)"
  sleep 2
  COUNTER=$((COUNTER + 2))
done

if [ "$N8N_READY" = false ]; then
  echo "[N8N] ⚠️  n8n not available after ${MAX_WAIT}s, proceeding anyway"
fi

# ============================================
# State Initialization
# ============================================
echo "[STATE] Initializing runtime state..."

# Create state file if not exists
STATE_FILE="/app/state/orchestrator.json"
if [ ! -f "$STATE_FILE" ]; then
  cat > "$STATE_FILE" <<EOF
{
  "initialized_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "mode": "${ORCHESTRATOR_MODE}",
  "governance": "${DOC25_GOVERNANCE}",
  "version": "1.0.0-docker",
  "stats": {
    "messages_processed": 0,
    "errors_count": 0,
    "uptime_seconds": 0
  }
}
EOF
  echo "[STATE] ✅ State file created"
else
  echo "[STATE] ✅ State file exists"
fi

# ============================================
# Logging Configuration
# ============================================
echo "[LOGGING] Configuring structured logging..."

LOG_FILE="/app/logs/orchestrator-$(date +%Y%m%d).log"
touch "$LOG_FILE"

echo "[LOGGING] ✅ Log file: $LOG_FILE"

# ============================================
# Launch Application
# ============================================
echo "========================================"
echo "Starting Cindy AI Orchestrator..."
echo "========================================"

# Execute the command passed to the entrypoint
exec "$@" 2>&1 | tee -a "$LOG_FILE"
