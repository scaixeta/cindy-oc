# Cindy Agent

Orquestrador de agentes AI baseado no framework Hermes, com governança DOC2.5.

## Sprint Ativa

**S1** — Configuração inicial do ambiente e documentação

## Escopo

- Configuração do Hermes CLI
- Integração Telegram
- Documentação DOC2.5

## Links

- [Setup](docs/SETUP.md)
- [Arquitetura](docs/ARCHITECTURE.md)
- [Desenvolvimento](docs/DEVELOPMENT.md)
- [Operações](docs/OPERATIONS.md)
- [Tracking](Dev_Tracking_S1.md)

---

## Cindy — Orquestradora (Context Router)

A Cindy é o agente principal do projeto. Em cada run, ela identifica o orchestrator ativo (Cline/Codex/Antigravity), a superfície de execução (VSCode/CLI) e o workspace root; em seguida, descobre e seleciona as skills/workflows disponíveis no contexto atual, respeitando os gates DOC2.5 (plano aprovado antes de execução; commit/push apenas sob ordem explícita do PO).

<p align="center">
  <img src=".brand/Cindy.jpg" alt="Cindy — Orquestradora" width="220" />
</p>
