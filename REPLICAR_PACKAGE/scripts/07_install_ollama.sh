#!/bin/bash
# ============================================================
# 07_install_ollama.sh — Ollama + GLM-5.1
# ============================================================
set -e

echo "=== 07: Ollama ==="

if command -v ollama &>/dev/null; then
    echo "Ollama já instalado: $(ollama --version)"
else
    echo "Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

echo "Baixando GLM-5.1:cloud..."
ollama pull glm-5.1:cloud 2>/dev/null || echo "Nota: glm-5.1:cloud requer acesso à API MiniMax"

echo "=== 07 completo ==="
