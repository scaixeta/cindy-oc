# STACK.md - Technology Stack

## Core
- **Operating System:** Ubuntu 22.04 (Dockerized)
- **Runtime:** Node.js 22 (LTS)
- **Languages:** JavaScript (ESM/CJS), Bash (Shell scripting), Python 3

## Infrastructure & Tools
- **PaaS:** Railway
- **Proxy/Tunneling:** `socat` (TCP Listening on $PORT -> 18790)
- **Automation:** `expect` (for NemoClaw interactive setup)
- **JSON Processing:** `jq` (v1.6+)
- **Process Management:** `entrypoint.sh` (Init PID 1)

## AI Architecture
- **Framework:** OpenClaw (NVIDIA v2026.3.11)
- **Model:** `nvidia/nemotron-4-340b-instruct`
- **Agent Orchestrator:** NemoClaw Alpha
- **Local Sandbox:** Ubuntu-based isolated workspace

## Repository Structure
- **Config:** `.agent/`, `.cline/`, `.clinerules/`, `.codex/`
- **Rules:** `rules/WORKSPACE_RULES.md`, `rules/GSD_RULES.md`
- **Tracking:** `Dev_Tracking_S3.md`, `Cindy_Contract.md`
