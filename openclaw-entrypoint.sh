#!/bin/bash
set -e

# Create config directory
mkdir -p /home/node/.openclaw

# Create openclaw.json config file
cat > /home/node/.openclaw/openclaw.json << 'CONFIGEOF'
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "minimax": {
        "baseUrl": "https://api.minimax.io/anthropic",
        "api": "anthropic-messages",
        "apiKey": "${MINIMAX_API_KEY}",
        "models": [
          {
            "id": "MiniMax-M2.5",
            "name": "MiniMax-M2.5"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "minimax/MiniMax-M2.5"
      }
    }
  },
  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}"
    }
  }
}
CONFIGEOF

# Export PATH and config path
export PATH="$(npm root -g)/.bin:$PATH"
export OPENCLAW_CONFIG_PATH=/home/node/.openclaw/openclaw.json

# If PAIRING_CODE is set, try to approve it after gateway starts
if [ -n "$PAIRING_CODE" ]; then
  # Start gateway in background
  openclaw gateway --allow-unconfigured --bind lan --port 18789 --token "$OPENCLAW_GATEWAY_TOKEN" &
  GATEWAY_PID=$!
  
  # Wait for gateway to be ready
  sleep 10
  
  # Try to approve the pairing (may fail if code expired)
  echo "Attempting to approve pairing code: $PAIRING_CODE"
  if openclaw pairing approve telegram "$PAIRING_CODE" 2>&1; then
    echo "Pairing code approved successfully!"
  else
    echo "Pairing code may have expired or is invalid. Gateway is still running."
    echo "To pair Telegram, send /pair to the bot and approve the new code."
  fi
  
  # Wait for gateway process
  wait $GATEWAY_PID
else
  # Run gateway directly
  exec openclaw gateway --allow-unconfigured --bind lan --port 18789 --token "$OPENCLAW_GATEWAY_TOKEN"
fi
