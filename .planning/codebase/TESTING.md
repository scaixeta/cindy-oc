# TESTING.md - Verification Patterns

## Testing Philosophy
- **Manual Proof of Life:** Every critical bridge (Telegram, Web UI) is verified manually by the PO and Agent.
- **Log Monitoring:** Deployment health is checked via `railway logs`.
- **Bug Tracking:** Failures and edge cases are documented in `tests/bugs_log.md`.

## Test Layers
1. **Entrypoint Health:** The `entrypoint.sh` scripts check for required binaries (`openclaw`, `socat`) and env vars (`NVIDIA_API_KEY`).
2. **Connectivity Check:** Validating the `socat` bind and public availability of the Gateway.
3. **Bot RPC Test:** Verifying the Telegram Bot can reach the OpenClaw Agent.

## Debugging Tools
- **Jq:** Used for JSON extraction from `openclaw.json`.
- **Socat Statistics:** Monitoring tunnel active sessions.
- **Browser Tools:** Inspecting WebSocket connectivity (WS 1006/1008 errors).

## Quality Gates
- **GSD Validation:** New features must follow the Discuss -> Plan -> Execute -> Verify loop.
- **DOC2.5 Audit:** Sprints only close after Rule 8 evidence verification.
