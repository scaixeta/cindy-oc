# Cindy AI Orchestrator - Docker Deployment Guide

## 1. Visão Geral

Este guia documenta como fazer deploy da **Cindy AI Orchestrator** usando Docker, portando o conhecimento local (Skills, KB, Docs) para containers com governança DOC2.5.

### 1.1 Arquitetura Docker

```
┌─────────────────────────────────────────────────────────┐
│                   Docker Stack                           │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │     cindy-orchestrator (Custom Build)            │   │
│  │  - Node.js 18 Alpine                             │   │
│  │  - Skills Discovery                              │   │
│  │  - KB & Docs embedded                            │   │
│  │  - DOC2.5 Governance                             │   │
│  │  - Health checks                                 │   │
│  └────────────┬─────────────────────────────────────┘   │
│               │                                          │
│  ┌────────────▼─────────────────────────────────────┐   │
│  │     n8n-local (Official n8n image)               │   │
│  │  - SQLite persistence                            │   │
│  │  - Workflow engine                               │   │
│  │  - Webhook receiver                              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │     redis-cache (Optional)                       │   │
│  │  - Cache layer                                   │   │
│  │  - Session storage                               │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 2. Pré-requisitos

### 2.1 Software Necessário

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git (para clonar o repositório)
- 2GB RAM mínimo (4GB recomendado)
- 5GB espaço em disco

### 2.2 Tokens e Credenciais

- Token do Telegram Bot (via @BotFather)
- N8N Encryption Key (gerar com `openssl rand -base64 32`)

## 3. Setup Inicial

### 3.1 Preparar Ambiente

```powershell
# Clone o repositório
git clone https://github.com/scaixeta/cindy-oc.git
cd cindy-oc

# Copie o exemplo de environment
Copy-Item .env.docker.example .scr\.env

# Edite e preencha as credenciais
notepad .scr\.env
```

### 3.2 Variáveis Obrigatórias

Edite `.scr/.env` e configure:

```env
TELEGRAM_BOT_TOKEN=seu_token_aqui
N8N_ENCRYPTION_KEY=sua_chave_aqui
```

### 3.3 Gerar N8N Encryption Key

```powershell
# Windows (PowerShell)
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)

# Linux/Mac
openssl rand -base64 32
```

## 4. Build e Deploy

### 4.1 Build da Imagem

```powershell
# Build da imagem customizada
docker compose -f docker-compose.production.yml build cindy-orchestrator
```

**O que acontece no build:**

1. **Stage 1 (builder)**: Instala dependências Node.js
2. **Stage 2 (knowledge)**: Compila Skills, KB e Docs em índices JSON
3. **Stage 3 (runtime)**: Cria imagem final com Alpine Linux

### 4.2 Deploy Stack Completo

```powershell
# Modo básico (orchestrator + n8n)
docker compose -f docker-compose.production.yml up -d

# Modo completo (com Redis cache)
docker compose -f docker-compose.production.yml --profile full up -d
```

### 4.3 Verificar Status

```powershell
# Ver containers rodando
docker compose -f docker-compose.production.yml ps

# Ver logs
docker compose -f docker-compose.production.yml logs -f cindy-orchestrator

# Ver logs do n8n
docker compose -f docker-compose.production.yml logs -f n8n-local
```

## 5. Migração de Conhecimento Local → Docker

### 5.1 O que é Portado Automaticamente

Durante o build, os seguintes artefatos locais são copiados para o container:

| Artefato Local | Destino no Container | Propósito |
|---|---|---|
| `.cline/skills/` | `/app/.cline/skills/` | Skills discovery |
| `KB/` | `/app/KB/` | Knowledge base |
| `docs/` | `/app/docs/` | Documentação técnica |
| `Templates/` | `/app/Templates/` | Templates DOC2.5 |
| `rules/` | `/app/rules/` | Regras de governança |
| `Cindy_Contract.md` | `/app/Cindy_Contract.md` | Contrato canônico |

### 5.2 Skills Discovery

O build cria índices JSON para discovery rápido:

- `skills-index.json` - Lista todas as skills disponíveis
- `kb-index.json` - Mapeia arquivos da KB
- `docs-index.json` - Indexa documentação

**Exemplo de skills-index.json:**

```json
{
  "skills": [
    "n8n-workflow-patterns",
    "n8n-workflow-deployment",
    "doc25-governance",
    "docker-specialist"
  ]
}
```

### 5.3 Volumes Persistentes

Dados que **não** são embedados na imagem e precisam persistir:

```yaml
volumes:
  cindy-state:/app/state      # Estado do orchestrator
  cindy-logs:/app/logs        # Logs rotacionados
  cindy-cache:/app/cache      # Cache temporário
  n8n-data:/home/node/.n8n    # Workflows n8n
```

## 6. Operações

### 6.1 Parar Stack

```powershell
docker compose -f docker-compose.production.yml stop
```

### 6.2 Reiniciar Orchestrator

```powershell
docker compose -f docker-compose.production.yml restart cindy-orchestrator
```

### 6.3 Rebuild Após Mudanças

```powershell
# Se você alterou Skills, KB ou código
docker compose -f docker-compose.production.yml up -d --build
```

### 6.4 Ver Logs em Tempo Real

```powershell
# Apenas orchestrator
docker compose -f docker-compose.production.yml logs -f cindy-orchestrator

