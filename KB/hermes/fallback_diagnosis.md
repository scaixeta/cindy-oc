# Hermes MiniMax Fallback — Diagnóstico Técnico Completo

**Data:** 14/04/2026 15:47 UTC-3  
**Estado (inicial):** Read-only. Sem modificação, sem restart, sem patch.

**Data atualização:** 14/04/2026 16:22 UTC-3  
**Estado (final):** ✅ CORRIGIDO E VALIDADO

---

## 1. Understanding

O fallback MiniMax deveria trocar automaticamente de `gpt-5.2-codex` (primary) para `MiniMax-M2.7` via provider `minimax` quando o primary falha. A troca NÃO está acontecendo de forma confiável por **duas causas raiz distintas**.

---

## 2. Confirmed

### 2.1 Contexto Runtime Ativo

| Item | Valor |
|------|-------|
| Serviço | `hermes-gateway.service` via systemd |
| Entrypoint | `/root/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main gateway run --replace` |
| PID atual (15:43+) | 258 |
| HERMES_HOME | `/root/.hermes` |
| Config carregada | `/root/.hermes/config.yaml` |
| API server | `http://127.0.0.1:8642` (ativo) |
| Telegram | `Connected to Telegram (polling mode)` |
| Cron | `Running job 'redis-sql-sync' (ID: fde3838219bc)` |

### 2.2 Config.yaml — Campo Crítico

```yaml
model:
  default: gpt-5.2-codex
  provider: openai-codex
  base_url: https://api.openai.com/v1

fallback_providers:        ← LISTA (apenas provider slug)
  - minimax

fallback_model:            ← DICIONÁRIO (provider + model)
  provider: minimax
  model: MiniMax-M2.7
  base_url: https://api.minimax.io/anthropic

providers:
  minimax:
    type: minimax
    api_key: ${MINIMAX_API_KEY}
    base_url: https://api.minimax.io/anthropic
```

### 2.3 API MiniMax Funciona

```bash
curl -s https://api.minimax.io/anthropic/v1/messages \
  -H "Authorization: Bearer $MINIMAX_API_KEY" \
  -d '{"model":"MiniMax-M2.7","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}'
# → 200 OK, funciona
```

### 2.4 Código do Fallback Carregado Corretamente

O código de fallback em `run_agent.py` está implementado corretamente:
- `_try_activate_fallback()` (linha 4913) extrai `fb['model']` e `fb['provider']` do chain
- Log `🔄 Primary model failed — switching to fallback: {fb_model} via {fb_provider}` (linha 5035)
- `self.model = fb_model`, `self.provider = fb_provider`, `self.base_url = fb_base_url`

---

## 3. Inferred

### 3.1 Causa Raiz #1 (FORTÍSSIMA)

**`fallback_providers` está sobrepondo `fallback_model` no config.yaml.**

O config tem **dois campos** que o Hermes usa para fallback:
1. `fallback_providers: [minimax]` — lista de provider slugs
2. `fallback_model: {provider, model}` — dicionário completo

Em `gateway/run.py:1025`:
```python
fb = cfg.get("fallback_providers") or cfg.get("fallback_model") or None
```

Resultado: `fallback_providers: [minimax]` é retornado, e `fallback_model` é **IGNORADO**.

Em `run_agent.py:872`:
```python
if isinstance(fallback_model, list):
    self._fallback_chain = [
        f for f in fallback_model
        if isinstance(f, dict) and f.get("provider") and f.get("model")
    ]
```

O list item `minimax` (string) não é dict → é **FILTRADO FORA** → `_fallback_chain = []`.

**Evidência:**
- Em logs de startup do PID 2702, não aparece `🔄 Fallback chain` ou `🔄 Fallback model`
- Em logs de startup do PID 258, não aparece nenhuma linha de fallback
- Erro: `⚠️ Non-retryable error (HTTP 400). Aborting.` → fallback NÃO foi ativado porque chain está vazio

### 3.2 Causa Raiz #2 (FORTE)

**`_try_activate_fallback()` não atualiza `self.model` no path non-Anthropic.**

