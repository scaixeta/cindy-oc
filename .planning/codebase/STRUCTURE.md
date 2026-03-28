# STRUCTURE.md - Repository Layout

## Root
- `Dev_Tracking_S3.md` - Active sprint tracker (Governance)
- `Dev_Tracking.md` - Milestone index (Governance)
- `Cindy_Contract.md` - Identity and role definition
- `Dockerfile` - Container blueprint (NVIDIA/Node22)
- `entrypoint.sh` - Gateway and reverse proxy boot script
- `railway.json` - Cloud deployment manifest

## Project Governance
- `rules/WORKSPACE_RULES.md` - Core project rules (DOC2.5)
- `rules/GSD_RULES.md` - Hybrid Cindy-GSD integration rules

## GSD Framework
- `.agent/` - GSD installation (Workflows, Skills, Hooks)
- `.planning/` - Technical state (Codebase Map, Phases)

## Logic & Services
- `src/` - Core application logic layer
- `telegram-bot.js` - Legacy/Fallback Bot API bridge
- `openclaw/` - Gateway-specific extensions and plugins
- `nemoclaw.sh` - CLI launcher for local dev

## Documentation & KB
- `KB/` - Deep technical knowledge items (NemoClaw, Setup)
- `docs/` - Canonical DOC2.5 documentation (ARCHITECTURE, SETUP)
- `Templates/` - Standardized document layouts
- `Sprint/` - Archived sprint history
