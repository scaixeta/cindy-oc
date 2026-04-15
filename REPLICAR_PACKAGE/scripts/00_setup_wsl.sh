#!/bin/bash
# ============================================================
# 00_setup_wsl.sh — Pré-requisitos para WSL2 / Ubuntu
# ============================================================

set -euo pipefail

echo "=============================================="
echo "  00_setup_wsl.sh — Pré-requisitos WSL2"
echo "=============================================="
echo ""

# ── 1. Update apt ────────────────────────────────────────
echo "[1/6] Atualizando apt..."
sudo apt update -qq
sudo apt upgrade -y -qq
echo "      ✓ apt atualizado"
echo ""

# ── 2. Instalar utilitários base ──────────────────────────
echo "[2/6] Instalando utilitários base..."
sudo apt install -y \
    git curl wget build-essential software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release \
    htop tree jq unzip zip

echo "      ✓ Utilitários instalados"
echo ""

# ── 3. Garantir Python 3.11+ ──────────────────────────────
echo "[3/6] Verificando / instalando Python 3.11+..."

PYTHON_CMD=""
for cmd in python3.11 python3.12 python3.13 python3; do
    if command -v "$cmd" &>/dev/null; then
        ver=$("$cmd" -c 'import sys; print(sys.version_info.major * 100 + sys.version_info.minor)')
        if [ "$ver" -ge 311 ]; then
            PYTHON_CMD="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "      Python 3.11+ não encontrado. Instalando Python 3.11..."
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt install -y python3.11 python3.11-venv python3.11-dev
    PYTHON_CMD="python3.11"
fi

PYTHON_VERSION=$("$PYTHON_CMD" --version)
echo "      ✓ Python encontrado: $PYTHON_VERSION"

#Garantir pip
if ! "$PYTHON_CMD" -m pip --version &>/dev/null; then
    echo "      Instalando pip para $PYTHON_CMD..."
    sudo apt install -y python3-pip
    "$PYTHON_CMD" -m ensurepip --upgrade 2>/dev/null || true
fi
echo ""

# ── 4. Node.js 22.x via NodeSource ───────────────────────
echo "[4/6] Instalando Node.js 22.x via NodeSource..."

# Limpar instalação anterior se existir
sudo rm -f /etc/apt/sources.list.d/nodejs.list
sudo rm -f /usr/share/keyrings/nodejs-archive-keyring.gpg

# Adicionar repo NodeSource para Node 22
if curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -; then
    sudo apt install -y nodejs
else
    echo "      Falha ao configurar NodeSource para Node 22.x"
    exit 1
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo "      ✓ Node.js $NODE_VERSION | npm $NPM_VERSION"
echo ""

# ── 5. redis-tools ────────────────────────────────────────
echo "[5/6] Instalando redis-tools..."
sudo apt install -y redis-tools
echo "      ✓ redis-tools instalado"
echo ""

# ── 6. Verificação final ──────────────────────────────────
echo "[6/6] Verificando versões instaladas..."
echo ""
echo "  ┌─────────────────────────────────────────┐"
echo "  │  Ferramenta           Versão           │"
echo "  ├─────────────────────────────────────────┤"
printf "  │  %-18s %-17s │\n" "bash" "$(bash --version | head -1 | cut -d' ' -f4)"
printf "  │  %-18s %-17s │\n" "git" "$(git --version | cut -d' ' -f3)"
printf "  │  %-18s %-17s │\n" "curl" "$(curl --version | head -1 | cut -d' ' -f2)"
printf "  │  %-18s %-17s │\n" "wget" "$(wget --version | head -1 | cut -d' ' -f3)"
printf "  │  %-18s %-17s │\n" "python" "$("$PYTHON_CMD" --version 2>&1)"
printf "  │  %-18s %-17s │\n" "node" "$NODE_VERSION"
printf "  │  %-18s %-17s │\n" "npm" "$NPM_VERSION"
printf "  │  %-18s %-17s │\n" "jq" "$(jq --version 2>&1)"
printf "  │  %-18s %-17s │\n" "redis-cli" "$(redis-cli --version 2>&1)"
printf "  │  %-18s %-17s │\n" "htop" "$(htop --version 2>&1 | head -1)"
printf "  │  %-18s %-17s │\n" "tree" "$(tree --version 2>&1 | head -1)"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "=============================================="
echo "  ✓ Setup WSL2 concluído com sucesso!"
echo "=============================================="
