# Dev_Tracking_S4.md — Sprint 4 (Ativa)

## Identificação
| Campo | Valor |
|---|---|
| Sprint | S4 |
| Status | **Ativa** |
| Início | 2026-04-15 |
| Versão | 1.1 |
| PO | A definir |
| Objetivo | MVP Discord como cockpit de gestão — visibilidade operacional via ST-S4-01 → 02 → 03. Task Envelope e Reflexo Canônico adiados para S5. |

---

## Contexto
A Sprint S3 materializou o time AIOps e o protocolo ACP/Redis. Por decisão do PO, a trilha técnica que estava prevista para S4 foi deslocada para S5. A S4 concentra a materialização do Discord como superfície operacional da Cindy, com ponte para ACP e reflexo canônico em tracking e documentação.

O runtime Hermes e o Telegram permanecem como baseline operacional validado enquanto o Discord é implantado e configurado. A WebUI local do Hermes também foi validada em `http://127.0.0.1:9119` via `hermes dashboard`, mantendo a sprint focada em cockpit/observabilidade sem alterar o status de abertura da S4.

---

## Escopo
### Fase 1 — Definição canônica
- Fechar o papel do Discord no fluxo da Cindy.
- Definir categorias, canais, threads e comandos mínimos.
- Definir o contrato Discord -> ACP e o envelope de tarefa mínimo.

### Fase 2 — Cockpit mínimo
- Estruturar servidor, roles e canais base.
- Materializar Cindy/Bot no Discord.
- Habilitar comandos manuais ou semiautomáticos.

### Fase 3 — Integração com runtime
- Ligar Discord -> Cindy -> ACP/Redis.
- Refletir status do mesh de volta ao Discord.
- Garantir thread por tarefa, incidente e review.

### Fase 4 — Reflexo canônico assistido
- Espelhar eventos relevantes em Dev_Tracking e bugs_log.
- Criar templates operacionais de decisão, incidente e review.
- Consolidar a governança sem criar fonte paralela.

---

## Backlog

| ID | Estória | SP | Dependência | Status |
|---|---|---|---|---|
| ST-S4-01 | Definir papel do Discord, categorias, canais e contrato Discord -> ACP | 5 | — | **Done** |
| ST-S4-02 | Estruturar servidor Discord com roles, threads e comandos mínimos | 8 | ST-S4-01 | **Done** |
| ST-S4-03 | Materializar Cindy/Bot no Discord com comandos de status, tarefa e review | 5 | ST-S4-02 | **Done** |
| ST-S4-04 | Integrar bridge Discord -> Cindy -> ACP/Redis e retorno de status | 8 | ST-S4-03 | Pending |
| ST-S4-05 | Refletir eventos relevantes em Dev_Tracking, bugs_log e templates operacionais | 5 | ST-S4-04 | Pending |

---

