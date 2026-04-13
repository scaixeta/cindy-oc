#!/bin/bash
# ============================================================
# 99_activate.sh — Ativação e validação final
# ============================================================
# Executar como: bash 99_activate.sh
# Deve ser executado por último

set -e

echo "============================================================"
echo "       CINDY AGENT — Validação Final"
echo "============================================================"

HERMES_DIR="$HOME/.hermes"
AGENTS_DIR="$HOME/CindyAgent/.agents"

echo ""
echo "▶ Verificando Hermes..."
if command -v hermes &> /dev/null; then
    echo "  hermes: OK ($(hermes --version 2>/dev/null || echo 'installed'))"
elif [ -f "$HERMES_DIR/hermes-agent/venv/bin/hermes" ]; then
    echo "  hermes: OK (venv)"
else
    echo "  hermes: FALHA — não encontrado"
fi

echo ""
echo "▶ Verificando Python..."
if command -v python3 &> /dev/null; then
    echo "  python3: $(python3 --version)"
else
    echo "  python3: FALHA"
fi

echo ""
echo "▶ Verificando Redis..."
if redis-cli PING &> /dev/null; then
    echo "  Redis: OK ($(redis-cli INFO server | grep redis_version | cut -d: -f2 | tr -d '[:space:]'))"
else
    echo "  Redis: FALHA — Execute: redis-server --daemonize yes"
fi

echo ""
echo "▶ Verificando OpenCode..."
if command -v opencode &> /dev/null; then
    echo "  opencode: OK"
else
    echo "  opencode: não encontrado (opcional)"
fi

echo ""
echo "▶ Verificando KB canônica..."
for f in SOUL.md USER.md MEMORY.md; do
    if [ -f "$HERMES_DIR/$f" ]; then
        echo "  $f: OK"
    else
        echo "  $f: FALHA"
    fi
done

echo ""
echo "▶ Verificando Scripts ACP..."
if [ -f "$HOME/.agents/scripts/acp_redis.py" ]; then
    echo "  acp_redis.py: OK"
    python3 -c "import sys; sys.path.insert(0,'$HOME/.agents/scripts'); from acp_redis import ACPRedis; print('  ACP import: OK')" 2>/dev/null || echo "  ACP import: FALHA"
else
    echo "  acp_redis.py: FALHA"
fi

echo ""
echo "▶ Verificando Gate de roteamento..."
if [ -f "$HOME/.agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py" ]; then
    RESULT=$(python3 "$HOME/.agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py" "monitorar thingsboard" 2>/dev/null)
    echo "  dual_model_gate.py: OK (teste → $RESULT)"
else
    echo "  dual_model_gate.py: FALHA"
fi

echo ""
echo "▶ Verificando arquivos do projeto..."
if [ -d "$HOME/CindyAgent" ]; then
    echo "  CindyAgent: OK"
    echo "  Docs: $(ls $HOME/CindyAgent/docs/*.md 2>/dev/null | wc -l) arquivos"
else
    echo "  CindyAgent: NÃO ENCONTRADO — clone o repo primeiro"
fi

echo ""
echo "============================================================"
echo "       RESUMO"
echo "============================================================"
echo ""
echo "Para iniciar a Cindy no terminal:"
echo ""
echo "  cd ~/CindyAgent"
echo "  source ~/.hermes/hermes-agent/venv/bin/activate"
echo "  hermes chat"
echo ""
echo "Para ativar com Telegram:"
echo ""
echo "  hermes gateway start"
echo ""
echo "Para testar ACP:"
echo ""
echo "  python3 ~/.agents/scripts/test_acp_multi_agent.py"
echo ""
echo "============================================================"
echo "  Cindy Agent pronta."
echo "============================================================"
