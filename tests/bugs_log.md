# bugs_log.md - Log Centralizado de Bugs e Testes

## 1. Proposito

Centralizar o registro de bugs e testes por sprint com rastreabilidade suficiente para sustentar validacoes e correcoes estruturais do projeto.

## 2. Regra de Uso

- Registrar bugs e testes por sprint
- Usar formato padronizado de identificacao
- Manter referencia cruzada com `Dev_Tracking_SX.md`
- Bugs: `BUG-SX-YY`
- Testes: `TEST-SX-YY`
- Registrar fatos observaveis, nao suposicoes

## 3. Sprint S0

### 4. Bugs Registrados

- `BUG-S0-01` - `Nenhum bug estrutural observado no bootstrap inicial`
  - Evidencia: `Estrutura canonicamente materializada sem conflito observado`
  - Impacto: `Nenhum`
  - Status: `Observed-No-Issue`
- `BUG-S0-02` - `Deriva documental apos a ativacao real de Railway, Postgres e n8n-runtime`
  - Evidencia: `README, tracking e docs canonicos continham trechos ainda ancorados no bootstrap sem refletir integralmente dominio publico, API validada e abandono do Slack`
  - Impacto: `Medio - risco de leitura operacional incorreta e perda de rastreabilidade`
  - Status: `Resolved`

### 5. Testes Registrados

- `TEST-S0-07` - `Validacao do Telegram Bot MVP com loop de long polling`
  - Escopo: `Credenciais em .scr/.env, token validado via getMe, chat ID obtido via getUpdates, bot operational loop em telegram-bot.js`
  - Resultado: `Bot respondeu '/start' com 'Oi! Sou a Cindy. Estou ouvindo.' - loop funcional`
  - Status: `Passed`

- `TEST-S0-01` - `Validacao manual da estrutura canonica inicial`
  - Escopo: `README, contrato, tracking, docs, rules, tests, Templates e baseline minimo de runtimes`
  - Resultado: `Aprovado na validacao estrutural manual`
  - Status: `Passed`
- `TEST-S0-02` - `Validacao da decisao do PO sobre Railway`
  - Escopo: `Decisao MVP com Railway registrada em Dev_Tracking_S0.md`
  - Resultado: `Decisao registrada conforme D-S0-04`
  - Status: `Passed`
- `TEST-S0-03` - `Validacao da KB portavel sobre Railway, n8n e comunicacao entre servidores`
  - Escopo: `KB/railway-n8n-server-communication-patterns.md e coerencia com o tracking da sprint`
  - Resultado: `Relatorio anexado a KB com padroes genericos, sem portar segredos ou configuracoes privadas`
  - Status: `Passed`
- `TEST-S0-04` - `Validacao da KB de login Railway no ambiente Windows`
  - Escopo: `KB/railway-n8n-server-communication-patterns.md e procedimento validado de autenticacao da CLI`
  - Resultado: `Procedimento registrado com comandos validados e sem expor segredos`
  - Status: `Passed`
- `TEST-S0-05` - `Validacao do deploy funcional do n8n no Railway com Postgres`
  - Escopo: `Servico n8n-runtime criado por imagem fixa, variaveis aplicadas e deploy validado`
  - Resultado: `n8n 1.64.0 subiu com deployment SUCCESS e logs de migracao/boot concluido`
  - Status: `Passed`
- `TEST-S0-06` - `Reconciliacao da documentacao canonica e KB com o estado tecnico real`
  - Escopo: `README, tracking, docs canonicos e KB alinhados com Railway ativo, dominio publico, API n8n validada e Telegram como proxima etapa`
  - Resultado: `Documentacao reconciliada com a infraestrutura validada e com a despriorizacao do Slack`
  - Status: `Passed`

## 4. Sprint S1

### 4. Bugs Registrados

- `Nenhum bug real registrado ate o momento`

### 5. Testes Registrados

- `TEST-S1-01` - `Validacao do webhook real do n8n-runtime para o contrato minimo do Telegram`
  - Escopo: `Webhook cindy-telegram ativo no n8n-runtime, payload com chat_id e text enviado conforme o contrato minimo, resposta JSON validada`
  - Resultado: `POST para /webhook/cindy-telegram retornou HTTP 200 com "n8n recebeu: integracao n8n ok"`
  - Status: `Passed`
- `TEST-S1-02` - `Validacao de envio do bot Telegram para o chat configurado`
  - Escopo: `Telegram Bot API com TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID locais`
  - Resultado: `sendMessage retornou HTTP 200 e ok=true`
  - Status: `Passed`
