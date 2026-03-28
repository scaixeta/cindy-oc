# CONCERNS.md - Project Risks & Fragilities

## Technical Debt

### 1. Hardcoded Security
- **Hardcode Bypass:** Fixed Gateway Token `9906eb...` is currently a security trade-off for session stability on ephemeral Railway storage.
- **Future fix:** Persistent Volume (Railway Volume) to allow dynamic but stable secrets.

### 2. Multi-hop Latency
- Telegram polls through the OpenClaw bridge, which talks to a localhost gateway, which talks to an external NVIDIA API.
- **Concern:** Latency and potential WebSocket 1006 disconnects during peak loads.

### 3. Amnesic Configuration
- The `entrypoint.sh` brute-forces the configuration on every boot (`config set ...`).
- **Fragility:** Any change made through the Web UI (UI configuration) will be lost on the next deploy unless synced back to the repo.

## Infrastructure Risks

### 1. Port Proxy Reliability
- `socat` is a crucial but single point of failure within the container.
- If `socat` crashes, the 502 error returns immediately regardless of Gateway health.

### 2. Provider Auth
- Reliance on NVIDIA API (Alpha) without a robust local fallback. If NVIDIA keys expire, the bot goes silent.
- **Mitigation:** OpenRouter fallback configured in `auth-profiles.json`.
