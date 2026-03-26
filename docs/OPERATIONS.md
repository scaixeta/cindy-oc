# OPERATIONS

## Proposito

Este documento descreve como o `Cindy OC` deve ser operado no estado atual, preservando DOC2.5 como fonte de verdade local.

## 1. Modelo operacional atual

- Ambiente principal: `Windows + VS Code`
- Modo de operacao: `Local-first com infraestrutura remota`
- Sprint ativa: `S2`
- Escopo operacional aprovado: `OpenClaw Fase 1 - Instalacao, confirmacao, configuracao e lockdown`
- S1 validada: `Telegram MVP, dispatcher, testes E2E 6/6`
- Infraestrutura ativa: `Railway com n8n-runtime e Postgres, Telegram MVP operacional`
- OpenClaw: `Fase 1 em preparacao - lockdown por padrao`

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
6. `Dev_Tracking_S2.md`
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

## 5. Fluxo operacional atual (S1 validado)

Fluxo validado na S1:

`Telegram -> Cindy -> resposta direta ou n8n-runtime via webhook -> Telegram`

Condicoes do fluxo (S1):

- `Telegram` integrado via long polling com dispatcher
- `Mensagens com prefixo n8n:` aciona webhook `cindy-telegram` no `n8n-runtime` ✅
- Suite de testes 6/6 validada

## 6. Evidencias e classificacao

- Evidencia primaria: `regras, contrato, tracking, docs e configuracoes reais do repo`
- Evidencia secundaria: `sumarios e notas operacionais`
- Inferencia: `conclusao derivada ainda nao confirmada pelo PO`
- OpenClaw Fase 1: `Em execucao (S2) - lockdown por padrao`

## 7. Rotinas operacionais

### 7.1 Validacoes manuais minimas

- validar `README.md`
- validar os 4 documentos canonicos em `docs/`
- validar `Dev_Tracking.md` e `Dev_Tracking_S2.md`
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

- `test-automation.js` - suite de testes E2E Telegram/n8n

## 9. Seguranca operacional

- nunca versionar credenciais
- nunca documentar segredos
- nao presumir acesso a sistemas externos sem prova documental
- manter alteracoes dentro do menor raio de impacto possivel
- **OpenClaw Fase 1**: bloqueado por padrao, permissoes minimas

## 10. Resposta a falhas

1. confirmar contexto da sprint
2. registrar bug ou teste em `tests/bugs_log.md`
3. corrigir o artefato minimo necessario
4. atualizar `Timestamp UTC`
5. registrar a decisao ou observacao relevante em `Dev_Tracking`

## 11. Contrato Minimo de Mensagens (MVP - S1)

### 11.0 Status de Implementacao

| Componente | Status | Observacao |
|---|---|---|
| Long polling via getUpdates | ✅ Implementado | Loop ativo em telegram-bot.js |
| Resposta direta (/start, oi, texto) | ✅ Implementado | Funcao sendMessage ativa |
| Roteamento n8n: | ✅ Implementado | Timeout 10s, webhook `cindy-telegram` |
| Validacao E2E (n8n:) | ✅ Passado | TEST-S1-06: 6/6 testes passaram |
| Dispatcher | ✅ Implementado | routeMessage + handleFallback |
| Fallback operacional | ✅ Implementado | Erros e timeouts controlados |

## 12. Rotina Operacional Minima (S1 validada)

### 12.1 Check de Startup

Ao iniciar `telegram-bot.js`:
```
========================================
Cindy OC - Telegram Bot MVP
[INIT] Token loaded: YES
[INIT] n8n URL: https://n8n-runtime-production.up.railway.app
[INIT] n8n webhook path: cindy-telegram
[STATUS] Bot ready and listening...
```

### 12.2 Observabilidade em Runtime

Logs gerados durante execucao:
- `[INCOMING] <texto>` - mensagem recebida
- `[TYPE] <direct|n8n|openclaw>` - tipo de roteamento
- `[OUTGOING N8N] <resposta>` - resposta do n8n
- `[OUTGOING DIRECT] <resposta>` - resposta direta
- `[OUTGOING FALLBACK] <mensagem>` - fallback acionado
- `[STATS] Messages: X, Errors: Y` - contadores de runtime

## 13. Estado do Servico n8n (S1)

O servico n8n em Railway:
- Provisionado e ativo em `n8n-runtime-production.up.railway.app`
- Webhook `cindy-telegram` ativo e respondendo
- Em estado de espera para futuras automacoes

## 14. OpenClaw Fase 1 - Regras Operacionais (S2)

### 14.1 Escopo da Fase 1

- Instalacao do OpenClaw
- Confirmacao de startup e saude operacional minima
- Configuracao minima necessaria para operacao controlada
- Lockdown: bloqueado por padrao, liberar apenas o estritamente necessario

### 14.2 Postura de Seguranca

- **Bloqueado por padrao** (deny-by-default)
- Permissoes minimas
- Features minimas
- Exposição minima
- Mentalidade de allowlist
- Nenhuma superficie aberta alem do necessario

### 14.3 Fluxo de Trabalho S2

1. **Preparar** - ST-S2-01: Verificar pre-requisitos workspace
2. **Instalar** - ST-S2-02: Instalar OpenClaw no caminho local aprovado
3. **Confirmar** - ST-S2-03: Validar startup e saude operacional
4. **Configurar** - ST-S2-04: Aplicar configuracao minima
5. **Bloquear** - ST-S2-05: Desabilitar capacidades nao essenciais
6. **Baseline** - ST-S2-06: Definir baseline de release controlado
7. **Checklist** - ST-S2-07: Registrar checklist operacional
8. **Aceite** - ST-S2-08: Definir criterios de aceite

### 14.4 Critérios de Bloqueio

Sempre que uma funcionalidade nao estiver explicitamente validada para a Fase 1:
- Bloquear por padrao
- Registrar como pendente
- Nao habilitar ate aprovacao explicita do PO

### 14.5 Fora do Escopo (ate validacao S2)

- Funcionalidades OpenClaw alem do minimo
- Expansao de permissoes
- Integracoes externas
- Fase 2

## 16. Guia de Integracao MiniMax M2.5 no AI Agent do n8n

### Passo 1 — Configurar credencial no n8n

No n8n, ir em **Credentials → New → OpenAI API**.

| Campo | Valor |
|---|---|
| **API Key** | sua chave MiniMax |
| **Base URL** | `https://api.minimax.io/v1` |

### Passo 2 — Adicionar o no de modelo no AI Agent

No no **AI Agent**, adicionar um sub-no do tipo **OpenAI Chat Model**.
Selecionar a credencial criada e no campo **Model**, digitar manualmente: `MiniMax-M2.5`.

### Passo 3 — Conectar e testar

- Conectar o **Chat Model** ao ponto `model` do AI Agent.
- Adicionar um **Chat Trigger** como input.
- Validar se o `Base URL` termina em `/v1` e o modelo e exatamente `MiniMax-M2.5`.

## 17. Referencias minimas

- `README.md`
- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S2.md`
- `tests/bugs_log.md`

