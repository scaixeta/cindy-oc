# Dev_Tracking.md — Índice de Sprints

## Sprint Ativa

| ID | Status | Inicio | Escopo |
|---|---|---|---|
| S4 | Ativa | 2026-04-15 | Discord em implantação e validação operacional — cockpit de gestão, bridge com Cindy/ACP e reflexo canônico DOC2.5 |

## Sprints Futuras

| ID | Status | Inicio | Escopo |
|---|---|---|---|
| S5 | Planejada | A definir | Microsoft Agent Framework & Advanced IoT Observability — backlog deslocado da S4 por decisão do PO |

## Sprints Encerradas

| ID | Status | Periodo | Entrega |
|---|---|---|---|
| S3 | Encerrada | 2026-04-14 a 2026-04-14 | Materialização do time AIOps (Fases 1-5) — ACP Mesh, Workers Especialistas, OpenCode Profiles e Smoke Tests |
| S2 | Encerrada (substituída) | 2026-04-13 a 2026-04-14 | Ferramentas internas da Cindy — substituída por S3 com novo objetivo time AIOps |

---

## Registros recentes

- `2026-04-09` — WSL Ubuntu reinstalado e Hermes operacionalizado
- `2026-04-09` — Telegram pareado e gateway funcional no runtime Hermes
- `2026-04-09` — KB canônica `KB/hermes/` sincronizada com o runtime vivo em `/root/.hermes`
- `2026-04-09` — branch principal consolidada em `main` com proteção de `.scr/.env`
- `2026-04-09` — `Replicar.md` reconhecido como mapa dos projetos principais da Cindy
- `2026-04-10` — OpenCode CLI integrado com MiniMax M2.7 via wrapper `run_opencode.bat`; TEST-S1-05 (API FastAPI) passou
- `2026-04-10` — Análise aprofundada dos 8 repositórios; 5 repositórios pessoais removidos de `Replicar.md`; `KB/REPOSITORIES_STATUS.md` criado
- `2026-04-12` — ST-S1-18: Codex CLI integrado como engine secundária de raciocínio
- `2026-04-13` — ST-S1-19: Arquitetura dual-modelo (MiniMax + GLM-5.1) implementada com RACI e gate de iteração
- `2026-04-13` — ST-S1-20: Comunicação ACP entre agentes via Redis (Pub/Sub + Streams) implementada e testada
- `2026-04-13` — ST-S1-21: Equipe de 5 agentes (Cindy, Sentivis, MiniMax, Scribe, GLM-5.1) documentada e operacional
- `2026-04-13` — D-S1-13: Equipe de 5 agentes com ACP via Redis — modelo aprovado
- `2026-04-13` — D-S1-14: Agentes se comunicam via ACP/JSON — nunca em linguagem humana entre si
- `2026-04-13` — D-S1-15: PO approves planos; agentes escalam decisões grandes via Cindy
- `2026-04-13` — ST-S2-03: Playwright instalado e funcional (Chromium, Firefox, WebKit) — venv Hermes como ambiente Python preferencial
- `2026-04-14` — S3 aberta: time AIOps multiagente com Microsoft Agent Framework — S2 substituída
- `2026-04-14` — D-S3-11: Codex é o modelo de pensamento e validação do time
- `2026-04-14` — Runtime Linux do Hermes corrigido após reboot: `MiniMax-M2.7` mantido como primário e `gpt-5.3-codex` como fallback
- `2026-04-14` — `hermes-gateway.service` reiniciado com sucesso; healthcheck `/health` e `hermes chat -Q` validados no Linux
- `2026-04-15` — Bateria operacional de 5 reinicializações do `hermes-gateway.service` validada; gateway final permaneceu `active (running)` com `telegram=connected`, `api_server=connected`, healthcheck `ok` e `hermes chat -Q` retornando `OK`
- `2026-04-15` — PO reclassificou a S4 para Discord e deslocou o backlog técnico de Microsoft Agent Framework, SonarCloud e observabilidade para a S5
- `2026-04-15` — S4 registrada como sprint de implantação e validação do Discord; S5 criada como sprint futura para o backlog técnico deslocado
- `2026-04-15` — Discord app validado na API; comandos slash registrados globalmente e install params ajustados para guild install
- `2026-04-15` — `DISCORD_GUILD_ID` configurado no env; teste de guild retornou `403` e o bot ainda não aparece entre os guilds acessíveis
- `2026-04-14` — ST-S1-22: Reconciliação do Remote oficial como `https://github.com/scaixeta/CindyAgent`
- `2026-04-14` — ST-S3-FINAL: Sprint S3 encerrada com materialização funcional do time AIOps e handoff gerado
- `2026-04-15` — ST-S4: Sprint S4 reclassificada para Discord; Microsoft Agent Framework e observabilidade movidos para S5


## Estrutura de Tracking

- `Dev_Tracking.md` — indice das sprints
- `Dev_Tracking_S4.md` — sprint ativa
- `Dev_Tracking_S5.md` — sprint futura planejada
- `Sprint/Dev_Tracking_S3.md` — sprint encerrada
- `Sprint/` — historico de sprints encerradas

## Referencia

Consulte `Dev_Tracking_S4.md` para backlog, decisões e pendências da sprint ativa e `Dev_Tracking_S5.md` para o backlog futuro deslocado.
