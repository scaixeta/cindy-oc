# DEVELOPMENT

## Proposito

Este documento descreve como o `Cindy OC` deve evoluir seguindo DOC2.5, com desenvolvimento local-first e baseline minimo da Cindy.

## 1. Principios de desenvolvimento

- uma sprint ativa por vez
- tracking obrigatorio
- mudanca minima necessaria
- plano antes de execucao quando houver impacto real
- sem estruturas paralelas fora do modelo canonico
- fato, inferencia e pendencia devem permanecer separados

## 2. Estado atual de desenvolvimento

- Fase atual: `OpenClaw Fase 1 - Instalacao, confirmacao, configuracao e lockdown`
- Sprint ativa: `S2`
- Escopo de desenvolvimento aprovado: `Instalacao OpenClaw, confirmacao runtime, configuracao controlada, lockdown`
- Decisao do PO: `MVP com Railway - ver D-S0-04`
- S1 validada: `Telegram MVP, dispatcher, testes E2E 6/6`
- Infraestrutura ativa: `Railway com n8n-runtime e Postgres, Telegram MVP operacional`
- OpenClaw Fase 1: `Bloqueado por padrao, permissoes minimas, superficie controlada`

## 3. Roadmap por fases

### 3.1 Fase atual

- `OpenClaw Fase 1 - Instalacao, confirmacao, configuracao e lockdown`
- Objetivo: `Instalar OpenClaw, confirmar runtime, configurar minima necessidade, bloquear tudo que nao for estritamente necessario`
- Entregas esperadas: `OpenClaw instalado, configuracao minima, baseline de release controlado, checklist operacional`
- Limites explicitos: `Bloqueado por padrao, nenhuma funcionalidade habilitada alem do minimo para confirmacao`

### 3.2 Proxima fase

- `OpenClaw Fase 2 - Funcionalidades controladas`
- Objetivo: `Habilitar funcionalidades OpenClaw de forma controlada apos validacao da Fase 1`
- Dependencias para iniciar: `Conclusao da S2 e nova aprovacao do PO`

## 4. Fluxo de desenvolvimento

### 4.1 Ler contexto

- `rules/WORKSPACE_RULES.md`
- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S2.md`
- apenas os docs canonicos necessarios

### 4.2 Planejar

- resumir entendimento
- propor plano
- explicitar o que esta confirmado, inferido e pendente
- aguardar aprovacao explicita do PO quando a mudanca extrapolar o escopo corrente ou alterar a estrutura

### 4.3 Executar

- atualizar backlog em tabela `Status | Estoria`
- registrar decisoes como `[D-SX-YY] - descricao`
- referenciar bugs e testes em `tests/bugs_log.md`
- aplicar a menor mudanca necessaria para atingir o objetivo

### 4.4 Atualizar rastreabilidade

- manter `Dev_Tracking_S2.md` coerente
- atualizar `Dev_Tracking.md` quando necessario
- sincronizar docs canonicos se a realidade do projeto mudou

## 5. Pack minimo da Cindy adotado

O projeto porta o minimo util destes blocos:

- governanca DOC2.5: `rules/`, `Cindy_Contract.md`, tracking e docs
- runtime Codex: `.codex/rules` e `.codex/skills` selecionadas
- runtime Cline: `.clinerules/`, `.cline/skills` selecionadas
- source of truth portado: `.agents/rules` e `.agents/skills` selecionadas
- templates locais: `Templates/`

## 6. Portabilidade entre runtimes

- `.agents/skills/` permanece como fonte portavel
- `.cline/skills/` e `.codex/skills/` funcionam como counterparts locais
- `.clinerules/workflows/` preserva os fluxos DOC2.5 necessarios para bootstrap, docs, dev e commit
- O conjunto de skills foi minimizado para governanca, Railway, n8n, Docker e operacao local

## 7. Mudancas permitidas na fase atual

- `Instalar e configurar OpenClaw (S2)`
- `Confirmar startup e saude operacional`
- `Aplicar configuracao minima`
- `Bloquear capacidades nao essenciais`
- `Documentar baseline de release`
- `Evoluir documentacao e tracking`

## 8. Mudancas explicitamente bloqueadas nesta fase

- `Habilitar funcionalidades OpenClaw alem do minimo`
- `Expansao de permissoes`
- `Integracoes externas nao validadas`
- `Promover infraestrutura sem aprovacao`
- `Executar Fase 2`

## 9. Tests e bugs

- log centralizado em `tests/bugs_log.md`
- `Timestamp UTC` nas tabelas de tracking
- quando nao houver automacao, registrar a validacao manual realmente executada

## 10. Referencias minimas

- `README.md`
- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/OPERATIONS.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S2.md`
- `tests/bugs_log.md`

