# Cindy OC

## Operacao DOC2.5

Workspace derivado da Cindy para desenvolvimento local em `VS Code`, com `Codex` e `Cline` como agentes locais, `OpenClaw` como camada externa opcional e futura, e baseline minima validada para operar com `Railway`, `n8n`, `Postgres` e Telegram.

---

## 1. Visao geral

O `Cindy OC` e o repositorio raiz para:

- governanca, contexto e despacho via Cindy
- desenvolvimento local assistido no `VS Code`
- manter a governanca local e a rastreabilidade enquanto a infraestrutura remota evolui
- apoiar a operacao validada de `Railway`, `n8n` e `Postgres`

Objetivos principais:

- materializar a estrutura canonica DOC2.5 do projeto derivado
- portar o baseline minimo da Cindy necessario para operacao local
- deixar o workspace pronto para evolucao controlada, sem presumir integracoes ainda nao implantadas

## 2. Estado atual

- Sprint ativa: `S2`
- Estado da sprint: `Doing`
- Fase atual: `OpenClaw Fase 1 - Instalacao, confirmacao, configuracao e lockdown`
- Escopo aprovado: `Instalacao OpenClaw, confirmacao runtime, configuracao controlada, lockdown`
- Estado tecnico validado: `Postgres saudavel, n8n-runtime ativo, Telegram MVP operacional com dispatcher, suite de testes 6/6`

## 3. Controle de sprints

| Sprint | Periodo | Estado | Tracking | Observacoes |
| --- | --- | --- | --- | --- |
| `S2` | `2026-03-24` | `Doing` | `Dev_Tracking_S2.md` | OpenClaw Fase 1: instalacao, confirmacao, lockdown |
| `S1` | `2026-03-23` | `Accepted` | `Sprint/Dev_Tracking_S1.md` | Telegram MVP, dispatcher, testes E2E 6/6 |
| `S0` | `2026-03-20` | `Accepted` | `Sprint/Dev_Tracking_S0.md` | Bootstrap, Railway, n8n validados |

## 4. Pendencias Ativas

- `ST-S2-01 a ST-S2-08 - OpenClaw Fase 1: preparacao, instalacao, confirmacao, configuracao, lockdown, baseline, checklist, aceite`

## 5. Artefatos Canonicos

- `README.md`
- `Cindy_Contract.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S2.md`
- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/OPERATIONS.md`
- `tests/bugs_log.md`


## Cindy — Orquestradora (Context Router)

A Cindy é o agente principal do projeto. Em cada run, ela identifica o orchestrator ativo (Cline/Codex/Antigravity), a superfície de execução (VSCode/CLI) e o workspace root; em seguida, descobre e seleciona as skills/workflows disponíveis no contexto atual, respeitando os gates DOC2.5 (plano aprovado antes de execução; commit/push apenas sob ordem explícita do PO).

<p align="center">
  <img src=".brand/Cindy.jpg" alt="Cindy — Orquestradora" width="220" />
</p>
