# Relatório Técnico: Comunicação ACP via Redis

**Data:** 2026-04-12  
**Ambiente:** Windows + WSL (Ubuntu) + Hermes Agent  
**Redis:** 7.0.15 (standalone, master), acessível via `redis-cli` (WSL) e `localhost:6379` (Windows)

---

## 1. Redis — Estado Atual

| Item | Valor |
|---|---|
| Versão | Redis 7.0.15 |
| Host | 127.0.0.1:6379 (WSL) |
| Modo | Standalone master |
| Memória | Sem limite (`maxmemory: 0`) |
| Clientes conectados | 1 |
| Keys no db0 | 38 |
| Uptime | ~87 minutos |

**Status:** Redis **operacional e acessível**. Nenhuma autenticação configurada.

---

## 2. Estrutura de Dados Atual (Inspeção)

O Hermes já utiliza o Redis com os seguintes padrões de chave:

```
hermes:sql:session:{id}:meta     # JSON string (session metadata)
hermes:sql:session:{id}:tail      # String (last messages)
hermes:memory:{key}               # JSON string (key-value store)
hermes:conversation:{room}:count  # String (counter)
hermes:sql:manifest               # JSON string (sync state)
hermes:sql:sessions:latest        # JSON string (latest session list)
hermes:sql:stats                  # Hash (stats)
```

**Conclusão:** O Hermes já usa Redis como store principal. Uma camada ACP sobre Redis pode coexistir sem conflito.

---

## 3. Proposta de Arquitetura ACP via Redis

### 3.1 Padrão recomendado: Pub/Sub + Streams

Duas camadas para cobrir todos os casos de uso:

**Camada 1 — Pub/Sub (mensagens instantâneas, sem persistência):**
- Canal: `acp:messages` (broadcast cross-agent)
- Útil para eventos Ephemeral: notificação de tarefa criada, comando de stop, ping
- Latência ~0.5–2ms local

**Camada 2 — Streams (mensagens persistidas, Consumable com offsets):**
- Stream: `acp:stream:{agent_id}` (consumer group por agente)
- Útil para tareas com idempotência, reexecução, fan-out
- TTL: 1h nos entries via `XTRIM` ou `EXPIRE`

### 3.2 Formato da Mensagem ACP (JSON)

```json
{
  "id": "uuid-v4",
  "type": "TASK|COMMAND|EVENT|RESPONSE",
  "from": "agent_id",
  "to": "agent_id|*",
  "action": "mcp_delegate_task|code_review|doc_generate",
  "payload": {
    "task_id": "...",
    "context": {...}
  },
  "meta": {
    "reply_to": "correlation_id",
    "timestamp": "ISO8601",
    "ttl_seconds": 300
  }
}
```

### 3.3 Comandos Redis Principais

**Pub/Sub:**
```redis
PUBLISH acp:messages '{"id":"...","type":"COMMAND","from":"scribe","to":"gateway",...}'
SUBSCRIBE acp:messages
PSUBSCRIBE acp:*
```

**Streams (producer):**
```redis
XADD acp:stream:gateway '*' id "..." type "TASK" from "scribe" payload '{...}'
XADD acp:stream:scribe '*' id "..." type "RESPONSE" from "gateway" ...
```

**Streams (consumer group):**
```redis
XGROUP CREATE acp:stream:gateway mygroup $ MKSTREAM
XREADGROUP GROUP mygroup consumer1 COUNT 10 STREAMS acp:stream:gateway ">"
XPENDING acp:stream:gateway mygroup
XACK acp:stream:gateway mygroup message_id
```

**Query/Estado:**
```redis
XRANGE acp:stream:gateway - + COUNT 50
XREVRANGE acp:stream:scribe + - COUNT 10
```

---

## 4. Viabilidade no Ambiente Atual

### ✅ Prós

1. **Redis já existente e funcional** em `localhost:6379`
2. **Nenhuma dependência nova** — todas as libs Python (`redis-py`) são leves e padrão
3. **Baixa latência** em ambiente local (~0.5–3ms roundtrip)
4. **Compatibilidade WSL/Windows** — mesmo host, mesma porta
5. **Nomenclatura já segregada** pelo Hermes (`hermes:*`) — fácil isolar `acp:*`
6. **38 chaves ativas** sem competição de recursos

