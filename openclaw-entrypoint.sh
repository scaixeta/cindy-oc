#!/bin/bash
set -e

# Create config directory
mkdir -p /home/node/.openclaw

# Create openclaw.json config file with pre-authorized user
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
      "authorizedUsers": ["8687754084"]
    }
  }
}
CONFIGEOF

# Export PATH and config path
export PATH="$(npm root -g)/.bin:$PATH"
export OPENCLAW_CONFIG_PATH=/home/node/.openclaw/openclaw.json

# Run gateway
exec openclaw gateway --allow-unconfigured --bind lan --port 18789 --token "$OPENCLAW_GATEWAY_TOKEN"
