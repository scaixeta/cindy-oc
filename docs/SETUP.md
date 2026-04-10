# SETUP.md — Configuração do Ambiente

## Visão Geral

Cindy Agent utiliza o framework Hermes como motor de IA e Telegram como canal de comunicação primário.

## Pré-requisitos

| Componente | Requisito |
|------------|-----------|
| Sistema Operacional | Windows com WSL2 (Linux) |
| Hermes CLI | Versão mais recente |
| Telegram Bot | Bot token válido |
| WSL | Ubuntu/Debian |

## Instalação do Hermes

### Via npm

```powershell
npm install -g @hermes/ai
```

### Verificação

```powershell
hermes --version
```

## Configuração do Telegram

### 1. Criar um Bot Telegram

1. Abra o Telegram e converse com **@BotFather**
2. Envie `/newbot`
3. Siga as instruções e copie o **bot token**

### 2. Configurar credenciais

O Hermes utiliza variáveis de ambiente para credenciais:

```powershell
# No arquivo .env ou via variáveis de ambiente
TELEGRAM_BOT_TOKEN=seu_token_aqui
```

### 3. Conectar ao Hermes

```powershell
hermes connect telegram --token $env:TELEGRAM_BOT_TOKEN
```

## Workspace Cindy Agent

O workspace está em `C:\cindyagent` (acessível via WSL em `/mnt/c/cindyagent`).

### Estrutura de configuração

```
cindyagent/
├── .cline/             # Configurações do runtime Cline
├── .clinerules/        # Regras e workflows DOC2.5
├── .agents/            # Skills e agentes
└── rules/              # Regras operacionais
```

## Validação

Após configurar, valide com:

```powershell
hermes status
```

## Pendente de Validação

| Item | Status |
|------|--------|
| Credenciais Telegram confirmadas | Pendente |
| Endpoint do bot respondendo | Pendente |

## Referência

Consulte [OPERATIONS.md](OPERATIONS.md) para comandos operacionais.
