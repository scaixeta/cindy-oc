# ACP_PROTO.md — Especificação do Agent Communication Protocol via Redis

**Data:** 2026-04-13
**Versão:** 1.0
**Status:** Testado e operacional

---

## 1. Visão Geral

O ACP (Agent Communication Protocol) é o protocolo de comunicação entre os 5 agentes autônomos (Cindy, Sentivis, MiniMax, Scribe, GLM-5.1). Usa **Redis** como backbone de transporte com duas camadas: **Pub/Sub** para eventos efêmeros e **Streams** para tarefas persistidas.

**Princípios:**
- Agentes **nunca usam linguagem humana** entre si
- Todas as mensagens são **JSON estruturado**
- Cindy é a **coordenadora** — agentes reportam a ela
- PO é consultado apenas para **decisões grandes**

---

## 2. Backbone Redis

| Item | Valor |
|---|---|
| Host | `localhost:6379` (WSL/Windows) |
| Versão | Redis 7.0.15 |
| Modo | Standalone master |
| Autenticação | Nenhuma (localhost only) |
| Namespace | `acp:*` (não colide com `hermes:*`) |

---

## 3. Camadas de Transporte

### 3.1 Pub/Sub — Eventos Efêmeros

**Canal:** `acp:messages` (broadcast)

**Uso:** Notificações instantâneas que não precisam de persistência (eventos, broadcasts, pings).

**Comandos Redis:**
```redis
PUBLISH acp:messages '{"id":"...","type":"EVENT","from":"scribe","to":"*","action":"docs_updated",...}'
SUBSCRIBE acp:messages
PSUBSCRIBE acp:*
```

**Latência:** ~0.5–2ms local

### 3.2 Streams — Tarefas Persistidas

**Stream:** `acp:stream:{agent_id}` (um por agente)

**Uso:** Tarefas que exigem idempotência, retry, ou consumo ordenado com offset.

**Consumer Groups:** Cada agente tem seu consumer group para evitar double-delivery.

**Comandos Redis:**
```redis
# Produzir
XADD acp:stream:sentivis '*' id "..." type "TASK" from "cindy" payload '{...}'

# Criar consumer group
XGROUP CREATE acp:stream:sentivis agents $ MKSTREAM

# Consumir
XREADGROUP GROUP agents consumer1 COUNT 10 STREAMS acp:stream:sentivis ">"

# Pending messages
XPENDING acp:stream:sentivis agents

# Acknowledgement
XACK acp:stream:sentivis agents message_id
```

**Latência:** ~1–5ms local

---

## 4. Formato de Mensagem

```json
{
  "id": "uuid-v4",
  "type": "TASK | COMMAND | EVENT | RESPONSE | PLAN",
  "from": "agent_id",
  "to": "agent_id | *",
  "action": "action_name",
  "payload": {
    "task_id": "...",
    "context": {...}
  },
  "meta": {
    "timestamp": "ISO8601",
    "reply_to": "correlation_id",
    "ttl_seconds": 300
  }
}
```

### Tipos de Mensagem

| Tipo | Uso | Exemplo |
|---|---|---|
| `TASK` | Tarefa atribuída | Cindy → Sentivis: configurar threshold |
| `COMMAND` | Comando de execução | GLM → MiniMax: revisar código |
| `EVENT` | Notificação broadcast | Scribe → *: docs atualizados |
| `RESPONSE` | Resposta a tarefa | Sentivis → Cindy: tarefa concluída |
| `PLAN` | Plano de ação | Agentes → Cindy: plano para approval |

---

## 5. Bibliotecas e Scripts

### `acp_redis.py` — Interface Python

```python
from acp_redis import ACPRedis

acp = ACPRedis()

# Pub/Sub
msg_id = acp.publish(to="sentivis", msg_type="TASK", action="configure_thresholds", payload={...}, from_agent="cindy")

# Stream
msg_id = acp.stream_produce(agent_id="sentivis", msg_type="TASK", action="...", payload={...}, from_agent="cindy")

# Consumir stream
messages = acp.stream_consume(agent_id="minimax", group="agents", consumer="minimax-consumer")
```

### `test_acp_multi_agent.py` — Teste de ciclo completo

```bash
python3 .agents/scripts/test_acp_multi_agent.py
```

**Resultado testado:**
```
[1] Scribe faz broadcast... ✓
[2] Cindy delega tarefa para Sentivis... ✓
[3] MiniMax envia tarefa para Sentivis... ✓
[4] GLM envia comando via stream... ✓
[5] Mensagens consumidas do stream... ✓
[6] Keys acp:* no Redis... ✓
```

---

## 6. Workflow de Exemplo

### Briefing: "Monitorar telemetria do NIMBUS-AERO"

```
1. PO dá direção → Cindy
2. Cindy publica TASK para Sentivis
   PUBLISH acp:messages {"type":"TASK","from":"cindy","to":"sentivis","action":"monitor_telemetry",...}

3. Sentivis analisa e responde via stream
   XADD acp:stream:cindy {...,"action":"telemetry_plan",...}

4. Cindy consome stream e consolida
   XREADGROUP GROUP agents COUNT 10 STREAMS acp:stream:cindy ">"

5. Cindy apresenta plano ao PO
   {"type":"PLAN","from":"sentivis","to":"cindy","payload":{plan:"V1 com 3 widgets, refresh 30s"...}}

6. PO aprova → Cindy distribui para execução
7. Agentes executam via streams各自
8. GLM valida → RESPONSE → Cindy → PO
```

---

## 7. Validação do Protocolo

**Testes realizados em 2026-04-13:**

| Teste | Resultado | Latência |
|---|---|---|
| Pub/Sub publish | ✅ OK | <1ms |
| Stream produce + consume | ✅ OK | 1-5ms |
| Ciclo 3 agentes (Cindy, Sentivis, MiniMax) | ✅ OK | <2s total |
| Keys `acp:*` no Redis | ✅ 2 streams criados | — |

**Scripts:**
- `/mnt/c/CindyAgent/.agents/scripts/acp_redis.py`
- `/mnt/c/CindyAgent/.agents/scripts/test_acp_multi_agent.py`

---

## 8. Problemas Conhecidos

| Problema | Severidade | Workaround |
|---|---|---|
| Sem autenticação Redis | Média |localhost only; não expor porta |
| Pub/Sub fire-and-forget | Baixa | Usar Streams para tarefas que precisam de ack |
| Sem TLS | Baixa |localhost only |

---

## 9. Referências

- `docs/AGENT_TEAM_MODEL.md` — modelo operacional da equipe
- `docs/ARCHITECTURE.md` — arquitetura dual-modelo
- `rules/WORKSPACE_RULES.md` — Regra 27
- `.agents/skills/dual-model-orchestrator/SKILL.md` — skill de orquestração

---

**Confiança:** Alta — testado em ambiente real, Redis operacional, protocolo validado.