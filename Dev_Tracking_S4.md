# Dev_Tracking_S4.md — Sprint 4 (Ativa)

## Identificação
| Campo | Valor |
|---|---|
| Sprint | S4 |
| Status | **Ativa** |
| Início | 2026-04-14 |
| Versão | 1.0 |
| PO | A definir |
| Objetivo | Adoção do Microsoft Agent Framework e Expansão da Observabilidade IoT |

---

## Contexto
A Sprint S3 materializou o time AIOps e o protocolo ACP/Redis. A Sprint S4 visa migrar a gestão desse time para o Microsoft Agent Framework, garantindo guardrails profissionais via Agent Governance Toolkit e resolvendo pendências de segurança/qualidade (SonarCloud).

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
| ST-S4-01 | Microsoft Agent Framework: Setup e projeto-teste inicial | 8 | — | Pending |
| ST-S4-02 | SonarCloud: Configuração e integração via pipeline (Depends ST-S2-04) | 3 | Credenciais | Blocked |
| ST-S4-03 | Integração Inter-Agente: Migrar handoffs ACP para o framework MS | 5 | ST-S4-01 | Pending |
| ST-S4-04 | Governance Toolkit: Aplicar guardrails de segurança e custo | 5 | ST-S4-01 | Pending |
| ST-S4-05 | IoT Telemetry Hub: Centralizar logs de ThingsBoard no ACP | 5 | — | Pending |

---

## Decisões
| ID | Descrição | Data |
|---|---|---|
| D-S4-01 | S4 iniciada com foco em profissionalização da malha via framework Microsoft | 2026-04-14 |

---

## Timestamp UTC (planejado)
| Event | Start | Finish | Status |
|---|---|---|---|
| Kickoff S4 | 2026-04-14T21:05:00-ST | — | Done |

---

## Notas Técnicas
- **MS Agent Framework:** Alvo principal de pesquisa e integração.
- **SonarCloud:** ST-S2-04 (Credenciais) continua como bloqueio externo.

---
Consulte `Dev_Tracking.md` para o histórico completo.
