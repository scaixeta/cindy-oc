# AGENT_TEAM_MODEL.md — Modelo Operacional da Equipe de 5 Agentes

**Data:** 2026-04-13
**Versão:** 1.0
**Classificação:** Norma operacional

---

## 1. Visão Geral

O Cindy Agent opera com **5 agentes autônomos** que se comunicam via ACP (Agent Communication Protocol) sobre Redis. Cada agente tem escopo definido, opera com autonomia dentro do seu domínio, e reportam à Cindy para consolidação antes de apresentar planos ao PO.

**Regras fundamentais:**
1. Agentes **nunca se comunicam em linguagem humana** entre si — apenas mensagens ACP estruturadas em JSON
2. Agentes **se reportam à Cindy**, não diretamente ao PO
3. Cindy **consolida e apresenta** planos de ação ao PO
4. PO é consultado apenas para **decisões grandes** e **aprovações de plano**

---

## 2. Equipe de Agentes

| Agente | Modelo | Escopo | Domínio principal |
|---|---|---|---|
| **Cindy** | MiniMax-M2.7 | Coordenadora/PM | Routing, triagem, intermediação, aprovação |
| **Sentivis** | GLM-5.1:cloud | IoT & Infra Specialist | ThingsBoard CE, n8n Railway, JWS, Cirrus Lab |
| **MiniMax** | MiniMax-M2.7 | AI & Logic Specialist | CindyAgent, DOC2.5, Hermes, OpenCode, código |
| **Scribe** | GLM-5.1:cloud | Docs & Integration Specialist | Swagger/OpenAPI, dashboards, docs técnicas |
| **GLM-5.1** | GLM-5.1:cloud | Senior Validator/QA | Code review, validação semântica, auditoria |

---

## 3. Modelo de Operação

```
┌─────────────────────────────────────────────────────────────┐
│                        VOCÊ (PO)                             │
│          Decisões grandes + Aprova planos                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌───────────────▼───────────────┐
          │  Agentes (autonomia operacional) │
          │                                 │
          │  Conversam via ACP (Redis)       │
          │  Decidem juntos                   │
          │  Geram plano de ação ────────────┼───► Cindy consolida
          │  Executam                        │
          │                                 │
          │  Se algo grande acontece ────────┼───► Cindy escala ao PO
          └─────────────────────────────────┘
                           │
                    Cindy (coordenadora)
```

### Fluxo Operacional

1. **Briefing** — PO dá direção geral
2. **Triagem** — Cindy distribui tarefa para agentes via ACP
3. **Discussão** — Agentes debatem via Redis Pub/Sub / Streams
4. **Plano** — Agentes geram plano de ação (em JSON estruturado)
5. **Consolidação** — Cindy reúne planos e apresenta ao PO
6. **Aprovação** — PO aprova ou ajusta
7. **Execução** — Agentes executam em paralelo
8. **Escala** — Se algo grande → Cindy consulta PO
9. **Retorno** — Resultado reportado ao PO via Cindy

---

## 4. Protocolo ACP

### Formato de Mensagem

```json
{
  "id": "uuid-v4",
  "type": "TASK|COMMAND|EVENT|RESPONSE|PLAN",
  "from": "agent_id",
  "to": "agent_id|*",
  "action": "action_name",
  "payload": {...},
  "meta": {
    "timestamp": "ISO8601",
    "reply_to": "correlation_id"
  }
}
```

### Canais

| Canal | Tipo | Uso |
|---|---|---|
| `acp:messages` | Pub/Sub | Eventos efêmeros (notificações, broadcasts) |
| `acp:stream:{agent_id}` | Stream | Tarefas persistidas com consumer group |

### Comandos principais

```python
# Publicar mensagem
acp.publish(to="sentivis", msg_type="TASK", action="configure_thresholds", payload={...}, from_agent="cindy")

# Publicar no stream (tarefas persistidas)
acp.stream_produce(agent_id="sentivis", msg_type="TASK", action="...", payload={...}, from_agent="cindy")

# Consumir do stream
acp.stream_consume(agent_id="minimax", group="agents", consumer="minimax-consumer")
```

---

## 5. RACI

| Atividade | Cindy | Sentivis | MiniMax | Scribe | GLM | PO |
|---|---|---|---|---|---|---|
| Triagem e distribuição | R | I | I | I | I | A |
| Discussão e planejamento | C | R | R | R | R | I |
| Plano de ação | A | C | C | C | C | A |
| Execução IoT/Infra | I | R | C | I | I | I |
| Execução código/AI | I | C | R | C | I | I |
| Execução docs | I | I | C | R | I | I |
| Teste técnico | A | I | I | I | R | I |
| Validação semântica | C | I | I | I | R | A |
| Detectar loop / risco | R | I | I | I | R | I |
| Correção | A | R | R | R | C | I |
| Decisão grande | I | C | C | C | C | A |
| Aprovação final | R | I | I | I | I | A |

R = Responsável (executa) | A = Aprovador (decide) | C = Consumidor | I = Informado

---

## 6. Gate de Classificação

Use `dual_model_gate.py` para classificar:

```bash
python .agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py "sua tarefa"
```

| Retorno | Destino | Suporte |
|---|---|---|
| ThingsBoard, n8n, IoT, Cirrus | Sentivis | MiniMax |
| Código, debug, Python, AI | MiniMax | GLM |
| Docs, Swagger, API | Scribe | GLM |
| Code review, validação | GLM | — |
| Não classificado | MiniMax | — |

---

## 7. Limite de Iteração

- Limite: **3-5 ciclos** Discussão→Execução→Validação
- Detecção: qualquer agente pode escalar para Cindy
- Após limite: Cindy escala para PO decidir

---

## 8. Scripts e Referências

| Script | Função |
|---|---|
| `.agents/scripts/acp_redis.py` | Biblioteca ACP (publish, subscribe, stream_produce, stream_consume) |
| `.agents/scripts/test_acp_multi_agent.py` | Teste de comunicação multi-agente |

| Documento | Função |
|---|---|
| `docs/ACP_PROTO.md` | Especificação formal do protocolo ACP |
| `docs/ARCHITECTURE.md` | Arquitetura completa do sistema |
| `rules/WORKSPACE_RULES.md` | Regra 27 (Orquestração de equipe) |
| `.agents/skills/dual-model-orchestrator/SKILL.md` | Skill de orquestração |

---

**Confiança:** Alta — modelo testado e operacional.