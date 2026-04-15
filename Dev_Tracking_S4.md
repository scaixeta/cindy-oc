# Dev_Tracking_S4.md — Sprint 4 (Ativa)

## Identificação
| Campo | Valor |
|---|---|
| Sprint | S4 |
| Status | **Ativa** |
| Início | 2026-04-15 |
| Versão | 1.0 |
| PO | A definir |
| Objetivo | Implantação e validação operacional do Discord como cockpit de gestão e reflexo canônico DOC2.5 |

---

## Contexto
A Sprint S3 materializou o time AIOps e o protocolo ACP/Redis. Por decisão do PO, a trilha técnica que estava prevista para S4 foi deslocada para S5. A S4 concentra a materialização do Discord como superfície operacional da Cindy, com ponte para ACP e reflexo canônico em tracking e documentação.

O runtime Hermes e o Telegram permanecem como baseline operacional validado enquanto o Discord é implantado e configurado.

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
| ST-S4-01 | Definir papel do Discord, categorias, canais e contrato Discord -> ACP | 5 | — | Pending |
| ST-S4-02 | Estruturar servidor Discord com roles, threads e comandos mínimos | 8 | ST-S4-01 | Pending |
| ST-S4-03 | Materializar Cindy/Bot no Discord com comandos de status, tarefa e review | 5 | ST-S4-02 | Pending |
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

---

## Timestamp UTC (planejado)
| Event | Start | Finish | Status |
|---|---|---|---|
| Kickoff S4 | 2026-04-15T00:00:00Z | — | Done |
| Registro de reclassificacao | 2026-04-15T00:00:00Z | 2026-04-15T00:00:00Z | Done |
| Discord app setup | 2026-04-15T13:33:22Z | 2026-04-15T13:33:22Z | Done |
| Teste de guild Discord | 2026-04-15T00:00:00Z | 2026-04-15T00:00:00Z | Blocked |

---

## Notas Técnicas
- **Discord:** alvo principal da sprint atual.
- **Hermes/Telegram:** base operacional permanece validada enquanto o Discord é implantado.
- **S5:** absorve o backlog antigo de Microsoft Agent Framework, SonarCloud e observabilidade IoT.

Consulte `Dev_Tracking.md` para o histórico completo.
