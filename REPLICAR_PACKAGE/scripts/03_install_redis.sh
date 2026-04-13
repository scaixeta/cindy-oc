#!/bin/bash
# 03_install_redis.sh — Install and configure Redis on WSL

set -e

echo "=== Redis Installation Script ==="

# Check if redis-server is already installed
if command -v redis-server &> /dev/null; then
    echo "redis-server is already installed: $(redis-server --version)"
else
    echo "redis-server not found. Installing via apt..."
    sudo apt update
    sudo apt install -y redis-server
fi

# Create ~/.local/bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Create Redis init/startup script
INIT_SCRIPT="$HOME/.local/bin/redis-wsl.sh"
echo "Creating Redis init script at $INIT_SCRIPT..."

cat > "$INIT_SCRIPT" << 'EOF'
#!/bin/bash
# redis-wsl.sh — Start Redis server on WSL

# Check if Redis is already running
if redis-cli ping &> /dev/null; then
    echo "Redis is already running."
else
    echo "Starting Redis server..."
    redis-server --daemonize yes
    sleep 1
    if redis-cli ping | grep -q PONG; then
        echo "Redis started successfully."
    else
        echo "Failed to start Redis."
        exit 1
    fi
fi
EOF

chmod +x "$INIT_SCRIPT"

# Add source line to .bashrc if not already present
BASHRC="$HOME/.bashrc"
SOURCE_LINE="source ~/.local/bin/redis-wsl.sh"

if ! grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
    echo "Adding source line to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# Redis auto-start" >> "$BASHRC"
    echo "$SOURCE_LINE" >> "$BASHRC"
else
    echo "Source line already present in $BASHRC."
fi

# Start Redis
echo "Starting Redis server..."
if redis-cli ping &> /dev/null; then
    echo "Redis is already running."
else
    redis-server --daemonize yes
    sleep 1
fi

# Test Redis connection
echo "Testing Redis connection..."
if redis-cli PING | grep -q PONG; then
    echo "Redis is running and responding to PING."
else
    echo "ERROR: Redis is not responding."
    exit 1
fi

echo "=== Redis installation complete ==="