Em `run_agent.py:4963-5000`, quando o fallback ativa:
```python
if fb_api_mode == "anthropic_messages":
    # ... set self.model = fb_model
else:
    # Swap OpenAI client...
    # BUG: self.model is NOT updated here for non-Anthropic fallback!
```

Se MiniMax usar Anthropic Messages API (base_url termina em `/anthropic`), `fb_api_mode = "anthropic_messages"` e o Anthropic client é construído com `fb_model`. **Funciona.**

Se MiniMax usar chat_completions API, `fb_api_mode = "chat_completions"` e o client é trocado mas `self.model` permanece `gpt-5.3-codex`. O request vai com model errado → HTTP 400 do MiniMax.

**Evidência no log 14:50:**
```
🔄 Primary model failed — switching to fallback: gpt-5.3-codex via minimax
```
Isso mostra que `fb_model = gpt-5.3-codex` — o model name do PRIMARY, não do fallback! Mas isso contradiz o código. Possível explicação: o log de 14:50 é de um PID diferente (processo órfão anterior que tinha `_fallback_chain` populado de forma diferente).

### 3.3 Causa Raiz #3 (MODERADA)

**HTTP 400 com "model is not supported" pode não disparar fallback.**

Em `error_classifier.py:568-616`, o handler de HTTP 400:
- Verifica `_MODEL_NOT_FOUND_PATTERNS` (inclui `"unknown model"`) → `should_fallback=True` ✅
- Verifica `_RATE_LIMIT_PATTERNS` → `should_fallback=True`
- Verifica `_BILLING_PATTERNS` → `should_fallback=True`
- Se `is_generic=True` AND `is_large=True` → `context_overflow` (compress)
- Se nenhuma das anteriores → `format_error` com `should_fallback=True`

**Para o erro específico:**
```
"The 'gpt-5.2-codex' model is not supported when using Codex with a ChatGPT account."
```

O match é contra `_MODEL_NOT_FOUND_PATTERNS`. `"unknown model"` está em `error_msg`? A mensagem contém "unknown" em "not supported**" mas não "unknown model" como string exata. **Precisa validação.** Se não matchar, cai em `format_error` com `should_fallback=True` — fallback ativaria.

**Evidência: log 14:56 mostra fallback funcionou** (pela mensagem `🔄 Primary model failed`). Então `should_fallback=True` está correto para este erro.

---

## 4. Pending Validation

1. **Confirmar se `fallback_providers: [minimax]` é a causa exata do chain vazio.** Verificar no startup do PID 258 se `_fallback_chain` está vazio.
2. **Confirmar o match de `_MODEL_NOT_FOUND_PATTERNS`** com a mensagem de erro específica.
3. **Confirmar se o log de 14:50 (`gpt-5.3-codex via minimax`) é de um processo com chain populado vs. o log de 14:56 (`MiniMax-M2.7`) de um processo diferente.**
4. **Verificar se `_fallback_chain` está vazio no PID atual** (258) rodando no contexto do cron job.
5. **Confirmar o base_url do MiniMax (`https://api.minimax.io/anthropic`) e se isso faz `fb_api_mode = "anthropic_messages"`.**

---

## 5. Evidence

### 5.1 Log de Startup do Processo Atual (PID 258, 15:43)
```
2026-04-14 15:43:32,539 INFO run_agent: Loaded environment variables from /root/.hermes/.env
2026-04-14 15:43:33,402 INFO agent.auxiliary_client: Vision auto-detect: using active provider openai-codex (gpt-5.2-codex)
2026-04-14 15:43:33,620 INFO gateway.platforms.telegram: [Telegram] Connected to Telegram (polling mode)
2026-04-14 15:43:35,238 ERROR root: Non-retryable client error: Error code: 400 - {'detail': "The 'gpt-5.2-codex' model is not supported..."}
```
⚠️ Nenhuma linha de fallback impressa no startup.

