# ARCHITECTURE.md — Arquitetura

## Visao Geral

Cindy Agent e o repositorio-base da Cindy, usado para integrar:

- governanca DOC2.5
- runtime Hermes em WSL
- OpenCode CLI como tool de raciocinio profundo
- persona operacional da Cindy
- canal Telegram
- documentacao e rastreabilidade
- futura replicacao controlada para outros projetos da Cindy

## Arquitetura de Alto Nivel

```
┌──────────────────────────────────────────────────────┐
│                    Cindy Agent                       │
│        governanca + docs + KB + tracking             │
└───────────────┬───────────────────────┬─────────────┘
                │                       │
        ┌───────▼────────┐      ┌──────▼────────┐
        │ KB/hermes       │      │ rules/ + DOC2.5│
        │ persona canonica│      │ governanca     │
        └───────┬─────────┘      └──────┬─────────┘
                │                       │
                └──────────┬────────────┘
                           │
                    ┌──────▼────────────────────────┐
                    │ /root/.hermes (runtime vivo)    │
                    │ Hermes + memorias + config       │
                    └──────┬──────────────────────────┘
                           │
                    ┌──────▼─────────┐    ┌──────────────┐
                    │ Telegram Gateway│   │ OpenCode CLI │
                    └────────────────┘    │ (delegacao)  │
                                            └──────────────┘
```

## Componentes principais

### 1. Repositorio-base Cindy Agent

Mantem o canon do projeto:

- `README.md`
- `docs/`
- `Dev_Tracking*.md`
- `tests/bugs_log.md`
- `Cindy_Contract.md`
- `rules/`
- `KB/hermes/`

### 2. OpenCode CLI

Ferramenta de delegacao para tarefas simples/rapidas que exigem raciocinio profundo sobre codigo.

- Wrapper: `run_opencode.bat` (ou via `opencode run`)
- Modelo: `minimax/MiniMax-M2.7`
- Autenticacao: `MINIMAX_API_KEY` do Coding Plan em `.scr/.env`
- Invocado pela Cindy via `mcp_delegate_task` com `acp_command=opencode`

### 3. Codex CLI

Ferramenta de delegacao para tarefas complexas (planejamento, arquitetura, codigo de grande escopo, raciocinio profundo).

- Comando: `codex exec "prompt" -s read-only`
- Modelo: `gpt-5.2-codex` (OpenAI, reasoning effort: high, context: 400K)
- Autenticacao: `codex auth login` via browser OAuth (subscription ChatGPT)
- Selecao: tarefas que exigem planejamento profundo — OpenCode para o resto

### 4. KB canonica da Cindy para Hermes

Local: `KB/hermes/`

Funcao:
- definir identidade da Cindy
- registrar preferencias estaveis do operador
- preservar memoria operacional persistente
- orientar a sincronizacao do runtime vivo do Hermes

### 5. Runtime vivo do Hermes

Local: `/root/.hermes`

Funcao:
- hospedar o runtime efetivo da Cindy no Hermes
- armazenar `SOUL.md`, `USER.md`, `MEMORY.md`, `config.yaml`, `.env`, `state.db`
- executar o gateway Telegram via `hermes-gateway.service`
- manter `MiniMax-M2.7` como modelo primario do runtime
- manter `gpt-5.3-codex` como fallback operacional via `openai-codex`

### 5. Telegram

E o canal operacional principal quando o gateway esta ativo.

Sem gateway ativo, o Telegram nao desperta o sistema sozinho.

## Fluxo principal atual

1. ajustar KB canonica no repositorio-base
2. sincronizar/reativar o runtime vivo do Hermes
3. subir ou reiniciar o gateway Telegram
4. operar a Cindy via Telegram ou CLI
5. para tarefas complexas de codigo, delegar ao OpenCode via `mcp_delegate_task`
6. registrar fatos, decisoes e pendencias na documentacao e tracking
7. planejar replicacao para outros projetos antes de qualquer alteracao externa

## Arquitetura Dual-Modelo

### Visão Geral

O Cindy Agent opera com **5 agentes autônomos** em regime de orquestração colaborativa:

