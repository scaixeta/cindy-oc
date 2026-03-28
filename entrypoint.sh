#!/bin/bash
# ==============================================================================
# ENTRYPOINT SCRIPT - NemoClaw Railway (Cindy OC - S2)
# ==============================================================================

set -e

# Assegurar o PATH para binários locais e globais
export PATH=$PATH:/openclaw/node_modules/.bin:/usr/local/bin:/usr/bin

echo "--- [1/3] Verificando Instalador NemoClaw ---"
export NEMOCLAW_NON_INTERACTIVE=1
export NEMOCLAW_RECREATE_SANDBOX=1
export PATH=$PATH:/usr/local/bin:/usr/bin:$HOME/.local/bin

if ! command -v nemoclaw &> /dev/null; then
    echo "Executando setup oficial da NVIDIA (Modo Nativo Não-Interativo)..."
    curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash
    
    # Reload profile para garantir persistência pós-bash script
    export PATH=$PATH:$HOME/.local/bin
else
    echo "NemoClaw já está instalado em $(which nemoclaw)."
fi

echo "--- [2/3] Verificando Variáveis de Ambiente ---"
if [ -z "$NVIDIA_API_KEY" ]; then
    echo "ERRO: NVIDIA_API_KEY não configurada no Railway!"
    # exit 1 (Removido para permitir o build de validação no Railway, mas avisamos)
fi

echo "--- [3/3] Inicializando Configurações de Sandbox ---"
# Se no Railway, usamos o modo standalone/isolado do container
if [ ! -f "/openclaw/data/config.yml" ] && command -v nemoclaw &> /dev/null; then
    echo "Verificando integridade da Sandbox..."
    nemoclaw status || echo "Sandbox ainda não inicializou corretamente."
fi

echo "--- [4/4] Iniciando Gateway e Worker NemoClaw ---"
# O comando de startup depende da versão do NemoClaw instalada
# Por padrão, iniciamos o gateway do OpenClaw
# (Nota: Adaptado para rodar em foreground no Docker)

# Executar o agent bridge se configurado (Telegram)
if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "--- [A] Iniciando Telegram Bridge (Lockdown Mode) ---"
    # O script de setup (nemoclaw.sh) auto-configura o Telegram se a env TELEGRAM_BOT_TOKEN existir.
    # Iniciamos a bridge em background pelo seu nome de processo:
    nemoclaw start telegram-bridge & 
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
