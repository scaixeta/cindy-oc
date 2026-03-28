# ARCHITECTURE.md - System Design

## Overview
Cindy-OC is a "Lockdown-by-Default" AI Gateway architecture. It bridges public messaging interfaces (Telegram) with private, isolated inference environments (NemoClaw Sandbox) using a multi-hop secure communication bridge.

## Network Topology
1. **Public Layer:** Railway Proxy (HTTPS) -> `$PORT` (Public Container Port)
2. **Proxy Layer:** `socat` TCP-LISTEN (bind 0.0.0.0) -> `socat` TCP-CONNECT (127.0.0.1:18790)
3. **Internal Layer:** `127.0.0.1:18790` (OpenClaw Gateway Loopback)

## Identity & Auth Flow
- **NemoClaw Gateway:** Self-manages a 42-byte WebSocket token.
- **Hardcoded Token:** For session stability, the token `9906eb350...` is injected during boot.
- **Trusted Proxy:** The `127.0.0.1` address is whitelisted to bypass the "Pairing Required" manual handshake for external Railway requests.

## Data Life Cycle
1. **Telegram Msg:** Arrives at Telegram Bot API.
2. **Bridge:** OpenClaw Telegram Bridge (running inside the container) polls/receives.
3. **Gateway RPC:** Bridge forwards task to the OpenClaw Agent (`main`).
4. **Inference:** Agent routes via `auth-profiles.json` to NVIDIA API.
5. **Response:** Async return via WebSockets back to Telegram.
