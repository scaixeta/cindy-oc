# DEVELOPMENT.md — Desenvolvimento

## Visão Geral

Este documento cobre o fluxo de desenvolvimento e práticas para Cindy Agent.

## Fluxo DOC2.5

```
1. Pedido → Análise
2. Classificar workspace (repo materializado / baseline de geração)
3. Ler contexto mínimo
4. Propor plano ao PO
5. Aprovação do PO
6. Execução com rastreabilidade
7. Validação e documentação
```

## Gates Obrigatórios

| Gate | Quando |
|------|--------|
| Aprovação de Plano | Antes de executar |
| Confirmação de Escrita | Antes de alterar arquivos |
| Commit/Push | Apenas sob ordem expressa do PO |

## Rastreabilidade

Toda alteração deve registrar:

- Timestamp UTC (formato: `YYYY-MM-DDTHH:MM:SS-ST`)
- Evento em `Dev_Tracking_SX.md`
- Log em `tests/bugs_log.md` quando aplicável

## Skills

Skills disponíveis em `.agents/skills/`:

| Skill | Descrição |
|-------|-----------|
| `autoresearch` | Pesquisa automática |
| `backend-feature-orchestrator-doc25` | Orquestrador de features |
| `central-station` | Configuração centralizada |
| `container-debugging` | Debug de containers |
| `database` | Operações de banco de dados |
| `create_code_structure` | Criação de estrutura de código |
| `crisp-dm-workflow-doc25` | Workflow CRISP-DM |

## GSD Framework

Framework Get Shit Done para execução técnica:

```powershell
/gsd:new-project   # Novo projeto
/gsd:plan-phase    # Planejar fase
/gsd:execute-phase # Executar fase
/gsd:quick         # Execução rápida
```

## Política Git

- `git status` — leitura permitida
- `git commit` / `git push` — apenas sob ordem expressa do PO
- Nunca usar `git diff` por padrão

## Qualidade

- Avaliação interna mínima: 80/100
- Budget contextual: até 30%

## Pendente de Validação

| Item | Status |
|------|--------|
| Stack de desenvolvimento completa | Pendente |
| Procedures de build/test | Pendente |

## Referência

Consulte [SETUP.md](SETUP.md) para configuração inicial.