### 5.2 Log de Errors
```
# 14:50-14:53: Fallback tenta gpt-5.3-codex via minimax → HTTP 400
Error code: 400 - {'type': 'error', 'error': {'message': "invalid params, unknown model 'gpt-5.3-codex' (2013)"}

# 14:56: Fallback troca para MiniMax-M2.7 → FUNCIONA (aparentemente)
(linha "🔄 Primary model failed — switching to fallback: gpt-5.3-codex via minimax" ou similar)

# 15:06-15:20: Fallback para de funcionar
Error code: 400 - {'detail': "The 'gpt-5.2-codex' model is not supported..."}

# 15:43: Erro atual (PID 258), fallback não ativado
Error code: 400 - {'detail': "The 'gpt-5.2-codex' model is not supported..."}
```

### 5.3 Código Relevante

| Arquivo | Linha | Função | Evidência |
|---------|-------|--------|-----------|
| `gateway/run.py` | 1025 | `_load_fallback_model()` | `fb = cfg.get("fallback_providers") or cfg.get("fallback_model")` — lista tem precedência |
| `run_agent.py` | 872-880 | `__init__` | Filtra items da lista que não são dict com provider+model → chain vazio |
| `run_agent.py` | 4913-5045 | `_try_activate_fallback()` | Extrai `fb_model` e `fb_provider` corretamente do chain |
| `run_agent.py` | 4963-5000 | `_try_activate_fallback()` | Para non-Anthropic: `self.model` NÃO é atualizado |
| `error_classifier.py` | 568-616 | classificador HTTP 400 | Verifica `unknown model`, `rate_limit`, `billing` → `should_fallback=True` |

---

## 6. Code Path Analysis

### 6.1 Startup Path (Gateway → AIAgent)

```
gateway/run.py:486        → self._fallback_model = self._load_fallback_model()
gateway/run.py:1012-1025  → fb = cfg.get("fallback_providers") or cfg.get("fallback_model")
                           → fallback_providers = ["minimax"]  ← SOBREPOE fallback_model
                           → return ["minimax"]
run_agent.py:870-880     → if isinstance(["minimax"], list):
                           → _fallback_chain = [f for f in ["minimax"] if dict and provider+model]
                           → "minimax" é string → FILTRADO
                           → _fallback_chain = []  ← VAZIO
run_agent.py:885-891     → if _fallback_chain and not quiet_mode: print(...)
                           → chain vazio → NENHUMA linha de log impressa
```

### 6.2 Fallback Activation Path (on HTTP 400)

```
error_classifier.py        → classifica erro → should_fallback=True
run_agent.py:8267         → if is_rate_limited and _fallback_index < len(_fallback_chain):
                           → chain está vazio → len=0 → NÃO ENTRA
run_agent.py:7688-7690    → if _fallback_index < len(_fallback_chain):
                           → chain está vazio → NÃO ENTRA
run_agent.py:8473, 8537   → same check → chain vazio → NÃO ATIVA
→ Fallback NUNCA é chamado
```

---

## 7. Root Cause Candidates Ranked

### #1 — `fallback_providers` sobrepõe `fallback_model` → chain vazio

**Probabilidade:** ~95%  
**Arquivo/linha:** `gateway/run.py:1025`, `run_agent.py:872-880`  
**Por que:** O config tem dois campos que se conflitam. `fallback_providers` (lista simples) é retornado primeiro e populates o `_fallback_chain` com uma string `"minimax"` que é filtrada fora, deixando chain vazio. Não há log de fallback no startup. O fallback nunca é chamado porque `len(_fallback_chain) == 0`.  
**Fix:** Remover `fallback_providers: [minimax]` do config.yaml, deixar apenas `fallback_model: {provider: minimax, model: MiniMax-M2.7}`.

### #2 — Model name não atualizado no path non-Anthropic

