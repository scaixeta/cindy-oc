# ARCHITECTURE

## Proposito

Descrever a arquitetura conceitual do `Cindy OC`, com foco na separacao entre governanca local, superficie de desenvolvimento e camadas externas.

## 1. Visao geral da arquitetura

- Papel do projeto: `Workspace local derivado da Cindy para desenvolvimento assistido`
- Tipo de arquitetura: `Local-first com camadas externas opcionais`
- Escopo arquitetural atual: `Governanca, tracking, runtimes locais, Telegram MVP e OpenClaw Fase 1`
- Limite do modelo atual: `Telegram MVP operacional, n8n-runtime ativo, OpenClaw Fase 1 em preparacao`

## 2. Camadas principais

### 2.1 Governanca

- `Cindy como context router e camada de governanca DOC2.5`

### 2.2 Nucleo funcional

- `VS Code como superficie principal de desenvolvimento local`

### 2.3 Memoria, evidencia ou conhecimento

- `README.md`, tracking, docs canonicos, rules, skills portadas e suite de testes`

### 2.4 Operacao e validacao

- `Codex e Cline como agentes locais com gates do PO e rastreabilidade obrigatoria`

## 3. Componentes principais

- `Sergio` - arquiteto e aprovador final
- `Telegram` - canal de comunicacao MVP integrado (bot operacional em telegram-bot.js com dispatcher)
- `OpenClaw` - camada externa opcional - Fase 1: instalacao, confirmacao, lockdown
- `Cindy` - governanca, contexto e despacho
- `Codex` e `Cline` - agentes locais
- `VS Code` - superficie local
- `Railway` - camada de servicos do MVP ativa
- `n8n-runtime` - instancia n8n em Railway preservada para automacoes futuras
- `Postgres` - database em Railway com volume

## 4. Fluxos principais

### 4.1 Descoberta e planejamento

- `A Cindy le regras, contrato, tracking e skills antes de propor execucao`
- `Mudancas relevantes exigem plano e gate do PO`

### 4.2 Execucao e rastreabilidade

- `Codex e Cline executam localmente no workspace aberto no VS Code`
- `Tudo que foi realmente feito deve ser refletido em Dev_Tracking e bugs_log quando aplicavel`

### 4.3 Validacao e aprendizado

- `Validacoes manuais e estruturais ficam registradas no projeto`
- `Integracoes externas so avancam quando houver aprovacao e evidencia real`

## 5. Fronteiras arquiteturais

- O que faz parte: `Repositorio local, docs, tracking, rules, Telegram MVP, n8n-runtime, OpenClaw Fase 1`
- O que NAO faz parte: `Funcionalidades OpenClaw, ThingsBoard, expansao de permissoes`
- Dependencias externas reais: `Railway com n8n-runtime, Postgres, Telegram MVP`
- Integracoes em lockdown: `OpenClaw Fase 1 - bloqueado por padrao ate validacao`
- Nota: Railway aprovado pelo PO como camada de servicos do MVP

## 6. Evidencias e verdade canonica

- Fontes primarias: `rules/WORKSPACE_RULES.md, Cindy_Contract.md, README.md, Dev_Tracking.md, Dev_Tracking_S2.md`
- Fontes secundarias: `docs canonicos e SKILLS_PORTED`
- Inferencias arquiteturais ativas: `n8n como automacao, OpenClaw Fase 1 em lockdown`
- Decisoes do PO: `MVP com Railway (D-S0-04)`
- Confirmacoes do PO: `Path C:\Cindy-OC e identidade do projeto Cindy OC`

## 7. Decisoes arquiteturais relevantes

- `[ARCH-D-01] O projeto e local-first e nao transfere a fonte de verdade para camadas externas`
- `[ARCH-D-02] OpenClaw nao sobrepoe o tracking DOC2.5`
- `[ARCH-D-03] Railway: MVP com Railway conforme decisao do PO (D-S0-04)`
- `[ARCH-D-04] Telegram integrado ao MVP por long polling com dispatcher (telegram-bot.js)`
- `[ARCH-D-05] OpenClaw Fase 1: lockdown por padrao, permissoes minimas, superficie controlada`

## 8. Postura de seguranca e controle

- **Bloqueado por padrao** (deny-by-default)
- Permissoes minimas
- Features minimas
- Exposição minima
- Mentalidade de allowlist
- Nenhuma superficie aberta alem do necessario

## 9. Relacao com outros artefatos

- `README.md`
- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/OPERATIONS.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S2.md`
- `tests/bugs_log.md`

