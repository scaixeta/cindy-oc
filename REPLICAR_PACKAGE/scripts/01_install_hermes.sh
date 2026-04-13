#!/bin/bash
set -e

echo "=== Hermes Agent Installation Script ==="

# 1. Criar ~/.hermes/ e subdirs
echo "[1/5] Creating ~/.hermes/ directory structure..."
mkdir -p ~/.hermes/{logs,sessions,cron,skills,memories}
echo "    Done."

# 2. Clonar ou pull do repositório
echo "[2/5] Cloning/Updating hermes-agent repository..."
if [ -d "$HOME/.hermes/hermes-agent/.git" ]; then
    echo "    Repository exists, pulling latest changes..."
    cd ~/.hermes/hermes-agent
    git pull
else
    echo "    Cloning repository to ~/.hermes/hermes-agent..."
    git clone https://github.com/scaixeta/hermes-agent.git ~/.hermes/hermes-agent
fi
echo "    Done."

# 3. Criar venv com python3.11
echo "[3/5] Creating Python 3.11 virtual environment..."
cd ~/.hermes/hermes-agent
python3.11 -m venv venv
echo "    Done."

# 4. Instalar dependências com uv sync --all-extras
echo "[4/5] Installing dependencies with uv sync --all-extras..."
source venv/bin/activate
uv sync --all-extras
echo "    Done."

# 5. Linkar hermes para PATH
echo "[5/5] Linking hermes to PATH..."
ln -sf ~/.hermes/hermes-agent/venv/bin/hermes ~/.local/bin/hermes 2>/dev/null || \
ln -sf ~/.hermes/hermes-agent/venv/bin/hermes /usr/local/bin/hermes 2>/dev/null || \
echo "    Warning: Could not link to ~/.local/bin or /usr/local/bin"
echo "    You may need to add ~/.local/bin to your PATH"
echo "    Done."

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next step: Run 'hermes setup' to complete configuration"
echo ""