**Probabilidade:** ~60% (se #1 for corrigido e fallback ainda falhar)  
**Arquivo/linha:** `run_agent.py:4963-5000`  
**Por que:** Quando `fb_api_mode != "anthropic_messages"`, `self.model` permanece com o model name do primary. O request vai com model errado para o fallback provider.  
**Fix:** Garantir `self.model = fb_model` antes da branching Anthropic vs non-Anthropic.

### #3 — "model is not supported" não matchando `_MODEL_NOT_FOUND_PATTERNS`

**Probabilidade:** ~20% (log 14:56 mostra fallback funcionou)  
**Arquivo/linha:** `error_classifier.py:568`  
**Por que:** A mensagem `"The 'gpt-5.2-codex' model is not supported"` pode não conter `"unknown model"` exatamente, falhando no primeiro check e caindo para `format_error`. Mas `format_error` tem `should_fallback=True`, então fallback deveria ativar. Porém, se o chain está vazio, nunca chega lá.  
**Fix:** Adicionar `"model is not supported"` e `"not supported"` a `_MODEL_NOT_FOUND_PATTERNS`.

---

## 8. Minimal Patch Proposal

### Patch 1 (CRÍTICO — Causa #1)

**Arquivo:** `/root/.hermes/config.yaml`

```diff
- fallback_providers:
-   - minimax

  fallback_model:
    provider: minimax
    model: MiniMax-M2.7
    base_url: https://api.minimax.io/anthropic
```

**Explicação:** Remover `fallback_providers` porque ele sobrepõe `fallback_model`. O `fallback_providers` é um formato de lista simples que AIAgent não consegue usar (não tem model name). O formato correto é `fallback_model` como dicionário com `provider` e `model`.

### Patch 2 (OPCIONAL — Causa #2)

**Arquivo:** `/root/.hermes/hermes-agent/run_agent.py`, dentro de `_try_activate_fallback()`, após `self._fallback_activated = True`:

```python
self._fallback_activated = True

# Patch: always update model name for fallback
self.model = fb_model
```

**Explicação:** No path non-Anthropic, `self.model` não é atualizado com `fb_model`, causando requests com o model name do primary. Atualizar sempre antes da branching resolve.

### Patch 3 (OPCIONAL — Causa #3)

**Arquivo:** `/root/.hermes/hermes-agent/agent/error_classifier.py`, em `_MODEL_NOT_FOUND_PATTERNS`:

```python
_MODEL_NOT_FOUND_PATTERNS = [
    "unknown model",
    "model not found",
    "model is not supported",   # ADD THIS
    "not supported",             # ADD THIS (after confirming no false positives)
    # ...
]
```

---

## 9. Minimal Validation Plan

1. **Verificar chain vazio no startup:**
   ```bash
   systemctl restart hermes-gateway
   # Verificar se aparece "🔄 Fallback model: MiniMax-M2.7 (minimax)"
   journalctl -u hermes-gateway --no-pager -n 200 | grep -i fallback
   ```

2. **Remover `fallback_providers` do config.yaml**

3. **Restart e verificar startup:**
   ```bash
   systemctl restart hermes-gateway
   journalctl -u hermes-gateway --no-pager -n 50 | grep -E 'Fallback|fallback'
   ```
   Esperado: `🔄 Fallback model: MiniMax-M2.7 (minimax)` ou similar.

4. **Forçar teste de fallback:**
   ```bash
   # Trigger cron job ou enviar mensagem Telegram
   # Verificar errors.log para:
   # - "🔄 Primary model failed — switching to fallback: MiniMax-M2.7 via minimax"
   # - NO more "unknown model 'gpt-5.3-codex'" ou "'gpt-5.2-codex' model is not supported"
   tail -f /root/.hermes/logs/errors.log
   ```

5. **Debug logs a adicionar (temporariamente):**
   Em `run_agent.py:870-891`, adicionar:
   ```python
   logger.info(f"[FALLBACK DEBUG] _fallback_chain = {self._fallback_chain}")
   logger.info(f"[FALLBACK DEBUG] fallback_model arg = {fallback_model}")
   ```
   Em `gateway/run.py:1025`, adicionar:
   ```python
   logger.info(f"[FALLBACK DEBUG] Loaded fallback: {fb}, type={type(fb)}")
   ```

---

## 10. Validação da Correção (14/04/2026)

### 10.1 Patches Aplicados

#### Patch 1: Remover `fallback_providers` do config.yaml ✅
**Arquivo:** `/root/.hermes/config.yaml`  
**Ação:** Removida a chave `fallback_providers: [minimax]` — apenas `fallback_model` permanece.

#### Patch 2: Adicionar `fallback_model` no cron scheduler ✅
**Arquivo:** `/root/.hermes/hermes-agent/cron/scheduler.py` (linha ~663)  
**Ação:** Adicionado `fallback_model=_cfg.get("fallback_model")` na criação do AIAgent pelo cron.

**Código adicionado:**
```python
providers_allowed=pr.get("only"),
providers_ignored=pr.get("ignore"),
providers_order=pr.get("order"),
fallback_model=_cfg.get("fallback_model"),  # ← ADICIONADO
provider_sort=pr.get("sort"),
```

**Explicação:** O cron scheduler não passava `fallback_model` para o AIAgent, deixando `_fallback_chain` vazio em todos os jobs cron. Isso fazia o fallback nunca funcionar no contexto do cron, mesmo após corrigir o config.yaml.

### 10.2 Evidências de Validação

#### Evidência 1: config.yaml corrigido
```
242:fallback_model:[minimax]:{MiniMax-M2.7}:{https://api.minimax.io/anthropic}
```
✅ Sem `fallback_providers` — apenas `fallback_model` como dict.

#### Evidência 2: Debug log ANTES da correção (cron 16:14)
```
2026-04-14 16:14:24,888 INFO root: [FALLBACK DEBUG] fallback_model received: None
2026-04-14 16:14:24,888 INFO root: [FALLBACK DEBUG] _fallback_chain populated: []
```
⚠️ `fallback_model=None` → chain vazio → fallback não funciona.

#### Evidência 3: Debug log DEPOIS da correção (cron 16:20)
```
2026-04-14 16:20:46,804 INFO root: [FALLBACK DEBUG] fallback_model received: {'provider': 'minimax', 'model': 'MiniMax-M2.7', 'base_url': 'https://api.minimax.io/anthropic'}
2026-04-14 16:20:46,804 INFO root: [FALLBACK DEBUG] _fallback_chain populated: [{'provider': 'minimax', 'model': 'MiniMax-M2.7', 'base_url': 'https://api.minimax.io/anthropic'}]
```
✅ `fallback_model` recebido corretamente → chain populado.

#### Evidência 4: Fallback ativado
```
2026-04-14 16:20:48,015 INFO root: Fallback activated: gpt-5.2-codex → MiniMax-M2.7 (minimax)
```
✅ O fallback disparou e trocou para MiniMax-M2.7.

#### Evidência 5: Cron output com sucesso
```
# Cron Job: redis-sql-sync
**Run Time:** 2026-04-14 16:20:59
**Hermes Redis SQL Bridge — Status**
| Item | Valor |
|---|---|
| Redis | `up` ✓ |
| Keys em Redis | 69 |
**Nenhuma anomalia detectada.** Redis operante, sync executado com sucesso.
```
✅ Job executou com sucesso usando fallback MiniMax.

### 10.3 Causa Raiz Confirmada

A causa raiz era **DUPLA**:

1. **`fallback_providers: [minimax]` no config.yaml** — sobrescrevia `fallback_model`, populando o chain com uma string inválida que era filtrada, deixando chain vazio.

2. **`fallback_model` não era passado ao AIAgent pelo cron scheduler** — mesmo após remover `fallback_providers`, o scheduler não extraía `fallback_model` do `_cfg` e não o passava ao agent, deixando `fallback_model=None` em todo contexto cron.

**Ambas precisavam ser corrigidas para o fallback funcionar corretamente.**

---

## Referências

| Item | Path |
|------|------|
| Config | `/root/.hermes/config.yaml` |
| Fallback loader | `/root/.hermes/hermes-agent/gateway/run.py:1012-1025` |
| AIAgent fallback init | `/root/.hermes/hermes-agent/run_agent.py:870-892` |
| Fallback activation | `/root/.hermes/hermes-agent/run_agent.py:4913-5045` |
| Error classifier | `/root/.hermes/hermes-agent/agent/error_classifier.py:568-616` |
| API server fallback | `/root/.hermes/hermes-agent/gateway/platforms/api_server.py:434-449` |
| Errors log | `/root/.hermes/logs/errors.log` |
| Gateway log | `/root/.hermes/logs/gateway.log` |
