# AGENT_TEAM_MODEL.md — Modelo Operacional da Equipe de 5 Funções

**Data:** 2026-04-13
**Versão:** 1.0
**Classificação:** Norma operacional

---

## 1. Visão Geral

O Cindy Agent opera com **5 funções autônomas** que se comunicam via ACP (Agent Communication Protocol) sobre Redis. Cada função tem escopo definido, opera com autonomia dentro do seu domínio, e reporta à Cindy para consolidação antes de apresentar planos ao PO.

**Regras fundamentais:**
1. As funções **nunca se comunicam em linguagem humana** entre si — apenas mensagens ACP estruturadas em JSON
2. As funções **se reportam à Cindy**, não diretamente ao PO
3. Cindy **consolida e apresenta** planos de ação ao PO
4. Cindy atua como **orquestradora e Scrum Master operacional**
5. PO é consultado apenas para **decisões grandes** e **aprovações de plano**

---

## 2. Equipe de Agentes

| Função | Escopo | Domínio principal | Ferramentas / foco |
|---|---|---|---|
| **Cindy** | Coordenadora | Routing, triagem, intermediação, consolidação, escala ao PO | ACP, regras, decisões de fronteira |
| **AICoders** | Time de desenvolvimento | Implementação, refatoração, debug e automação | `OpenCode`, subagentes independentes, código, testes de unidade |
| **Escriba** | Documentação e integração | Docs, contratos, API, KB e runbooks | Markdown, Swagger/OpenAPI, contratos operacionais |
| **Gateway** | Gate técnico e segurança | Aprovação técnica pré-subida, qualidade, bugs e segurança | `Playwright`, `SonarQube`, `Sec`, code gate |
| **QA** | Validação e aceite | Testes funcionais, regressão, smoke e aceite final | E2E, validação semântica, não-regressão |

---

## 3. Modelo de Operação

```
┌─────────────────────────────────────────────────────────────┐
│                        VOCÊ (PO)                             │
│          Decisões grandes + Aprova planos                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌───────────────▼───────────────┐
          │  Funções (autonomia operacional) │
          │                                 │
          │  Conversam via ACP (Redis)       │
          │  Decidem dentro do domínio       │
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
2. **Triagem** — Cindy distribui tarefa para funções via ACP
3. **Discussão** — Funções debatem via Redis Pub/Sub / Streams
4. **Plano** — Funções geram plano de ação em JSON estruturado; subagentes podem divergir e chegar à mesma decisão por caminhos diferentes
5. **Consolidação** — Cindy reúne planos e apresenta ao PO
6. **Aprovação** — PO aprova ou ajusta
7. **Execução** — Funções executam em paralelo
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
acp.publish(to="aicoders", msg_type="TASK", action="implement_feature", payload={...}, from_agent="cindy")

# Publicar no stream (tarefas persistidas)
acp.stream_produce(agent_id="gateway", msg_type="TASK", action="code_gate", payload={...}, from_agent="cindy")

# Consumir do stream
acp.stream_consume(agent_id="qa", group="agents", consumer="qa-consumer")
```

---

## 5. RACI

| Atividade | Cindy | AICoders | Escriba | Gateway | QA | PO |
|---|---|---|---|---|---|---|
| Triagem e distribuição | R | I | I | I | I | A |
| Discussão e planejamento | C | R | R | R | R | I |
| Plano de ação | A | C | C | C | C | A |
| Execução código/AI | I | R | I | C | I | I |
| Execução docs/API | I | I | R | I | I | I |
| Gate técnico pré-subida | A | I | I | R | C | I |
| Validação funcional | C | I | I | C | R | A |
| Detectar loop / risco | R | I | I | R | R | I |
| Correção | A | R | C | C | C | I |
| Decisão grande | I | C | C | C | C | A |
| Aprovação final | R | I | I | C | R | A |

R = Responsável (executa) | A = Aprovador (decide) | C = Consumidor | I = Informado

---

## 6. Gate de Classificação

Use `dual_model_gate.py` para classificar:

```bash
python .agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py "sua tarefa"
```

| Retorno | Destino | Suporte |
|---|---|---|
| Código, debug, Python, AI | AICoders | Gateway |
| Docs, Swagger, API | Escriba | QA |
| Code review, validação, segurança | Gateway | QA |
| Validação funcional / aceite | QA | Gateway |
| Não classificado | Cindy | AICoders |

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
