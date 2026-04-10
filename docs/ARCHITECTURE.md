# ARCHITECTURE.md — Arquitetura

## Visão Geral

Cindy Agent é um orquestrador de agentes AI construído sobre o framework Hermes, com governança DOC2.5.

## Arquitetura de Alto Nível

```
┌─────────────────────────────────────────────┐
│              Cindy Agent                     │
│  (Orquestrador + Governança DOC2.5)          │
└─────────────────┬───────────────────────────┘
                  │
        ┌─────────┴──────────┐
        │                      │
   ┌────▼────┐           ┌───▼────┐
   │ Hermes  │           │ Telegram│
   │ (Motor  │           │ (Canal  │
   │   IA)   │           │  Comum) │
   └─────────┘           └─────────┘
```

## Componentes

### Hermes Framework

Motor de IA que orchestru:

- Execução de agentes (Cline, Codex, Antigravity)
- Gerenciamento de contexto e memória
- Integração com tools e skills

### Cindy (Orquestradora)

- Identifica runtime ativo (Cline/Codex/Antigravity)
- Seleciona skills/workflows conforme contexto
- Aplica gates DOC2.5

### Telegram

Canal de comunicação para interação com o agente.

## Runtimes Suportados

| Runtime | Entry Point | Skills |
|---------|-------------|--------|
| Cline | `.clinerules/` | `.cline/skills/` |
| Codex | `.codex/` | `.codex/skills/` |
| Antigravity | `.agents/` | `.agents/skills/` |

## Estrutura de Diretórios

```
cindyagent/
├── .agents/          # Skills canônicas + GSD
├── .cline/           # Runtime Cline
├── .clinerules/      # Workflows DOC2.5
├── .codex/           # Runtime Codex
├── rules/            # Regras operacionais
├── docs/             # Documentação canônica
└── Sprint/           # Sprints encerradas
```

## Fluxo de Execução

1. Mensagem via Telegram
2. Hermes processa e roteia
3. Cindy identifica contexto (runtime, workspace)
4. Skill/workflow correto é selecionado
5. Execução com gates DOC2.5
6. Resposta via Telegram

## Pendente de Validação

| Item | Status |
|------|--------|
| Topologia detalhada de serviços | Pendente |
| Fluxo de dados completo | Pendente |

## Referência

Consulte [DEVELOPMENT.md](DEVELOPMENT.md) para detalhes de implementação.