- `TEST-S1-03` - `Validacao end-to-end Telegram -> telegram-bot.js -> n8n (cindy-telegram) -> Telegram`
  - Escopo: `Mensagem "n8n: teste de integracao" roteada pelo bot para o webhook cindy-telegram e resposta retornada ao Telegram`
  - Resultado: `n8n respondeu "n8n recebeu: teste de integracao" e o bot enviou ao chat; timeout/fallback nao acionado`
  - Status: `Passed`

## 5. Sprint S2

### Bugs Registrados

- `BUG-S2-01` - `MiniMax MCP apresenta erro "invalid api key" (erro 2049)`
  - Evidencia: `Chamada ao MiniMax retorna "API Error: 2049-invalid api key"`
  - Impacto: `Search capability temporariamente Indisponivel`
  - Status: `Workaround: desabilitado, usar Google Search MCP como alternativa`

- `BUG-S2-02` - `n8n-mcp local: endpoint /mcp nao existe no servidor Railway`
  - Evidencia: `POST para /mcp retorna "Cannot POST /mcp"`
  - Impacto: `n8n MCP local temporariamente Indisponivel`
  - Status: `Workaround: desabilitado, usar n8n Docs MCP Official como alternativa`

### Testes Registrados

(Nenhum teste registrado para S2 ate o momento)

## 6. Sprint S3

### Bugs Registrados

- `BUG-S3-01` - `Pareamento automatico Telegram nao funciona via PAIRING_CODE`
  - Evidencia: `openclaw pairing approve telegram XEVPZQ6K retorna "No pending pairing request found for code: XEVPZQ6K"`
  - Impacto: `Alto - Usuario precisa fazer pairing manual apos cada deploy/redeploy`
  - Status: `Open - Root cause em investigacao`
  - Tentativas de correcao:
    - 1. PAIRING_CODE no entrypoint com sleep 10: `FALHOU - codigo expirou antes do approve`
    - 2. PAIRamento via variavel de ambiente: `FALHOU - mesmo erro`
    - 3. Entrypoint com tratamento de erro: `GATEWAY FUNCIONAL, mas pairing manual ainda necessario`
  - Root cause teorizada: `O codigo de pairing expira rapidamente ou o approve executa antes do gateway processar o pending request`
  - Proximos passos: `Investigar timing do approve ou usar authorizedUsers na config`

### Testes Registrados

(Nenhum teste registrado para S3 ate o momento)

## 6. Timestamp UTC

Usar formato DOC2.5 (ISO 8601, 24h): `YYYY-MM-DDTHH:MM:SS-ST` para inicio e `YYYY-MM-DDTHH:MM:SS-FN` para fim.

Event | Start | Finish | Status
---|---|---|---
BUG-S0-01 | 2026-03-20T18:06:30-ST | 2026-03-20T18:06:45-FN | Observed-No-Issue
TEST-S0-01 | 2026-03-20T18:06:45-ST | 2026-03-20T18:08:00-FN | Passed
TEST-S0-02 | 2026-03-20T18:38:00-ST | 2026-03-20T18:38:30-FN | Passed
TEST-S0-03 | 2026-03-20T19:18:30-ST | 2026-03-20T19:19:30-FN | Passed
TEST-S0-04 | 2026-03-20T20:24:30-ST | 2026-03-20T20:25:30-FN | Passed
TEST-S0-05 | 2026-03-20T21:18:30-ST | 2026-03-20T21:19:30-FN | Passed
BUG-S0-02 | 2026-03-20T22:05:05-ST | 2026-03-20T22:05:20-FN | Resolved
TEST-S0-06 | 2026-03-20T22:05:20-ST | 2026-03-20T22:05:50-FN | Passed
TEST-S0-07 | 2026-03-23T20:43:30-ST | 2026-03-23T20:44:00-FN | Passed
TEST-S1-01 | 2026-03-23T23:54:00-ST | 2026-03-23T23:54:30-FN | Passed
TEST-S1-02 | 2026-03-23T23:55:00-ST | 2026-03-23T23:55:30-FN | Passed
TEST-S1-03 | 2026-03-23T23:56:00-ST | 2026-03-23T23:57:00-FN | Passed
BUG-S3-01 | 2026-03-25T04:00:00-ST | 2026-03-25T04:06:00-FN | Open

## 7. Regras de Qualidade do Log

- Cada bug deve apontar para pelo menos uma evidencia observavel
- Cada teste deve descrever o escopo realmente validado
- O `Timestamp UTC` deve refletir eventos ja executados
- O log deve permanecer coerente com `README.md`, `Dev_Tracking.md` e `Dev_Tracking_SX.md`
