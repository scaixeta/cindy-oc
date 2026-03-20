# Dev_Tracking - Indice de Sprints

## Projeto

- Nome: `Cindy OC`
- Objetivo: `Bootstrapar um workspace derivado da Cindy para desenvolvimento local governado por DOC2.5`
- Fase atual: `Bootstrap local com infraestrutura Railway ativa e n8n validado`
- Escopo aprovado: `Estrutura canonica, baseline minimo, decisao MVP com Railway e primeira validacao tecnica do n8n`

## Sprint Ativa

- **`S0`** - `Doing`

## Lista de Sprints

| Sprint | Periodo | Estado | Link |
|---|---|---|---|
| `S0` | `2026-03-20` | `Doing` | `Dev_Tracking_S0.md` |

## Registros

- `2026-03-20T17:58:54-ST` - `Sprint S0 aberta para bootstrap inicial do projeto`
- `2026-03-20T18:37:30-FN` - `Decisao do PO registrada: MVP com Railway (D-S0-04)`
- `2026-03-20T19:18:30-FN` - `KB portavel registrada com padroes genericos de comunicacao entre Railway, n8n e outros servidores`
- `2026-03-20T20:24:30-FN` - `KB registrada com procedimento validado de login Railway`
- `2026-03-20T21:18:30-FN` - `Primeira instancia funcional de n8n em Railway validada via imagem fixa e Postgres`
- `2026-03-20T21:40:00-FN` - `Dominio public Railway gerado para n8n-runtime (n8n-runtime-production.up.railway.app)`
- `2026-03-20T21:50:00-FN` - `API n8n validada com sucesso (/api/v1/workflows retorna 200)`
- `2026-03-20T22:00:00-FN` - `Slack abandonado como canal MVP; Telegram definido como proximo canal de comunicacao`
- `2026-03-20T22:05:05-FN` - `Documentacao canonica e KB reconciliadas com o estado real da infraestrutura ativa`

## Observacoes

- Sprints encerradas devem ser movidas para `Sprint/Dev_Tracking_SX.md`
- O arquivo ativo permanece na raiz (`Dev_Tracking_SX.md`)
- Manter este indice sincronizado com `README.md` e `tests/bugs_log.md`
- Manter apenas uma sprint ativa por vez
- Registrar aqui apenas mudancas de estado, marcos relevantes e correcoes estruturais do projeto

## Regras de atualizacao

- Atualizar este indice quando a sprint ativa mudar de estado
- Atualizar este indice quando uma nova sprint for aberta
- Atualizar este indice quando houver correcao estrutural relevante no projeto
- Nao duplicar aqui o backlog detalhado da sprint

---

## Timestamp UTC

Usar formato DOC2.5 (ISO 8601, 24h): `YYYY-MM-DDTHH:MM:SS-ST` para inicio e `YYYY-MM-DDTHH:MM:SS-FN` para fim.

Event | Start | Finish | Status
---|---|---|---
`S0` | `2026-03-20T17:58:54-ST` |  | `Doing`
