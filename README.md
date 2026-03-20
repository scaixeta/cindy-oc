# Cindy OC

## Bootstrap Local DOC2.5

Workspace derivado da Cindy para desenvolvimento local em `VS Code`, com `Codex` e `Cline` como agentes locais, `OpenClaw` como camada externa opcional e futura, e baseline minima ja validada para operar com `Railway`, `n8n` e conteineres.

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

- Sprint ativa: `S0`
- Estado da sprint: `Doing`
- Fase atual: `Bootstrap local com infraestrutura Railway ativa e n8n validado`
- Escopo aprovado: `Estrutura canonica, baseline minimo, MVP com Railway e primeira validacao tecnica do n8n`
- Decisao do PO: `MVP com Railway (ver D-S0-04 em Dev_Tracking_S0.md)`
- Estado tecnico validado: `Postgres saudavel, n8n-runtime ativo, dominio publico respondendo e API n8n validada`

## 3. Controle de sprints

| Sprint | Periodo | Estado | Tracking | Observacoes |
| --- | --- | --- | --- | --- |
| `S0` | `2026-03-20` | `Doing` | `Dev_Tracking_S0.md` | Bootstrap inicial com n8n-runtime em Railway |

## 4. Pendencias Ativas

- `Validar quando OpenClaw sera conectado ao fluxo`
- `Integrar Telegram como canal de comunicacao MVP (proxima etapa, ainda nao implementada)`
- `Limpar servico vazio n8n (futuro)`
- `Atualizar a KB e os artefatos canonicos sempre que houver mudanca tecnica relevante`

## 5. Artefatos Canonicos

- `README.md`
- `Cindy_Contract.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S0.md`
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