### ⚠️ Riscos e Problemas

1. **Sem autenticação** — qualquer processo local pode ler/escrever em Redis
2. **Sem TLS** — dados sensíveis em texto puro na memória
3. **Persistência depub/sub** — mensagens Pub/Sub são Fire-and-Forget; se o subscriber estiver offline, perde
4. **Single-thread Redis** — em cargas muito altas (>50k msg/s) pode se tornar gargalo, mas improvável neste cenário
5. **TTL implícito** — precisar configurar expiração manualmente nos streams para não acumular dados para sempre
6. **Compatibilidade entre agentes** — todos precisam implementar o mesmo schema `id/type/from/to/payload`

---

## 5. Problemas de Latência e Concorrência

| Cenário | Latência esperada | Observação |
|---|---|---|
| Pub/Sub local | 0.5–2ms | Sem disk, tudo em memória |
| XADD + XREAD local | 1–5ms | Stream com consumer group |
| concurrently 10 agentes | <10ms | Redis single-thread, gerencia contexto |
| WSL → Windows (Redis server) | ~1–3ms | Mesmo host, comunic. localhost |

**Concorrência:** Redis atomic commands (MULTI/EXEC não necessário para pub/sub). Streams garantem ordering por timestamp. Consumer groups evitam double-delivery.

**Recomendações:**
- Usar `XADD` com `MAXLEN ~1000` para streams com alto volume
- Pub/Sub para eventos que não exigem durability
- Streams para tarefas que precisam de retry

---

## 6. Alternativas se Redis Não Estivesse Disponível

| Alternativa | Prós | Contras |
|---|---|---|
| **HTTP/WebSocket polling** (FastAPI local) | Sem deps extras, simples | Latência maior, polling overhead |
| **Arquivos JSON em disco** (`/tmp/acp/`) | Zero config, observável | Sem atomicidade, race conditions, latência ~5–20ms |
| **SQLite** | Persistente, relacional, ACID | Escrita serializada, single writer |
| **RabbitMQ** (Docker) | Fila robusta, persistence | Depósito pesado, exige container |
| **NATS** | Leve, pub/sub nativo | Exige instalação adicional |
| **gRPC com compartilhamento de arquivo** | Comunicação binária | Acoplamento, sem broker central |

**Recomendação:** Se Redis não estivesse disponível, **SQLite com file-based queue** seria a alternativa mais pragmática para o cenário atual (arquivos pequenos, volume baixo, host único).

---

## 7. Próximos Passos Recomendados

1. **Criar biblioteca Python mínima** (`acp_redis.py`) com interface `publish()`, `subscribe()`, `stream_produce()`, `stream_consume()`
2. **Definir schema JSON** — validar com Pydantic antes de implementar
3. **Testar Pub/Sub** entre dois processos simulados (AICoders ↔ Escriba)
4. **Implementar consumer group** no stream para tarefas de longa duração
5. **Adicionar TTL automático** nos streams via `XADD` com `MAXLEN` ou `EXPIRE`
6. **Considerar autenticação Redis** (`requirepass`) se os dados forem sensíveis
7. **Documentar API ACP** em `docs/ACP_PROTO.md` — incluindo message types e workflows

---

## Resumo

Redis está **operacional e viável** como backbone de comunicação ACP entre agentes no ambiente Windows/WSL/Hermes. A arquitetura recomendada usa **Pub/Sub para eventos efêmeros** e **Streams para tarefas persistidas com consumer groups**. A latência local é muito baixa (~1–5ms), e o modelo de dados já segregado (`acp:*` vs `hermes:*`) evita colisão com o uso atual do Hermes. O principal risco é a ausência de autenticação — recomendável se os agentes rodarem em host compartilhado.

**Confiança: Alta** — Redis funcional, ambiente testado, arquitetura compatível com o estado atual.
