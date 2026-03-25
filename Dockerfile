# OpenClaw Custom Dockerfile - Node 22 required
FROM node:22-bullseye

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install openclaw globally
RUN npm install -g openclaw@latest

# Add npm global bin to PATH
ENV PATH="$(npm root -g)/.bin:$PATH"

# Create config directory
RUN mkdir -p /home/node/.openclaw

# Set working directory
WORKDIR /home/node

# Set environment
ENV OPENCLAW_CONFIG_PATH=/home/node/.openclaw/openclaw.json

# Run gateway with inline config creation and lan binding
# Using absolute path to openclaw binary
CMD ["/bin/sh", "-lc", "mkdir -p /home/node/.openclaw && cat > /home/node/.openclaw/openclaw.json <<'EOF'\n{\n  \"gateway\": {\n    \"mode\": \"local\",\n    \"bind\": \"lan\",\n    \"port\": 18789,\n    \"auth\": {\n      \"mode\": \"token\",\n      \"token\": \"${OPENCLAW_GATEWAY_TOKEN}\"\n    }\n  },\n  \"models\": {\n    \"mode\": \"merge\",\n    \"providers\": {\n      \"minimax\": {\n        \"baseUrl\": \"https://api.minimax.io/anthropic\",\n        \"api\": \"anthropic-messages\",\n        \"apiKey\": \"${MINIMAX_API_KEY}\"\n      }\n    }\n  },\n  \"agents\": {\n    \"defaults\": {\n      \"model\": {\n        \"primary\": \"minimax/MiniMax-M2.5\"\n      }\n    }\n  }\n}\nEOF\nexport PATH=\"$(npm root -g)/.bin:$PATH\"\nexport OPENCLAW_CONFIG_PATH=/home/node/.openclaw/openclaw.json\nexec $(npm root -g)/bin/openclaw gateway --allow-unconfigured --bind lan --port 18789 --token \"$OPENCLAW_GATEWAY_TOKEN\""]
