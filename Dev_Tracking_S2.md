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
| Doing | `ST-S2-01 - Preparar workspace e pre-requisitos runtime para instalacao OpenClaw` |
| Doing | `ST-S2-02 - Instalar OpenClaw no caminho local aprovado` |
| Doing | `ST-S2-03 - Confirmar startup e saude operacional minima do OpenClaw` |
| To-Do | `ST-S2-04 - Aplicar configuracao minima necessaria para operacao controlada` |
| To-Do | `ST-S2-05 - Bloquear capacidades nao-essenciais por padrao e liberar apenas o estritamente necessario` |
| To-Do | `ST-S2-06 - Definir e validar baseline de release controlado para futuras habilitacoes` |
| To-Do | `ST-S2-07 - Registrar checklist operacional para OpenClaw fase 1` |
| To-Do | `ST-S2-08 - Definir criterios de aceite para considerar OpenClaw fase 1 completo` |
| Doing | `ST-S2-09 - Projetar Dockerfile customizado para NemoClaw em ambiente PaaS (Railway)` |
| To-Do | `ST-S2-10 - Configurar entrypoint.sh para automação de startup no container` |
| To-Do | `ST-S2-11 - Criar guia canônico de deploy Railway na KB` |

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

## 8. Timestamp UTC [Regra 7]

| Event | Start | Finish | Status |
|---|---|---|---|
| S2-INIT | 2026-03-27T18:10:00-ST | | In-Progress |
| NEMOCLAW-PLAN | 2026-03-27T18:10:05-ST | 2026-03-27T18:11:00-FN | Done |
| NEMOCLAW-EXEC | 2026-03-27T18:12:00-ST | 2026-03-27T18:15:00-FN | Done |

## 9. Referencia de Fechamento da Sprint

- `S2-END: Pendente de validacao`


