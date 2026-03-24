# OPERATIONS

## Proposito

Este documento descreve como o `Cindy OC` deve ser operado no estado atual, preservando DOC2.5 como fonte de verdade local.

## 1. Modelo operacional atual

- Ambiente principal: `Windows + VS Code`
- Modo de operacao: `Local-first com infraestrutura remota`
- Sprint ativa: `S1`
- Escopo operacional aprovado: `Telegram MVP operacional, consolidacao do contrato de mensagens e limpeza tecnica da infraestrutura minima`
- Decisao do PO: `MVP com Railway - ver D-S0-04 em Dev_Tracking_S0.md`
- Infraestrutura ativa: `Railway com n8n-runtime (n8nio/n8n:1.64.0) e Postgres`
- Canal de comunicacao MVP: `Telegram integrado (bot operacional em telegram-bot.js)`

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
6. `Dev_Tracking_S1.md`
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

`Telegram -> Cindy -> resposta direta ou n8n-runtime via webhook -> Telegram`

Condicoes do fluxo atual:

- `Telegram` integrado via long polling loop operacional em telegram-bot.js
- `Mensagens com prefixo n8n:` ja podem acionar o webhook `cindy-telegram` no `n8n-runtime`
- `OpenClaw` permanece opcional e fora do escopo atual
- `Slack` foi abandonado como canal MVP
- `VS Code` segue como superficie real de execucao local
- `Railway` com n8n-runtime e Postgres esta ativo
- `Dev_Tracking_SX.md` continua sendo a fonte de verdade do que foi feito
- `O fluxo conversacional acima ja possui um loop MVP funcional e agora entra em fase de consolidacao operacional`

## 6. Evidencias e classificacao

- Evidencia primaria: `regras, contrato, tracking, docs e configuracoes reais do repo`
- Evidencia secundaria: `sumarios e notas operacionais`
- Inferencia: `conclusao derivada ainda nao confirmada pelo PO`
- Pendente de validacao: `OpenClaw, webhook opcional do Telegram e qualquer detalhe externo ainda nao implantado`

## 7. Rotinas operacionais

### 7.1 Validacoes manuais minimas

- validar `README.md`
- validar os 4 documentos canonicos em `docs/`
- validar `Dev_Tracking.md` e `Dev_Tracking_S1.md`
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

## 11. Contrato Minimo de Mensagens (MVP)

### 11.0 Status de Implementacao

| Componente | Status | Observacao |
|---|---|---|
| Long polling via getUpdates | ✅ Implementado | Loop ativo em telegram-bot.js |
| Resposta direta (/start, oi, texto) | ✅ Implementado | Funcao sendMessage ativa com saudacao atualizada |
| Roteamento n8n: | ✅ Implementado | Funcao callN8n ativa com timeout 10s e webhook `cindy-telegram` validado |
| Validacao E2E (n8n:) | ✅ Passado | TEST-S1-03: Telegram->bot->n8n->Telegram concluido |
| Webhook Telegram | ❌ Nao implementado | Long polling suficiente |
| OpenClaw | ❌ Fora do escopo | Diferido |

### 11.1 Entrada do Telegram

```json
{
  "message_id": 1,
  "chat": { "id": 8687754084, "type": "private" },
  "text": "/start",
  "date": 1774309008
}
```

Campos relevantes para roteamento:
- `text`: conteúdo da mensagem
- `chat.id`: chat_id do remetente
- `command marker`: prefixo `/` indica comando

### 11.2 Classificacao Cindy

| Tipo de entrada | Acao |
|---|---|
| `/start` | Resposta direta de Boas-vindas |
| `oi` / `olá` | Resposta direta de saudacao |
| `n8n:` prefixo | Encaminhar para n8n-runtime |
| Demais texto | Resposta direta generica |

### 11.3 Contracto n8n (quando acionado)

- **Quando chamar**: apenas quando a mensagem iniciar com `n8n:`
- **Endpoint atual**: `POST {N8N_URL}/webhook/{N8N_WEBHOOK_PATH}` com `N8N_WEBHOOK_PATH=cindy-telegram`
- **Payload enviado para n8n**:
```json
{
  "chat_id": 8687754084,
  "text": "mensagem original após n8n:",
  "source": "telegram",
  "timestamp": "ISO-8601"
}
```
- **Resposta esperada do n8n**: texto simples para reply
- **Timeout**: 10 segundos, fallback para "Servico temporariamente indisponivel"
- **Fora do escopo**: memoria, contexto complexo, orquestracao multi-step

### 11.4 Resposta para Telegram

| Cenário | Mensagem |
|---|---|
| Sucesso n8n | Resposta retornada pelo n8n |
| Timeout n8n | "Servico temporariamente indisponivel" |
| Comando invalido | "Desculpe, nao entendi. Use /start para comecar." |
| Comando /start | "Olá, sou a Cindy uma IA da Sentivis. Posso te ajudar?" |
| Saudação oi/olá | "Olá, sou a Cindy uma IA da Sentivis. Posso te ajudar?" |
| Texto generico | "Mensagem recebida: {texto}" |

### 11.5 Fora do Escopo

- OpenClaw na interface
- Multicanal (Slack, WhatsApp, etc)
- Memoria persitente de conversa
- Workflows complexos no n8n
- Autenticacao avancada

## 12. Referencias minimas

- `README.md`
- `docs/SETUP.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S1.md`
- `tests/bugs_log.md`
