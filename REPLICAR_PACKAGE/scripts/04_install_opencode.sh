#!/bin/bash
# ============================================================
# 04_install_opencode.sh — OpenCode CLI Installer
# ============================================================
# Instala OpenCode CLI (opencode) globalmente via npm
# Cria run_opencode.bat para Windows
# Documenta configuracao da MINIMAX_API_KEY
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BAT_TARGET="C:/cindyagent/run_opencode.bat"

echo "=========================================="
echo " OpenCode CLI Installer"
echo "=========================================="
echo ""

# -----------------------------
# 1. Verificar se opencode existe
# -----------------------------
echo "[1/4] Verificando installacao do opencode..."

if command -v opencode &> /dev/null; then
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "desconhecida")
    echo "      opencode ja instalado: v$OPENCODE_VERSION"
    ALREADY_INSTALLED=true
else
    echo "      opencode NAO encontrado."
    ALREADY_INSTALLED=false
fi

echo ""

# -----------------------------
# 2. Instruir instalacao manual se necessario
# -----------------------------
echo "[2/4] Instalacao..."

if [ "$ALREADY_INSTALLED" = false ]; then
    echo "      Instale manualmente com:"
    echo ""
    echo "      npm install -g opencode-cli"
    echo ""
    echo "      Apos instalar, execute este script novamente."
    echo ""
    read -p "      Pressione ENTER para continuar (ou Ctrl+C para sair)..."
else
    echo "      Instalacao ja existente. Pulando etapa."
fi

echo ""

# -----------------------------
# 3. Criar run_opencode.bat
# -----------------------------
echo "[3/4] Criando run_opencode.bat em C:/cindyagent/..."

# Garantir que o diretorio existe
mkdir -p "C:/cindyagent"

cat > "$BAT_TARGET" << 'EOF'
@echo off
rem ============================================
rem run_opencode.bat — Atalho para OpenCode CLI
rem ============================================
rem Requer: opencode-cli instalado globalmente
rem   npm install -g opencode-cli
rem
rem Requer variavel de ambiente MINIMAX_API_KEY
rem   set MINIMAX_API_KEY=sua_chave_aqui
rem   (ou configure no Windows: Configuracao > Variaveis de Ambiente)
rem ============================================

echo Opening OpenCode CLI...
opencode %*
EOF

echo "      Arquivo criado: $BAT_TARGET"
echo ""

# -----------------------------
# 4. Documentar MINIMAX_API_KEY
# -----------------------------
echo "[4/4] Variavel de ambiente MINIMAX_API_KEY"
echo ""
echo "      O OpenCode requer a chave da API da Minimax."
echo ""
echo "      OPÇÃO 1 — Via terminal (sessao atual):"
echo "        set MINIMAX_API_KEY=sua_chave_aqui"
echo ""
echo "      OPÇÃO 2 — Via run_opencode.bat (permanente):"
echo "        Edite C:/cindyagent/run_opencode.bat e adicione:"
echo "        set MINIMAX_API_KEY=sua_chave_aqui"
echo ""
echo "      OPÇÃO 3 — Variavel de ambiente Windows:"
echo "        Configuracao > Variaveis de Ambiente > Nova..."
echo "        Nome: MINIMAX_API_KEY"
echo "        Valor: sua_chave_aqui"
echo ""
echo "=========================================="
echo " Concluido!"
echo "=========================================="
echo ""
echo " Proximo passo:"
echo "   1. Instale opencode: npm install -g opencode-cli"
echo "   2. Configure MINIMAX_API_KEY"
echo "   3. Teste: opencode --version"
echo ""