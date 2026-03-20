# OPERATIONS

## Proposito

Este documento descreve como o `Cindy OC` deve ser operado no estado atual, preservando DOC2.5 como fonte de verdade local.

## 1. Modelo operacional atual

- Ambiente principal: `Windows + VS Code`
- Modo de operacao: `Local-first com infraestrutura remota`
- Sprint ativa: `S0`
- Escopo operacional aprovado: `Bootstrap local com infraestrutura Railway validada`
- Decisao do PO: `MVP com Railway - ver D-S0-04 em Dev_Tracking_S0.md`
- Infraestrutura ativa: `Railway com n8n-runtime (n8nio/n8n:1.64.0) e Postgres`
- Canal de comunicacao MVP: `Telegram (proxima etapa, ainda nao implantada)`

O projeto opera com base em:

- leitura obrigatoria do contexto antes de agir
- execucao guiada por plano quando aplicavel
- aprovacao do PO para mudancas fora do escopo corrente
- rastreabilidade em `Dev_Tracking`
- registro de validacoes e inconsistencias em `tests/bugs_log.md`

## 2. Read-First

Antes de qualquer execucao, ler na seguinte ordem:

1. `rules/WORKSPACE_RULES.md`
2. regra global do runtime ativo
3. `Cindy_Contract.md`
4. `README.md`
5. `Dev_Tracking.md`
6. `Dev_Tracking_S0.md`
7. apenas os docs canonicos necessarios

## 3. Plan-First

- Planejar antes de executar quando a mudanca alterar estrutura, governanca, processos ou comportamento relevante
- Nao assumir que ausencia de comentario equivale a aprovacao
- Quando houver inferencia, registrar explicitamente como inferencia

## 4. Approval-Gated Execution

- Mudancas fora do escopo ativo exigem aprovacao explicita do PO
- Fechamento de sprint exige comando explicito do PO
- Commit e push exigem comando explicito do PO
- Nenhuma camada externa pode sobrepor o tracking DOC2.5 do repositorio

## 5. Fluxo operacional atual

Fluxo atual:

`Telegram -> Cindy -> Codex/Cline -> consolidacao de resultado -> Telegram`

Condicoes do fluxo atual:

- `Telegram` e o canal de comunicacao MVP priorizado, mas ainda nao implantado
- `OpenClaw` permanece opcional e fora do escopo atual
- `Slack` foi abandonado como canal MVP
- `VS Code` segue como superficie real de execucao local
- `Railway` com n8n-runtime e Postgres esta ativo
- `Dev_Tracking_SX.md` continua sendo a fonte de verdade do que foi feito
- `O fluxo conversacional acima representa a direcao aprovada, nao uma integracao ativa neste momento`

## 6. Evidencias e classificacao

- Evidencia primaria: `regras, contrato, tracking, docs e configuracoes reais do repo`
- Evidencia secundaria: `sumarios e notas operacionais`
- Inferencia: `conclusao derivada ainda nao confirmada pelo PO`
- Pendente de validacao: `Telegram, OpenClaw e qualquer detalhe externo ainda nao implantado`

## 7. Rotinas operacionais

### 7.1 Validacoes manuais minimas

- validar `README.md`
- validar os 4 documentos canonicos em `docs/`
- validar `Dev_Tracking.md` e `Dev_Tracking_S0.md`
- validar `tests/bugs_log.md`

### 7.2 Higiene documental

- manter `README.md` como entry point unico
- nao criar `docs/README.md` ou `docs/INDEX.md`
- atualizar apenas o artefato minimo necessario

## 8. Rotinas de teste

### Testes manuais minimos

- validar estrutura canonica
- validar coerencia entre README, tracking e bugs_log
- validar se o baseline minimo de runtimes e skills foi materializado

### Testes automatizados

- `Pendente de validacao`

## 9. Seguranca operacional

- nunca versionar credenciais
- nunca documentar segredos
- nao presumir acesso a sistemas externos sem prova documental
- manter alteracoes dentro do menor raio de impacto possivel

## 10. Resposta a falhas

1. confirmar contexto da sprint
2. registrar bug ou teste
3. corrigir o artefato minimo necessario
4. atualizar `Timestamp UTC`
5. registrar a decisao ou observacao relevante em `Dev_Tracking`

## 11. Referencias minimas

- `README.md`
- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S0.md`
- `tests/bugs_log.md`
