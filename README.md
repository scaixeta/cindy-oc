# Cindy Agent

Repositorio-base local da Cindy no workspace `C:\CindyAgent`, usado para manter a governanca DOC2.5, a documentacao canonica, a persona operacional da Cindy no Hermes e os artefatos de referencia que serao replicados para outros projetos do ecossistema.

## Estado atual

- **Sprint ativa:** `S3` — time AIOps multiagente com Microsoft Agent Framework como plataforma de gestao approved
- **Runtime principal:** Hermes em WSL (`Ubuntu`), com runtime vivo em `/root/.hermes`
- **Versao atual do Hermes:** `v0.9.0 (2026.4.13)`
- **Modelo primario do runtime Hermes:** `MiniMax-M2.7` via `minimax`
- **Fallback do runtime Hermes:** `gpt-5.3-codex` via `openai-codex`
- **Canal operacional principal:** Telegram, via `hermes-gateway.service`
- **Healthcheck validado:** `http://127.0.0.1:8642/health`
- **KB canonica da Cindy para Hermes:** `KB/hermes/`
- **Sincronizacao viva do runtime:** `/root/.hermes/SOUL.md`, `/root/.hermes/memories/USER.md`, `/root/.hermes/memories/MEMORY.md`
- **Remote oficial:** `https://github.com/scaixeta/CindyAgent`
- **Branch atual de trabalho:** `v1.1`
- **Segredo local protegido:** `.scr/.env` permanece fora de versionamento

## Sprint S3 — Estado

| Item | Estado |
|---|---|
| Sprint | `S3` |
| Status | Ativa |
| Foco | Materializar o time AIOps multiagente com mesh governado |
| Base operacional validada | Hermes + Telegram + KB canônica + tracking DOC2.5 |

O runtime Hermes foi revalidado em `2026-04-14` e atualizado para `v0.9.0`, mantendo `MiniMax-M2.7` como primario, `gpt-5.3-codex` como fallback, `hermes-gateway.service` ativo e teste local `hermes chat -Q` respondendo `OK`.

## Escopo atual da S3

- materializar o time AIOps multiagente com papeis operacionais claros
- manter Hermes + Telegram como base operacional estavel da Cindy
- preservar a KB canonica e a memoria operacional alinhadas ao runtime vivo
- manter a documentacao DOC2.5 aderente ao estado real do projeto
- registrar bugs, testes e decisoes da sprint ativa com evidencia verificavel

## Visão Operacional AIOps

A Cindy evoluiu de uma assistente reativa para uma **Plataforma AIOps (Autonomous IT Operations)** corporativa, operando sob o framework **DOC 2.5**.

### 1. O que ela faz atualmente
- **Governança Autônoma:** Mantém integridade entre Sprints, documentação canônica (KB) e rastreabilidade técnica (Dev_Tracking) sem intervenção constante.
* **Validação E2E:** Executa suítes de teste (Pytest, Playwright) de forma isolada, diagnostica deadlocks em containers e verifica métricas de saúde sistêmica.
* **Execuções Headless:** Opera via OpenCode com perfis especializados, reduzindo alucinações e isolando acessos em sandboxes seguras.
* **Governança HITL (PO Gates):** Opera autonomamente entre fronteiras de aprovação, escalando para o PO apenas em decisões de arquitetura, custos ou bloqueios críticos.

### 2. O Time AIOps (Multiagente)
A carga operacional é distribuída em uma malha de especialistas (**ACP Mesh**):
- **Cindy (Orquestradora):** Gateway de interface e Context Router macro.
- **Builder (Engenharia):** Implementação de código, refatoração e infraestrutura.
- **Reviewer (Gatekeeper):** Validação técnica, QA e aprovação de handoffs.
- **Documenter (Scribe):** Manutenção silenciosa de docs, memórias e registros de sprint.
- **PlatformOps (SRE):** Observabilidade, diagnóstico de infra e saúde do runtime.

### 3. Como ela opera (Arquitetura)
- **ACP Mesh (Redis):** Protocolo de comunicação assíncrona com máquina de estados (Queued -> Running -> Review -> Done/Escalated).
- **Handoffs Rastreáveis:** Toda troca de responsabilidade entre agentes gera um trace_id persistente para auditoria.
- **Observabilidade:** Monitoramento de throughput, taxa de sucesso e retrabalho (rework) via telemetria no Redis.
- **Isolamento OpenCode:** Ferramentas de sistema são executadas através de perfis com permissões granulares e governadas.

## Operacao rapida

### Subir Hermes + Cindy no Telegram

```powershell
.\start_hermes_cindy_telegram.bat
```

### OpenCode — usar reasoning profundo

```batch
.\run_opencode.bat "prompt aqui"
```

Modelo padrao: `minimax/MiniMax-M2.7`

## Estrutura canonica

- `README.md` — entry point do projeto
- `Dev_Tracking.md` — indice de sprints
- `Dev_Tracking_S3.md` — sprint ativa
- `docs/SETUP.md` — ambiente, instalacao e preparo operacional
- `docs/ARCHITECTURE.md` — arquitetura atual
- `docs/DEVELOPMENT.md` — fluxo de evolucao e backlog
- `docs/OPERATIONS.md` — operacao corrente do runtime Hermes
- `tests/bugs_log.md` — bugs, testes e evidencias
- `KB/` — Base de Conhecimento (aiops, hermes, meta)

## Leitura recomendada

1. `rules/WORKSPACE_RULES.md`
2. `Cindy_Contract.md`
3. `README.md`
4. `docs/SETUP.md`
5. `docs/ARCHITECTURE.md`
6. `docs/DEVELOPMENT.md`
7. `docs/OPERATIONS.md`
8. `Dev_Tracking.md`
9. `Dev_Tracking_S3.md`
10. `KB/aiops/S3_EXECUTION_PLAN.md`

---

## Cindy — Orquestradora (Context Router)

A Cindy é o agente principal do projeto. Em cada run, ela identifica o orchestrator ativo (Cline/Codex/Antigravity), a superfície de execução (VSCode/CLI) e o workspace root; em seguida, descobre e seleciona as skills/workflows disponíveis no contexto atual, respeitando os gates DOC2.5 (plano aprovado antes de execução; commit/push apenas sob ordem explícita do PO).

<p align="center">
  <img src=".brand/Cindy.jpg" alt="Cindy — Orquestradora" width="220" />
</p>
