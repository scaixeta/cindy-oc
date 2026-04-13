#!/bin/bash
# ============================================================
# 05_install_codex.sh — Codex CLI
# ============================================================
set -e

echo "=== 05: Codex CLI ==="

if command -v codex &>/dev/null; then
    echo "Codex já instalado: $(codex --version 2>/dev/null || echo 'ok')"
else
    echo "Instalando Codex CLI..."
    npm install -g @opencode/codex-cli 2>/dev/null || npm install -g codex-cli 2>/dev/null || true
    
    if command -v codex &>/dev/null; then
        echo "Codex instalado: $(codex --version 2>/dev/null || echo 'ok')"
    else
        echo "AVISO: codex não disponível após instalação"
        echo "Para usar o Codex, você precisa de uma licença ativa da OpenAI"
    fi
fi

echo "=== 05 completo ==="
