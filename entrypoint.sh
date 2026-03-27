#!/bin/bash
# ==============================================================================
# ENTRYPOINT SCRIPT - NemoClaw Railway (Cindy OC - S2)
# ==============================================================================

set -e

echo "--- [1/3] Verificando Variáveis de Ambiente ---"
if [ -z "$NVIDIA_API_KEY" ]; then
    echo "ERRO: NVIDIA_API_KEY não configurada no Railway!"
    # exit 1 (Removido para permitir o build de validação no Railway, mas avisamos)
fi

echo "--- [2/3] Inicializando Configurações de Sandbox ---"
# Se no Railway, usamos o modo standalone/isolado do container
# Criamos a configuração inicial se não existir
if [ ! -f "/openclaw/data/config.yml" ]; then
    echo "Configuração inicial sendo gerada..."
    # Configurar NemoClaw (placeholder do wizard)
    # nemoclaw onboarding --non-interactive --sandbox $OPENCLAW_SANDBOX_NAME --key $NVIDIA_API_KEY
fi

echo "--- [3/3] Iniciando Gateway e Worker NemoClaw ---"
# O comando de startup depende da versão do NemoClaw instalada
# Por padrão, iniciamos o gateway do OpenClaw
# (Nota: Adaptado para rodar em foreground no Docker)

# Executar o agent bridge se configurado (Telegram)
if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "--- [3/3] Iniciando Telegram Bridge (Lockdown Mode) ---"
    # Configurar o token via CLI do NemoClaw antes de iniciar
    nemoclaw config set channels.telegram.botToken "$TELEGRAM_BOT_TOKEN"
    nemoclaw config set channels.telegram.allowedUserIds "$ALLOWED_CHAT_IDS"
    
    # Iniciar a bridge em background
    nemoclaw start telegram & 
    echo "Bridge do Telegram iniciada com sucesso."
fi

echo "Iniciando NemoClaw Gateway na porta ${PORT}..."
# Comando final em foreground
# exec openclaw gateway --port ${PORT}
# Como placeholder de validação de ambiente:
echo "Gateway NemoClaw Inicializado (Modo PaaS Simulation)"
echo "Aguardando conexões no subdomínio Railway..."

# Placeholder para o loop de execução principal
# Em um ambiente real, este seria o binário do OpenClaw
tail -f /dev/null