# Todos os serviços
docker compose -f docker-compose.production.yml logs -f
```

### 6.5 Inspecionar Container

```powershell
# Entrar no container (shell)
docker exec -it cindy-orchestrator sh

# Ver skills descobertas
docker exec cindy-orchestrator cat /app/skills-index.json

# Ver estado do orchestrator
docker exec cindy-orchestrator cat /app/state/orchestrator.json
```

## 7. Health Checks

### 7.1 Verificar Health

```powershell
# Ver status de health
docker inspect cindy-orchestrator | Select-String -Pattern "Health"

# Ver último resultado do health check
docker inspect cindy-orchestrator --format='{{.State.Health.Status}}'
```

### 7.2 O que é Verificado

O health check (`docker/healthcheck.sh`) valida:

1. ✅ Arquivo de estado existe
2. ✅ Processo Node.js está rodando
3. ⚠️  Taxa de erro < 30%
4. ⚠️  Logs não estão stale (< 5min)

## 8. Observabilidade

### 8.1 Métricas (Porta 9090)

```powershell
# Acessar métricas (quando implementado)
curl http://localhost:9090/metrics
```

### 8.2 Logs Estruturados

Logs são gravados em:

- Container stdout/stderr → `docker logs`
- Arquivo local → `/app/logs/orchestrator-YYYYMMDD.log`

### 8.3 Estado Persistido

```powershell
# Ver estado JSON
docker exec cindy-orchestrator cat /app/state/orchestrator.json
```

**Exemplo de estado:**

```json
{
  "initialized_at": "2026-03-26T17:00:00Z",
  "mode": "docker",
  "governance": "enabled",
  "version": "1.0.0-docker",
  "stats": {
    "messages_processed": 142,
    "errors_count": 3,
    "uptime_seconds": 3600
  }
}
```

## 9. Troubleshooting

### 9.1 Container não Inicia

```powershell
# Ver logs de inicialização
docker compose -f docker-compose.production.yml logs cindy-orchestrator

# Verificar entrypoint
docker logs cindy-orchestrator 2>&1 | Select-String "PREFLIGHT"
```

**Causas comuns:**

- `TELEGRAM_BOT_TOKEN` não configurado
- Porta 9090 já em uso
- n8n não está healthy

### 9.2 Skills não Descobertas

```powershell
# Verificar se skills foram copiadas no build
docker exec cindy-orchestrator ls -la /app/.cline/skills/

# Ver índice de skills
docker exec cindy-orchestrator cat /app/skills-index.json
```

### 9.3 n8n não Conecta

```powershell
# Verificar se n8n está healthy
docker compose -f docker-compose.production.yml ps n8n-local

# Testar conectividade interna
docker exec cindy-orchestrator curl -f http://n8n-local:5678/healthz
```

## 10. Segurança

### 10.1 Práticas Recomendadas

✅ **SIM:**
- Use `.scr/.env` para secrets (gitignored)
- Gere N8N_ENCRYPTION_KEY forte
- Rode como usuário `node` (não root)
- Use health checks

❌ **NÃO:**
- Não commite `.env` com tokens reais
- Não exponha n8n publicamente sem auth
- Não use `latest` tag em produção

### 10.2 Hardening

```yaml
# Limitar recursos no docker-compose.yml
cindy-orchestrator:
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 512M
      reservations:
        memory: 256M
```

## 11. Backup e Restore

### 11.1 Backup de Volumes

```powershell
# Backup do estado
docker run --rm -v cindy-state:/data -v ${PWD}:/backup alpine tar czf /backup/cindy-state-backup.tar.gz -C /data .

# Backup workflows n8n
docker run --rm -v n8n-data:/data -v ${PWD}:/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .
```

### 11.2 Restore

```powershell
# Restore estado
docker run --rm -v cindy-state:/data -v ${PWD}:/backup alpine sh -c "cd /data && tar xzf /backup/cindy-state-backup.tar.gz"
```

## 12. Atualizações

### 12.1 Update da Imagem

```powershell
# Rebuild com nova versão
docker compose -f docker-compose.production.yml build --no-cache

# Deploy nova versão
docker compose -f docker-compose.production.yml up -d
```

### 12.2 Rollback

```powershell
# Voltar para versão anterior
docker compose -f docker-compose.production.yml down
docker image rm cindy-oc-cindy-orchestrator:latest
docker compose -f docker-compose.production.yml up -d
```

---

## Referências

- [Dockerfile.cindy-orchestrator](../Dockerfile.cindy-orchestrator)
- [docker-compose.production.yml](../docker-compose.production.yml)
- [.env.docker.example](../.env.docker.example)
- [Cindy Contract](../Cindy_Contract.md)
- [WORKSPACE_RULES.md](../rules/WORKSPACE_RULES.md)
