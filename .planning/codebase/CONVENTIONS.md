# CONVENTIONS.md - Coding & Governance

## Project Philosophy
- **DOC2.5 First:** Documentation is source of truth for governance.
- **Lockdown by Default:** Any new service must be closed to the public and require explicit authentication or trusted proxy bypass.
- **Hybrid-GSD:** Technical planning should be done via GSD (`.planning/`), while high-level tracking remains in `Dev_Tracking_SX.md`.

## Coding Style
- **JavaScript:** Predominantly CJS/ESM. Focus on functional and event-driven patterns (Telegram Bot API).
- **Bash:** Robust `entrypoint.sh` with error handling, background jobs, and process orchestration.
- **Prompts:** XML-formatted instructions for AI agents and GSD skills.

## Git & Workflow
- **Commits:** Atomic and descriptive.
- **Architecture:** Keep it "Small and Fast". Avoid over-engineering.
- **Approvals:** Rules demand PO confirmation for structural changes and final deployment.

## Documentation
- **Format:** GitHub Flavored Markdown.
- **Timestamps:** Mandatory UTC (YYYY-MM-DDTHH:MM:SS-ST/FN).
- **Language:** Portuguese-BR (User-facing) / English (Technical/Code).
