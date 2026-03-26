# Change Request - S3: Cindy Orchestrator como Entidade Docker

## 1. Identificacao

- ID: `CR-S3-DOCK-01`
- Projeto: `Cindy OC`
- Tipo: Arquitetura / Infraestrutura
- Estado: Em validacao pelo PO
- Data: 2026-03-26 UTC

## 2. Estado Atual

### 2.1 Infraestrutura Docker

| Container | Status | Uptime | Funcao |
|-----------|--------|--------|--------|
| `n8n-local` | ✅ Running | 56 min | Workflow engine |
| `cindy-ai-orchestrator` | ✅ Running | 4 horas | Bot Telegram |

### 2.2 docker-compose.yml Atual

```yaml
services:
  cindy-ai-orchestrator:
    image: node:18-alpine
    command: ["node", "telegram-bot.js"]
    depends_on: n8n-local
    
  n8n-local:
    image: n8nio/n8n:latest
    ports: 5678:5678
    N8N_DB_TYPE: sqlite
```

### 2.3 O que funciona hoje

- ✅ Telegram Bot com long polling
- ✅ Envio de mensagens para webhook n8n
- ✅ n8n com workflow MVP ativo
- ✅ Comunicacao entre containers via rede `cindy-local`

## 3. O que falta para Cindy Orchestrator "de verdade"

### 3.1 Problema Atual

O container `cindy-ai-orchestrator` atual é apenas um "bot Telegram", não um "orchestrator". Falta:

| # | Componente | Status | Prioridade |
|---|------------|--------|------------|
| 1 | Dockerfile dedicado | ❌ Faltando | P1 |
| 2 | Discovery de skills/docs | ❌ Não implementado | P1 |
| 3 | Roteamento inteligente (não só Telegram) | ❌ Só Telegram | P2 |
| 4 | Awareness DOC2.5 | ❌ Sem contexto | P2 |
| 5 | Logs centralizados | ❌ Só stdout | P2 |
| 6 | Health check | ❌ Não configurado | P2 |
| 7 | Capacidade de invocar workflows n8n | ⚠️ Parcial | P1 |

### 3.2 Proposta: Cindy Orchestrator como Serviço Docker

```
┌─────────────────────────────────────────────────────────┐
│                   Cindy Orchestrator                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │   Router     │  │   Skills    │  │   Context   │   │
│  │  (Mensagens) │  │  Discovery  │  │   Manager   │   │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
│         │                 │                 │           │
│         └────────────┬────┴────────┬────────┘           │
│                      │             │                     │
│              ┌───────▼─────────────▼───────┐             │
│              │       Core Engine           │             │
│              │  (Regras DOC2.5 + Gates)    │             │
│              └───────────────┬─────────────┘             │
│                              │                            │
│         ┌────────────────────┼────────────────────┐       │
│         │                    │                    │       │
│  ┌──────▼──────┐   ┌───────▼───────┐  ┌──────▼──────┐ │
│  │   Telegram   │   │     n8n       │  │   Future:   │ │
│  │    Bot       │   │   Workflow    │  │   Slack,    │ │
│  │  (Listener)  │   │   Executor    │  │   Discord   │ │
│  └──────────────┘   └───────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 4. Roadmap Proposto

### Fase 1: Containerizacao Base (S3)

- [ ] Criar `Dockerfile.cindy-orchestrator` (multi-stage build)
- [ ] Adicionar `healthcheck` no docker-compose
- [ ] Configurar logging estruturado
- [ ] Criar script de entrypoint inteligente

### Fase 2: Core Orchestrator (S4)

- [ ] Implementar discovery de skills
- [ ] Integrar contexto DOC2.5
- [ ] Criar router de mensagens por tipo/intent
- [ ] Implementar gate de validacao

### Fase 3: Integração Profunda (S5)

- [ ] API client n8n (invocar workflows)
- [ ] Cache Redis para estado
- [ ] Fallback entre canais
- [ ] Dashboard de observabilidade

## 5. Gate de Decisao

| Pergunta | Resposta Atual | Acao |
|----------|----------------|------|
| n8n está funcional? | ✅ Sim | Continuar |
| Telegram está integrado? | ✅ Sim | Usar como canal MVP |
| Container está rodando? | ✅ Sim | Base OK |
| É orchestrator de verdade? | ❌ Não | Precisa evoluir |

## 6. Recomendacao

Seguir roadmap em 3 fases:
1. **S3**: Containerizacao + hardening
2. **S4**: Core orchestrator com DOC2.5
3. **S5**: Integracao profunda + multi-canal

## 7. Pendente

- Aprovacao do PO para prosseguir
- Definicao de qual fase priorizar primeiro

---

**Pendente de Aprovacao PO**
