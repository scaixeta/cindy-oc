# ==============================================================================
# NEMOCLAW RAILWAY DOCKERFILE (Cindy OC - S2 - Lockdown Protocol)
# ==============================================================================
FROM ubuntu:22.04

# Evitar prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências base
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    python3 \
    python3-pip \
    sudo \
    expect \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Criar diretórios de trabalho e dados (Volume Mount Point)
WORKDIR /openclaw
RUN mkdir -p /openclaw/data /openclaw/skills /openclaw/logs

# O instalador oficial do NemoClaw agora rodará apenas no runtime (entrypoint.sh) via `expect` script.
# Preparo para injeção de Automatos.

# Copiar arquivos do projeto para o container
# Nota: No Railway, o build context é a raiz do repo
COPY . /openclaw/build_context

# Configurar variáveis de ambiente padrão
ENV PORT=18789
ENV OPENCLAW_PORT=18789
ENV OPENCLAW_SANDBOX_NAME=nemoclaw
ENV NEMOCLAW_MODE=standalone

# Expor a porta do gateway
EXPOSE ${PORT}

# Copiar e dar permissão ao entrypoint e automatizador
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY install_nemoclaw.exp /usr/local/bin/install_nemoclaw.exp
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/install_nemoclaw.exp

# Protocolo de Segurança: Não rodar como root se possível (opcional dependendo do sandbox)
# USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