- **Cindy** (Coordenadora / PO) — triagem, intermediação, registro, aprovação
- **Sentivis** (IoT & Infra Specialist) — ThingsBoard, n8n, JWS, Cirrus Lab
- **MiniMax** (AI & Logic Specialist) — CindyAgent, DOC2.5, OpenCode, código
- **Scribe** (Docs & Integration Specialist) — Swagger, dashboards, documentação técnica
- **GLM-5.1** (Senior Validator / QA) — code review, validação semântica, compliance

### Modelo de Operação

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

1. **Briefing** — Você dá direção geral
2. **Discussão** — Agentes conversam, debatem, analisam alternativas entre si
3. **Plano** — Trazem um plano de ação concreto para você
4. **Aprovação** — Você aprova ou ajusta
5. **Execução** — Agentes executam em paralelo
6. **Decisao grande** — algo fora do previsto -> consultam voce antes de mudar o rumo
7. **Retorno** — resultado final reportado a voce

### Atribuição de Papéis

| Modelo | Papel | Escopo |
|---|---|---|
| Cindy | Coordenadora / PM | Routing, triagem, comunicação, intermediação |
| Sentivis 🆕 | IoT & Infra Specialist | ThingsBoard CE, n8n Railway, JWS, Cirrus Lab, telemetria |
| MiniMax | AI & Logic Specialist | CindyAgent, DOC2.5, Hermes, OpenCode, código |
| Scribe 🆕 | Docs & Integration Specialist | Swagger/OpenAPI, dashboards, docs técnicas, API contracts |
| GLM-5.1 | Senior Validator / QA | Code review, validação semântica, auditoria, compliance |

### Fluxo de Orquestração

```
PO define direção geral
    ↓
Cindy tria e distribui (quem faz o quê)
    ↓
Agentes discutem entre si → geram plano de ação
    ↓
Plano reportado ao PO -> voce aprova
    ↓
Execução distribuída
    ↓
Se algo grande acontece → consultam Você
    ↓
Resultado final reportado ao PO
```

### RACI — Equipe Completa

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

### Gate de Iteração

- Limite: 3 a 5 ciclos Discussão→Execução→Validação
- Detecção de loop: qualquer agente pode escalar para Cindy
- Após limite: escala para PO decidir

### Gate de Decisão (Classificação)

Roteamento semântico por palavras-chave — zero LLM no caminho de classificação.

| Tipo de tarefa | Destino primário | Suporte |
|---|---|---|
| ThingsBoard, n8n, IoT, Cirrus Lab | Sentivis | MiniMax |
| Código, debug, Python, AI | MiniMax | GLM |
| Docs, Swagger, API contracts | Scribe | GLM |
| Code review, validação semântica | GLM | — |
| Tarefa não classificada | MiniMax | — |

### Configuração

- **GLM-5.1**: `ollama run glm-5.1:cloud` (tier Free, MIT)
- **MiniMax-M2.7**: integrado via Hermes/OpenCode
- **Gate**: `.agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py`
- **Skill**: `.agents/skills/dual-model-orchestrator/SKILL.md`

## Fronteiras atuais

### Dentro do escopo atual

- Cindy Agent como repositorio-base
- Hermes + Telegram funcionando no ambiente local
- `hermes-gateway.service` ativo no Linux com healthcheck local validado
- OpenCode CLI como tool de delegacao (MiniMax M2.7)
- documentacao canonica e tracking da sprint S3
- mapa de replicacao em `Replicar.md`

### Fora do escopo atual

- replicacao automatica para todos os projetos listados
- fechamento da sprint S3
- endurecimento completo do bootstrap Windows para o servico systemd do gateway

## Referências da equipe de agentes

- `docs/AGENT_TEAM_MODEL.md` — modelo operacional da equipe de 5 agentes
- `docs/ACP_PROTO.md` — especificação formal do protocolo ACP
- `docs/DEVELOPMENT.md` — fluxo DOC2.5 e fluxo da equipe
- `docs/OPERATIONS.md` — comandos operacionais e ACP
- `docs/SETUP.md` — configuração do ambiente e pré-requisitos
- `rules/WORKSPACE_RULES.md` — Regra 27 (orquestração de equipe)
- `.agents/skills/dual-model-orchestrator/SKILL.md` — skill de orquestração
- `.agents/scripts/acp_redis.py` — biblioteca ACP
- `.agents/scripts/test_acp_multi_agent.py` — teste de comunicação
- `docs/ARCHITECTURE.md` — este documento
