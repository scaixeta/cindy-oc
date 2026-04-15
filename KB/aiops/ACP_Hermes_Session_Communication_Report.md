# Relatório Técnico: Comunicação ACP via Hermes Session

**Data:** 2026-04-12  
**Autor:** MiniMax (subagente investigação)  
**Classificação:** Alta / Investigação ativa

---

## 1. Resumo Executivo

O Hermes **já suporta comunicação inter-agente via ACP (Agent Client Protocol)** de forma nativa, porém projetado para **comunicação pai→filho (delegação)** e **conexão com editores (VS Code/Zed)** — não para um "chat entre agentes" peer-to-peer simétrico no mesmo runtime.

**Veredicto de viabilidade:** Parcialmente viável. O protocolo existe e está funcional, mas comunicação simétrica entre agentes hypotéticos (Sentivis, MiniMax, Scribe, GLM, Cindy) no mesmo runtime **não é o caso de uso nativo** — seria necessário um mecanismo de canal compartilhado a ser implementado.

---

## 2. Arquitetura Encontrada

### 2.1 Stack de Comunicação

```
┌─────────────────────────────────────────────────────────┐
│  Editor (VS Code / Zed) ←→ acp_adapter/server.py       │
│                           (stdio / JSON-RPC ACP)        │
└─────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────┐
│  hermes-agent (AIAgent / run_agent.py)                  │
│    ├── delegate_task → ThreadPoolExecutor               │
│    │       └── child AIAgent (subagente)                │
│    ├── acp_command + acp_args → spawn subprocess        │
│    └── ACP transport: stdout/stdin (JSON-RPC)           │
└─────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────┐
│  state.db (SQLite) ← session persistence                 │
│  response_store.db (SQLite) ← Responses API state       │
└─────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────┐
│  Redis ← channel_directory.json, gateway_state.json     │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Componentes ACP no Hermes

| Componente | Caminho | Função |
|---|---|---|
| `acp_adapter/server.py` | `hermes-agent/acp_adapter/server.py` | Servidor JSON-RPC ACP — conecta editores ao Hermes |
| `acp_adapter/session.py` | `hermes-agent/acp_adapter/session.py` | SessionManager — mapeia sessões ACP para instâncias AIAgent |
| `acp_registry/agent.json` | `hermes-agent/acp_registry/agent.json` | Metadata do agente para registro |
| `delegate_tool.py` | `hermes-agent/tools/delegate_tool.py` | Delegação padre→filho via ThreadPoolExecutor |
| `gateway/platforms/api_server.py` | `hermes-agent/gateway/platforms/api_server.py` | API server OpenAI-compatible (porta 8642) |

### 2.3 Fluxo de Delegação Atual

```
Agente Pai (Cindy)
    ↓ delegate_task(goal, context, acp_command='opencode')
    ↓
ThreadPoolExecutor (max_workers=4)
    ↓
child AIAgent — isolado
    ├── system_prompt custom (goal + context)
    ├── toolsets restritos (parent_toolsets - BLOCKED)
    ├── session_db compartilhado (parent_session_db)
    ├── API key herdada
    └── retorna summary → pai
