---
name: dual-model-orchestrator
description: Orquestrar tarefas entre os 5 agentes autônomos (Cindy, Sentivis, MiniMax, Scribe, GLM-5.1) seguindo o modelo de operação aprovado. Use quando a tarefa envolver desenvolvimento, IoT, documentação, validação ou qualquer trabalho que exija planejamento e decisão em equipe.
---

# Dual-Model Orchestrator — Equipe de 5 Agentes

## Modelo de Operação

```
┌─────────────────────────────────────────────────────────────┐
│                        VOCÊ (PO)                             │
│          Decisões grandes + Aprova planos                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌───────────────▼───────────────┐
          │  Agentes (autonomia operacional) │
          │                                 │
          │  Conversam entre si              │
          │  Decidem juntos                  │
          │  Geram plano de ação ────────────┼───► Você aprova
          │  Executam                        │
          │                                 │
          │  Se algo grande acontece ────────┼───► Você é consultado
          └─────────────────────────────────┘
```

**Fluxo Operacional:**

1. **Briefing** — PO dá direção geral
2. **Discussão** — Agentes conversam, debatem, analisam alternativas
3. **Plano** — Trazem plano de ação concreto
4. **Aprovação** — PO aprova ou ajusta
5. **Execução** — Agentes executam em paralelo
6. **Big decision** — Consultam PO se algo fora do previsto
7. **Retorno** — Resultado finalReported ao PO

## Papéis

| Agente | Papel | Escopo |
|---|---|---|
| Cindy | Coordenadora / PM | Routing, triagem, intermediação, comunicação, aprovação |
| Sentivis | IoT & Infra Specialist | ThingsBoard CE, n8n Railway, JWS, Cirrus Lab, telemetria |
| MiniMax | AI & Logic Specialist | CindyAgent, DOC2.5, Hermes, OpenCode, código |
| Scribe | Docs & Integration Specialist | Swagger/OpenAPI, dashboards, docs técnicas, API contracts |
| GLM-5.1 | Senior Validator / QA | Code review, validação semântica, auditoria, compliance |

## RACI

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

R = Responsável (executa) | A = Aprovador (decide) | C = Consultado | I = Informado

## Fluxo Iterativo

```
PO define direção geral
    ↓
Cindy tria e distribui
    ↓
Agentes discutem → geram plano de ação
    ↓
Plano Reported ao PO → Aprovação
    ↓
Execução distribuída
    ↓
Se algo grande → consultam PO
    ↓
Retorno ao PO
```

## Gate de Classificação (semântico)

Use `dual_model_gate.py` para classificar o tipo de tarefa:

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

## Gate de Iteração

- Limite: 3 a 5 ciclos Discussão→Execução→Validação
- Detecção: qualquer agente pode escalar para Cindy
- Após limite: escala para PO

## Execução por Agente

**Sentivis (IoT/Infra):**
```bash
cmd.exe /c "ollama run glm-5.1:cloud \"[tarefa IoT/Infra]\""
```

**MiniMax (código/AI):**
```bash
opencode run -m minimax/MiniMax-M2.7 "[tarefa]"
```

**GLM (validação):**
```bash
cmd.exe /c "ollama run glm-5.1:cloud \"[tarefa de validação]\""
```

## Referências

- `docs/ARCHITECTURE.md` — arquitetura completa da equipe de 5 agentes
- `rules/WORKSPACE_RULES.md` — Regra 27 com RACI e critérios de roteamento
- `.agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py`