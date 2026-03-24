# Dev_Tracking - Sprint S2 (Cindy OC)

## 1. Identificacao da Sprint

- Sprint: `S2`
- Projeto: `Cindy OC`
- Periodo: `2026-03-24`
- Escopo aprovado: `OpenClaw Fase 1 - Instalacao, confirmacao, configuracao e lockdown`
- Contexto inicial:
  - `Telegram MVP operacional com dispatcher explicito`
  - `n8n-runtime ativo e preservado`
  - `OpenClaw preparado para integracao`
  - `S1 encerrada com suite de testes 6/6`

## 2. Objetivos da Sprint

- `[OBJ-S2-01] Preparar workspace e pre-requisitos para instalacao do OpenClaw`
- `[OBJ-S2-02] Instalar OpenClaw no caminho local aprovado`
- `[OBJ-S2-03] Confirmar startup e saude operacional minima`
- `[OBJ-S2-04] Aplicar configuracao minima necessaria para operacao controlada`
- `[OBJ-S2-05] Bloquear capacidades nao-essenciais por padrao`

## 3. Backlog da Sprint (STATUS | ESTORIA)

| Status | Estoria |
|---|---|
| To-Do | `ST-S2-01 - Preparar workspace e pre-requisitos runtime para instalacao OpenClaw` |
| To-Do | `ST-S2-02 - Instalar OpenClaw no caminho local aprovado` |
| To-Do | `ST-S2-03 - Confirmar startup e saude operacional minima do OpenClaw` |
| To-Do | `ST-S2-04 - Aplicar configuracao minima necessaria para operacao controlada` |
| To-Do | `ST-S2-05 - Bloquear capacidades nao-essenciais por padrao e liberar apenas o estritamente necessario` |
| To-Do | `ST-S2-06 - Definir e validar baseline de release controlado para futuras habilitacoes` |
| To-Do | `ST-S2-07 - Registrar checklist operacional para OpenClaw fase 1` |
| To-Do | `ST-S2-08 - Definir criterios de aceite para considerar OpenClaw fase 1 completo` |

Estados possiveis:
- `To-Do`, `Doing`, `Done`, `Accepted`, `Pending-SX`

## 4. Escopo

### Em escopo (Fase 1)
- Instalacao do OpenClaw
- Confirmacao de runtime e startup
- Configuracao minima necessaria
- Lockdown: bloqueado por padrao, liberar apenas o estritamente necessario

### Fora de escopo
- Funcionalidades OpenClaw (ate que Fase 1 esteja validada)
- Novas integracoes
- Expansao de permissoes
- Fase 2

## 5. Postura de Seguranca e Controle

- **Bloqueado por padrao** (deny-by-default)
- Permissoes minimas
- Features minimas
- Exposição minima
- Mentalidade de allowlist
- Nenhuma superficie aberta alem do necessario para confirmacao e configuracao controlada

## 6. Politica de Commits e Testes (DOC2.5)

### Politica de Commits

- Nenhum `git commit` ou `git push` sem autorizacao explicita do PO
- `Dev_Tracking_S2.md` e gate obrigatorio de rastreabilidade
- Fechamento de sprint so ocorre sob comando explicito do PO

### Requisitos de Teste

- Validacoes manuais devem ser registradas
- O resumo desta sprint deve permanecer coerente com `README.md`, `Dev_Tracking.md` e `tests/bugs_log.md`

## 7. Estado da Sprint

Preencher ao encerrar a sprint `S2`.

- Itens concluidos: `Pendente de validacao`
- Itens pendentes e realocados: `Pendente de validacao`
- Observacoes finais: `Sprint ativa`

## 8. Referencia de Fechamento da Sprint

- `S2-END: Pendente de validacao`

---

## 9. Execucoes de Atualizacao n8n (Fora do Escopo S2)

| Timestamp | Acao | Resultado |
|---|---|---|
| `2026-03-23T23:42:00-FN` | `Atualizar n8n para latest via n8n-runtime-v2` | `n8n 2.12.3 ativo, migrations OK, workflow "Cindy Telegram Router" ativado` |
| `2026-03-23T23:42:30-FN` | `Dominio temporario n8n-runtime-v2-production.up.railway.app` | `Servico disponivel,health validado` |

**Nota**: A execucao foi necessaria para garantir baseline atualizado antes de qualquer trabalho com OpenClaw. O servico original `n8n-runtime` permanece em 1.64.0 ate decisao do PO sobre swap de dominio.

---

## 10. Execucoes de MCP Search (S2)

| Timestamp | Acao | Resultado |
|---|---|---|
| `2026-03-24T00:55:00-FN` | `Atualizar cline_mcp_settings.json - desabilitar MiniMax e n8n-mcp local, adicionar Google Search MCP` | `MiniMax: disabled=true (API key invalida), n8n-mcp local: disabled=true (endpoint nao existe), Google Search MCP: adicionado (@gpriday/ask-google-mcp)` |
| `2026-03-24T00:55:30-FN` | `Mover .env-n8n-vars para .scr/` | `Arquivo movido para SOT de credenciais` |

**Nota**: O Google Search MCP usa `@gpriday/ask-google-mcp` com Gemini Search Grounding. O n8n Docs MCP Official permanece ativo via `https://n8n.mcp.kapa.ai/`.

---

## 11. Bug Registrado

| ID | Descricao | Status |
|---|---|---|
| `BUG-S2-01` | `MiniMax MCP apresenta erro "invalid api key" (2049)` | `Aguardando correcao upstream ou nova API key` |
| `BUG-S2-02` | `n8n-mcp local: endpoint /mcp nao existe no servidor` | `Desabilitado temporariamente` |

**Workaround**: Usar Google Search MCP e n8n Docs MCP Official como alternativas temporarias.


