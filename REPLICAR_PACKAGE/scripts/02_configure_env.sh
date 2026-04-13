#!/bin/bash
# 02_configure_env.sh — Configurar variáveis de ambiente do Hermes Agent

set -e

HERMES_DIR="$HOME/.hermes"
ENV_FILE="$HERMES_DIR/.env"
CONFIG_FILE="$HERMES_DIR/config.yaml"

echo "========================================="
echo " Hermes Agent — Configuração de Ambiente"
echo "========================================="
echo

# Criar diretório .hermes se não existir
mkdir -p "$HERMES_DIR"

# Solicitar MINIMAX_API_KEY
echo -n "MINIMAX_API_KEY: "
read -r MINIMAX_API_KEY
if [ -z "$MINIMAX_API_KEY" ]; then
    echo "ERRO: MINIMAX_API_KEY é obrigatória."
    exit 1
fi

# Solicitar TELEGRAM_BOT_TOKEN
echo -n "TELEGRAM_BOT_TOKEN: "
read -r TELEGRAM_BOT_TOKEN
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "ERRO: TELEGRAM_BOT_TOKEN é obrigatório."
    exit 1
fi

# Solicitar GITHUB_TOKEN (opcional)
echo -n "GITHUB_TOKEN [opcional, Enter para skip]: "
read -r GITHUB_TOKEN

# Criar .env
cat > "$ENV_FILE" << EOF
MINIMAX_API_KEY=$MINIMAX_API_KEY
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
EOF

if [ -n "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN=$GITHUB_TOKEN" >> "$ENV_FILE"
fi

echo "✓ $ENV_FILE criado."

# Criar config.yaml
cat > "$CONFIG_FILE" << EOF
model: MiniMax-M2.7
provider: minimax

toolsets:
  - telegram

telegram:
  enabled: true

logging:
  level: info
EOF

echo "✓ $CONFIG_FILE criado."

# Criar diretórios adicionais
mkdir -p "$HERMES_DIR/logs"
mkdir -p "$HERMES_DIR/cache"

echo
echo "========================================="
echo " Configuração concluída!"
echo "========================================="
echo " Arquivos criados:"
echo "   $ENV_FILE"
echo "   $CONFIG_FILE"
echo "   $HERMES_DIR/logs/"
echo "   $HERMES_DIR/cache/"
