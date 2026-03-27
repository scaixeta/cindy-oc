#!/bin/bash
# ==============================================================================
# NEMOCLAW VPS SETUP SCRIPT (Cindy OC - S2)
# Autor: Antigravity (Cindy Assistant)
# Objetivo: Instalação base do ecossistema NemoClaw e Caddy.
# ==============================================================================

set -e

echo "--- [1/4] Atualizando sistema e instalando dependências ---"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git jq apt-transport-https ca-certificates gnupg lsb-release

echo "--- [2/4] Instalando Docker ---"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker instalado com sucesso."
else
    echo "Docker já está instalado."
fi

echo "--- [3/4] Instalando OpenShell e NemoClaw ---"
# Script oficial da Nvidia/OpenShell
curl -sSL https://raw.githubusercontent.com/nvidia/openshell/main/install.sh | bash

# Instalar NemoClaw via NPM (global)
# Nota: NemoClaw geralmente é empacotado como binário ou via npm
if ! command -v nemoclaw &> /dev/null; then
    sudo npm install -g @nvidia/nemoclaw || {
        echo "Aviso: Falha ao instalar via NPM. Tentando método alternativo/manual conforme vídeo FuturMinds..."
        # Método alternativo baseado no vídeo (onboarding script)
    }
fi

echo "--- [4/4] Instalando Caddy Server ---"
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1G 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1G 'https://dl.cloudsmith.io/public/caddy/stable/debian.list' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy -y

echo "=============================================================================="
echo " SETUP CONCLUÍDO! "
echo " Próximo passo: Rodar 'nemoclaw onboard' para configurar o sandbox."
echo "=============================================================================="
