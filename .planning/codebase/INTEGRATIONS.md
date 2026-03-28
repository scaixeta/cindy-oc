# INTEGRATIONS.md - External Systems & APIs

## Core Integrations

### 1. Telegram (Bot Interface)
- **Token:** `${TELEGRAM_BOT_TOKEN}` (Railway Env)
- **Engine:** `telegram-bot.js`
- **Bridge:** OpenClaw Telegram Bridge
- **Allowed Users:** ID `8687754084` (Auto-Allowlist)
- **Policy:** `dmPolicy='allowlist'`

### 2. Railway (Deployment Control)
- **Environment:** Container-based PaaS
- **Volumes:** Ephemeral (Root partition)
- **Networking:** External `$PORT` bound to socat TCP reverse tunnel.
- **CLI Management:** `railway.json`

### 3. NVIDIA (Inference Engine)
- **API Key:** `${NVIDIA_API_KEY}` (Railway Env)
- **Provider:** OpenClaw Agent (NVIDIA Provider)
- **Context:** `OpenClaw 2026.3.11`
- **Fallback:** OpenRouter (Configured in `auth-profiles.json`)

## Internal Bridges
- **Socat Reverse Proxy:** Port `$PORT` (Railway Public) -> `127.0.0.1:18790` (Localhost Loopback)
- **Gateway Dashboard:** WebSocket secured with hardcoded token `9906eb350...`
- **Origin Security:** `gateway.controlUi.allowedOrigins=["*"]`
- **Trusted Proxies:** `["127.0.0.1", "::1"]`
