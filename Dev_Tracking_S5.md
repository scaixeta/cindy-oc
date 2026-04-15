# Dev_Tracking_S5.md — Sprint 5 (Planejada)

## Identificação
| Campo | Valor |
|---|---|
| Sprint | S5 |
| Status | **Planejada** |
| Início | A definir |
| Versão | 1.0 |
| PO | A definir |
| Objetivo | Adoção do Microsoft Agent Framework e Expansão da Observabilidade IoT |

---

## Contexto
A Sprint S3 materializou o time AIOps e o protocolo ACP/Redis. A Sprint S5 recebe o backlog técnico que antes estava previsto para a S4, após o PO reclassificar a S4 para a implantação e validação operacional do Discord.

Em `2026-04-15`, a base operacional Hermes + Telegram foi revalidada com 5 reinicializações consecutivas do `hermes-gateway.service`, mantendo `telegram=connected`, `api_server=connected`, healthcheck `ok` e `hermes chat -Q` respondendo `OK`.

O backup completo do Hermes foi criado localmente em `backups/hermes/` e o diretório foi excluído do versionamento via `.gitignore`.

---

## Escopo
### Fase 1 — Microsoft Agent Framework Evaluation & Integration
- Instalação e configuração do ambiente de desenvolvimento.
- Mapeamento de agentes ACP para o framework MS.
- Avaliação do Agent Governance Toolkit para guardrails.

### Fase 2 — Advanced IoT Observability
- Integração da telemetria ThingsBoard/n8n no fluxo de decisão dos agentes.
- Dashboards de infraestrutura avançados.

### Fase 3 — Qualidade & Segurança
- Configuração do SonarCloud (depende de credenciais).
- Refatoração do mesh para reduzir latência e aumentar resiliência.

---

## Backlog

| ID | Estória | SP | Dependência | Status |
|---|---|---|---|---|
| ST-S5-01 | Microsoft Agent Framework: Setup e projeto-teste inicial | 8 | — | Pending |
| ST-S5-02 | SonarCloud: Configuração e integração via pipeline (Depends ST-S2-04) | 3 | Credenciais | Blocked |
| ST-S5-03 | Integração Inter-Agente: Migrar handoffs ACP para o framework MS | 5 | ST-S5-01 | Pending |
| ST-S5-04 | Governance Toolkit: Aplicar guardrails de segurança e custo | 5 | ST-S5-01 | Pending |
| ST-S5-05 | IoT Telemetry Hub: Centralizar logs de ThingsBoard no ACP | 5 | — | Pending |

---

## Decisões
| ID | Descrição | Data |
|---|---|---|
| D-S5-01 | S5 herda o backlog técnico deslocado da S4 após decisão do PO | 2026-04-15 |
| D-S5-02 | Bateria operacional de 5 reinicializações do `hermes-gateway.service` validada com Telegram conectado, healthcheck `ok` e `hermes chat -Q` retornando `OK` | 2026-04-15 |
| D-S5-03 | Estado atual registrado: Hermes/Telegram validado, backup completo do runtime criado em `backups/hermes/` e `backups/` excluído do git | 2026-04-15 |

---

## Timestamp UTC (planejado)
| Event | Start | Finish | Status |
|---|---|---|---|
| Kickoff S5 | A definir | — | Pending |
| Bateria Hermes 5x | 2026-04-15T12:14:11-ST | 2026-04-15T12:17:34-FN | Done |
| Registro de estado S5 | 2026-04-15T09:34:00-ST | 2026-04-15T09:34:00-ST | Done |

---

## Notas Técnicas
- **MS Agent Framework:** alvo principal de pesquisa e integração.
- **SonarCloud:** ST-S2-04 (Credenciais) continua como bloqueio externo.
- **Baseline operacional Hermes/Telegram:** validada em `2026-04-15` com 5 reinicializações do gateway e estado final `active (running)`.

Consulte `Dev_Tracking.md` para o histórico completo.