## Decisões
| ID | Descrição | Data |
|---|---|---|
| D-S4-01 | S4 reclassificada pelo PO para focar na implantação e validação operacional do Discord | 2026-04-15 |
| D-S4-02 | O backlog técnico anterior de Microsoft Agent Framework, SonarCloud e observabilidade passa para S5 | 2026-04-15 |
| D-S4-03 | Credenciais do Discord validadas; comandos slash registrados globalmente; instalação em guild ainda pendente | 2026-04-15 |
| D-S4-04 | `DISCORD_GUILD_ID` configurado no env; teste de API retornou `403` para comandos do guild e o bot ainda não aparece entre os guilds acessíveis | 2026-04-15 |
| D-S4-05 | Catálogo do guild realinhado ao runtime Hermes atual via overwrite com o catálogo global; comandos `project/*` stale removidos do guild | 2026-04-15 |
| D-S4-06 | Aceite técnico parcial revisado: `/help` e `/clear` validados no cliente Discord; `/status` permanece pendente de payload útil no navegador; cockpit completo, `project status` e `sprint status` continuam pendentes | 2026-04-15 |
| D-S4-07 | Validação Playwright/Discord atualizada: login web concluído; canais `#geral` e `#runtime-status` exercitados; autocomplete mínimo confirmado; `/help` e `/clear` passaram; `/status` não retornou payload útil verificável | 2026-04-15 |
| D-S4-08 | Auditoria tripla aprovada pelo PO via delegation: Discord App (gap audit), Runtime (G1-G7 audit), Backlog (priorização). Codex validou: G1 (toolsets) já resolvido, dead code de 119 linhas identificado em `discord.py`, caminho mais curto para MVP = ST-S4-01 → 02 → 03 (~60% do esforço original) | 2026-04-15 |
| D-S4-09 | MVP recortado: ST-S4-04 (Task Envelope) e ST-S4-05 (Reflexo Canônico) adiados para S5. MVP de visibilidade = ST-S4-01 → 02 → 03. Estimativa revisada: ~35-55h vs 52-86h original | 2026-04-15 |
| D-S4-10 | Pré-work ST-S4-01 concluído: dead code removido (119 linhas, 8 comandos duplicados), `hermes-discord` toolset validado como existente e correto, G1 marcado como résolvido. Ready for ST-S4-01 | 2026-04-15 |
| D-S4-11 | DISCORD_COCKPIT_DEFINITION.md produzido: papel do Discord como cockpit de gestão definido, categorias e canais especificados, envelope de tarefa mínimo documentado, contrato Discord→ACP formalizado | 2026-04-15 |
| D-S4-12 | ST-S4-02 concluído: DISCORD_SERVER_SETUP.md criado com estrutura de roles (Cindy, PO, Agent-Ops, Developer, Viewer), categorias/canais (PORTFOLIO, PO_GATES, AGENT_OPS, INCIDENTS, AUTOMATION, ARCHIVE), slash commands de cockpit (/project, /task, /incident, /review, /sprint, /agent, /mesh), script `scripts/discord_cockpit_setup.py` para setup e verificação | 2026-04-15 |
| D-S4-13 | ST-S4-03 concluído: 7 handlers de cockpit implementados em `gateway/platforms/discord.py` (_register_slash_commands): /project, /task, /incident, /review, /sprint, /agent, /mesh — cada um pubblica no ACP via ACPRedis.publish(), documentação completa em DISCORD_SLASH_HANDLERS.md | 2026-04-15 |

---

## Timestamp UTC (planejado)
| Event | Start | Finish | Status |
|---|---|---|---|
| Kickoff S4 | 2026-04-15T00:00:00Z | — | Done |
| Registro de reclassificacao | 2026-04-15T00:00:00Z | 2026-04-15T00:00:00Z | Done |
| Discord app setup | 2026-04-15T13:33:22Z | 2026-04-15T13:33:22Z | Done |
| Teste de guild Discord | 2026-04-15T00:00:00Z | 2026-04-15T00:00:00Z | Blocked |
| Realinhamento do catálogo do guild | 2026-04-15T18:24:01Z | 2026-04-15T18:24:01Z | Done |
| Validação MVP `/status` | 2026-04-15T18:24:01Z | 2026-04-15T18:24:01Z | Partial |
| Validação Playwright Discord MVP | 2026-04-15T00:00:00Z | 2026-04-15T00:00:00Z | Partial |
| Validação WebUI Hermes | 2026-04-15T23:27:06Z | 2026-04-15T23:27:06Z | Done |

---

## Notas Técnicas
- **Discord:** alvo principal da sprint atual.
- **Hermes/Telegram:** base operacional permanece validada enquanto o Discord é implantado.
- **Discord guild catalog:** agora espelha o catálogo global atual do runtime; o comando stale `project` foi removido do guild.
- **Discord MVP:** a superfície ativa ficou reduzida a `/status`, `/help` e `/clear`; `/help` e `/clear` passaram no cliente Discord, enquanto `/status` ainda precisa entregar payload útil verificável no navegador; `project status` e `sprint status` seguem pendentes.
- **WebUI Hermes:** `hermes dashboard` está disponível e validado localmente em `http://127.0.0.1:9119`; isso não encerra a S4 e não altera o backlog do Discord.
- **S5:** absorve o backlog antigo de Microsoft Agent Framework, SonarCloud e observabilidade IoT.

Consulte `Dev_Tracking.md` para o histórico completo.
