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

- Fase atual: `Bootstrap local com infraestrutura Railway ativa e n8n validado`
- Sprint ativa: `S0`
- Escopo de desenvolvimento aprovado: `Estrutura inicial, docs canonicos, baseline minimo e MVP com Railway`
- Decisao do PO: `MVP com Railway - ver D-S0-04 em Dev_Tracking_S0.md`
- Fora do escopo atual: `OpenClaw e integracoes externas ainda nao implantadas`
- Infraestrutura ativa: `Railway com n8n-runtime (n8nio/n8n:1.64.0) e Postgres`
- Canal de comunicacao MVP: `Telegram (proxima etapa)`
- Higiene de segredos: `.scr/.env` local, sem credenciais Slack ativas no estado atual

## 3. Roadmap por fases

### 3.1 Fase atual

- `Bootstrap local com infraestrutura minima ativa`
- Objetivo: `Criar o workspace derivado, ativar a infraestrutura minima em Railway e validar o n8n`
- Entregas esperadas: `Docs canonicos, tracking, regras, templates, skills minimas, Railway ativo, Postgres saudavel e n8n validado`
- Limites explicitos: `Sem Telegram implantado, sem OpenClaw ativo e sem automacao conversacional final`

### 3.2 Proxima fase

- `Canal conversacional MVP`
- Objetivo: `Definir e validar Telegram como primeiro canal conversacional do projeto`
- Dependencias para iniciar: `Token do bot, estrategia inicial de long polling ou webhook e aprovacao do PO`

### 3.3 Fases posteriores

- `Integracoes controladas e servicos reais`

## 4. Fluxo de desenvolvimento

### 4.1 Ler contexto

- `rules/WORKSPACE_RULES.md`
- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S0.md`
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

- manter `Dev_Tracking_S0.md` coerente
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

- `Evoluir documentacao, regras e tracking`
- `Adicionar ou ajustar baseline local necessario para o projeto`

## 8. Mudancas explicitamente bloqueadas nesta fase

- `Inventar integracoes prontas com OpenClaw, Telegram ou qualquer servico externo nao validado`
- `Promover infraestrutura externa sem aprovacao`

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
- `Dev_Tracking_S0.md`
- `tests/bugs_log.md`
