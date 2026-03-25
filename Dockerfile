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

# Copy entrypoint script
COPY openclaw-entrypoint.sh /home/node/openclaw-entrypoint.sh
RUN chmod +x /home/node/openclaw-entrypoint.sh

# Set working directory
WORKDIR /home/node

# Set environment
ENV OPENCLAW_CONFIG_PATH=/home/node/.openclaw/openclaw.json

# Run entrypoint script
ENTRYPOINT ["/home/node/openclaw-entrypoint.sh"]
