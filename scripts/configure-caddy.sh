#!/bin/bash
# ==============================================================================
# CADDY CONFIGURATION SCRIPT (Cindy OC - S2)
# ==============================================================================

# Defina seu subdomínio abaixo
# Ex: SUBDOMAIN="cindy.meudominio.com"

if [ -z "$1" ]; then
    echo "Erro: Forneça o subdomínio como argumento. Ex: ./configure-caddy.sh cindy.exemplo.com"
    exit 1
fi

SUBDOMAIN=$1
PORT=18789

echo "--- Configurando Caddyfile para $SUBDOMAIN ---"

sudo bash -c "cat <<EOF > /etc/caddy/Caddyfile
$SUBDOMAIN {
    reverse_proxy localhost:$PORT
}
EOF"

echo "--- Validando e reiniciando o Caddy ---"
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl restart caddy

echo "--- Caddy configurado com sucesso! Verifique o log: sudo journalctl -u caddy ---"