```

**Configurações de delegação:**
- `MAX_CONCURRENT_CHILDREN = 3`
- `MAX_DEPTH = 2` (pai→filho, netos rejeitados)
- `BLOCKED_TOOLS = {delegate_task, clarify, memory, send_message, execute_code}`
- `acp_command` e `acp_args` são transmitidos ao filho para transport ACP

---

## 3. O que o Hermes já Suporta nativamente

### ✅ Suportado

1. **Delegação com ACP transport:** Pai pode spawnar filhos via `acp_command` (ex: `opencode --acp --stdio`). O filho usa JSON-RPC sobre stdio como transporte.

2. **Sessões persistidas em state.db:** Sessions ACP sobrevivem a restarts. `load_session`/`resume_session` funcionam.

3. **API server OpenAI-compatible:** Porta 8642 expõe `/v1/chat/completions` e `/v1/responses` — qualquer cliente OpenAI-compatible pode se conectar.

4. **Credential pooling:** Subagentes podem compartilhar credential pool com rotação automática.

5. **Progress callback:** Pai recebe eventos de progresso dos filhos (`tool.started`, `tool.completed`, `_thinking`).

6. **API server como platform:** O `api_server` é um platform adapter como Telegram/Discord — mesmo mecanismo.

### ❌ Não Suportado nativamente

1. **Canal de mensagens entre agentes no mesmo runtime** — sem mecanismo de pub/sub ou canal compartilhado.

2. **Comunicação peer-to-peer simétrica** — só existe delegação hierárquica (pai→filho).

3. **Agent channel em state.db** — sessions são por-conversação, não há tabela de "agent channel".

4. **Cindy como coordinator sem bottleneck** — não existe pattern nativo de "agente observador".

---

## 4. Formato de Mensagem ACP

O ACP usa **JSON-RPC 2.0 sobre stdio** (para editor) ou **HTTP SSE** (para API server).

### Estrutura de mensagem (delegação):
```json
{
  "jsonrpc": "2.0",
  "id": "call_function_xxx",
  "method": "invoke",
  "params": {
    "goal": "Criar API FastAPI...",
    "context": "Workspace: C:\\cindyagent\nProvedor: MiniMax M2.7",
    "workspace_path": "/mnt/c/CindyAgent",
    "acp_command": "opencode",
    "acp_args": ["--acp", "--stdio"]
  }
}
```

### Resposta:
```json
{
  "jsonrpc": "2.0",
  "id": "call_function_xxx",
  "result": {
    "status": "completed",
    "summary": "API criada com 3 endpoints...",
    "tool_trace": [...]
  }
}
```

---

## 5. Ambiente Atual — Estado Verificado

| Componente | Estado |
|---|---|
| Hermes runtime | `/root/.hermes` ativo |
| state.db | 14MB, sessions ativas |
| response_store.db | 20MB |
| Redis | PONG — ativo |
| Gateway (PID 462) | `running` — Telegram conectado, API server conectado |
| `channel_directory.json` | Atualizado 2026-04-12 21:25 |
| ACP adapter | Presente (server.py, session.py, tools.py) |
| `hermes acp` command | Configurado em `agent.json` |

**gateway_state.json atual:**
```json
{
  "pid": 462,
  "kind": "hermes-gateway",
  "gateway_state": "running",
  "platforms": {
    "telegram": {"state": "connected"},
    "api_server": {"state": "connected"}
  }
}
```

---

## 6. Problemas Identificados

### Problema 1: Sem canal de agente compartilhado
**Severidade:** Alta  
**Detalhe:** Não existe mechanism em `state.db` para armazenar mensagens entre agentes. Cada session é independente.

### Problema 2: Delegação é hierárquica, não peer-to-peer
**Severidade:** Alta  
**Detalhe:** O `delegate_task` cria processos filhos com `ThreadPoolExecutor`. Não há como dois agentes rodando simultaneamente trocarem mensagens sem passar pelo processo pai.

### Problema 3: Cindy como coordinator sem ser bottleneck
**Severidade:** Média  
**Detalhe:** Para Cindy observar/coordinar sem ser bottleneck, seria necessário um "agent channel" onde mensagens ficam em queue e cada agente faz pull. Atualmente não existe.

### Problema 4: ACP é transport, não protocolo de coordenação
**Severidade:** Média  
**Detalhe:** O ACP define como enviar/receber mensagens (JSON-RPC sobre stdio), mas não define semantic de comunicação multi-agente (quem envía para quem, quando, com qual idempotência).

### Problema 5: WSL + Windows path mixing
**Severidade:** Baixa (operacional)  
**Detalhe:** Workspace em `/mnt/c/CindyAgent` (WSL) mas credenciais e state em `/root/.hermes` (WSL). Path resolução pode causar problemas em subprocessos ACP.

---

## 7. Próximos Passos para Teste

### Passo 1 — Validar delegação simples
```bash
cd /root/.hermes/hermes-agent
source venv/bin/activate
python -c "
from run_agent import AIAgent
agent = AIAgent(model='MiniMax-M2.7', provider='minimax')
result = agent.run_conversation(
    user_message='Diga apenas: olá do subagente'
)
print(result['final_response'])
"
```

### Passo 2 — Testar ACP transport com subprocess
```bash
# Testar se opencode está disponível e aceita --acp --stdio
opencode --acp --stdio --help 2>&1 | head -5
```

### Passo 3 — Verificar API server
```bash
curl http://localhost:8642/health
curl http://localhost:8642/v1/models
```

### Passo 4 — Implementar agent channel (proposto)
Criar tabela em `state.db`:
```sql
CREATE TABLE agent_channel (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    channel TEXT NOT NULL,
    sender TEXT NOT NULL,
    payload TEXT NOT NULL,  -- JSON
    created_at REAL DEFAULT (julianday('now')),
    consumed_by TEXT
);
CREATE INDEX idx_channel ON agent_channel(channel, consumed_by);
```

### Passo 5 — Testar comunicação via Redis pub/sub (alternativa)
```bash
redis-cli publish agent:channel:sentivis '{"from":"cindy","type":"task","content":"..."}'
```

---

## 8. Configurações e EMVARs Necessários

```bash
# Para ativar ACP transport em subagentes
export ACP_COMMAND=opencode  # ou hermes, claude, etc.
export ACP_ARGS='["--acp", "--stdio"]'

# Para API server (gateway)
export HERMES_API_SERVER_ENABLED=true
export HERMES_API_SERVER_HOST=127.0.0.1
export HERMES_API_SERVER_PORT=8642

# Para Redis (canal de comunicação)
export REDIS_HOST=localhost
export REDIS_PORT=6379
```

---

## 9. Conclusão

O Hermes tem infraestrutura ACP sólida para **delegação** e **conexão com editores**. Para implementar comunicação ACP entre agentes hypotéticos (Sentivis, MiniMax, Scribe, GLM, Cindy) no mesmo runtime, é necessário:

1. **Criar um agent channel** (tabela em `state.db` ou canal Redis pub/sub)
2. **Implementar polling mechanism** onde cada agente faz pull do channel
3. **Usar a API server (porta 8642)** como endpoint HTTP para mensagens entre agentes
4. **Cindy como observadora** — implementada como skill que faz polling do channel e relê sessions dos outros agentes

**Confiança:** Alta nos fatos verificados, Média nas propostas de implementação.
