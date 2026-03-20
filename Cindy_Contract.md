# Contrato Cindy Context Router (DOC2.5)

## 1. Contexto de Runtime

Este contrato define o contexto discoverable da Cindy no inicio de cada run do `Cindy OC`.

| Componente | Valor | Fonte de Verdade |
|---|---|---|
| `orchestrator` | `auto-detect` | Estrutura do workspace |
| `execution_surface` | `vscode` / `cli` | Ambiente de execucao |
| `workspace_root` | `C:\Cindy-OC` | CWD / caminho aprovado pelo PO |
| `doutrina` | `DOC2.5` | `rules/WORKSPACE_RULES.md` |

## 2. Orquestradores Validos

| Orchestrator | Entry Point | Rules | Skills |
|---|---|---|---|
| `codex` | `.codex/` | `.codex/rules/WORKSPACE_RULES_GLOBAL.md` | `.codex/skills/` |
| `cline` | `.clinerules/` | `.clinerules/WORKSPACE_RULES_GLOBAL.md` | `.cline/skills/` |
| `antigravity` | `.agents/` | `.agents/rules/WORKSPACE_RULES.md` | `.agents/skills/` |

Notas operacionais:

- `.clinerules/` e `.cline/` possuem papeis diferentes e complementares no runtime Cline
- `.agents/skills/` permanece a canonical authoring source of truth das skills comuns
- `rules/WORKSPACE_RULES.md` prevalece sobre este contrato quando houver conflito

## 3. Registro de Skills

Prioridade de consulta:

1. `.agents/skills/`
2. `.clinerules/workflows/`
3. `.cline/skills/`
4. `.codex/skills/`

O baseline portado neste projeto foi reduzido ao minimo util para:

- bootstrap e governanca DOC2.5
- operacao local com Codex e Cline
- estudos e fluxos futuros com Railway
- trabalho futuro com n8n
- suporte futuro a Docker e contêineres

## 4. Gates Obrigatorios

| Gate | Quando | Regra |
|---|---|---|
| Aprovacao de Plano | Antes de executar mudanca relevante | Plano aprovado pelo PO |
| Confirmacao de Escrita | Antes de alterar arquivos fora do escopo corrente | Planejamento e aprovacao |
| Commit/Push | Antes de `git commit`/`git push` | Ordem expressa do PO |

## 5. Contrato de Descoberta

Fluxo minimo:

1. Ler `rules/WORKSPACE_RULES.md`
2. Identificar orchestrator e superficie de execucao
3. Ler a regra global do runtime ativo
4. Classificar o workspace
5. Consultar registry de skills
6. Validar gates obrigatorios
7. Propor plano ao PO quando aplicavel

## 6. Limites do Projeto Derivado

- `Cindy OC` nao e o repositorio canonico da Cindy
- `OpenClaw` permanece externo e opcional por padrao
- `Slack`, `Railway`, `n8n`, `ThingsBoard` e outros sistemas externos so podem ser promovidos a verdade canonica quando houver evidencia ou aprovacao explicita do PO

Versao: 1.0
Template: Derivado
Doutrina: DOC2.5
