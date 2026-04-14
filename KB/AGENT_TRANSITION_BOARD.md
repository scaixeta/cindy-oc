# AGENT_TRANSITION_BOARD

## Objetivo

Acompanhar a transição do CindyAgent de um runtime centralizado para um time AIOps multiagente com Microsoft Agent Framework como plataforma de gestão.

> Status consolidado mais recente: ver `KB/HANDOFF_S3_2026-04-14.md`.

**Decisão central:** Nomes de agentes são baseados em papel — não em modelo. Microsoft Agent Framework é a plataforma de gestão approved — não mais referência futura.

---

## Papéis do time

| Papel | Responsabilidade | Status atual |
|---|---|---|
| Cindy (Coordenação) | Coordenação operacional, roteamento, visibilidade | Ativo |
| Builder | Execução técnica, código, automação | Planejado |
| Reviewer | Validação, revisão, qualidade | Planejado |
| Documenter | Documentação, kb, procedimentos | Planejado |
| PlatformOps | Infraestrutura, runtime, observabilidade | Planejado |

> Nenhum papel está atrelado a modelo ou provedor específico. Modelo é runtime strategy — não identidade.

---

## Decisões aprovadas

| # | Decisão | Data |
|---|---|---|
| D1 | Nomes de agente = papel (não modelo) | 2026-04-14 |
| D2 | Microsoft Agent Framework = plataforma de gestão approved | 2026-04-14 |
| D3 | ACP/Redis permanece como mesh interno durante transição | 2026-04-14 |
| D4 | OpenCode permanece como executor técnico dos especialistas | 2026-04-14 |
| D5 | Adoção incremental: produtos Microsoft pagos não são obrigatórios na fase 1 | 2026-04-14 |

---

## Arquivos alterados

| Arquivo | Alteração | Status |
|---|---|---|
| `KB/AIOPS_TEAM_BASELINE.md` | Nomes papel + MAF approved + rationale | Feito |
| `KB/AIOPS_TEAM_ACTION_PLAN.md` | Premissas, Fase 6, núcleo aprovado | Feito |
| `KB/hermes/MEMORY.md` | Fatos canônicos atualizados | Feito |
| `KB/AGENT_TRANSITION_BOARD.md` | Este board | Feito |

---

## Sequência de execução (Fases do ACTION_PLAN)

1. **Fase 1** — Contrato operacional por papel
2. **Fase 2** — ACP ampliado como mesh governado
3. **Fase 3** — Materializar os especialistas (workers)
4. **Fase 4** — Integrar OpenCode como executor
5. **Fase 5** — Observabilidade e governança
6. **Fase 6** — Adoção Microsoft Agent Framework

---

## Bloqueios abertos

| Bloqueio | Impacto | Ação necessária |
|---|---|---|
| ST-S2-05: porta 11434 do Ollama bloqueada para WSL2 | Builder não consegue usar Ollama local | Usuário libera firewall/Norton |
| ST-S2-04: credenciais SonarCloud pendentes | Análise de código bloqueada | PO fornece credenciais |
| Sprint S3 aberta, mas backlog ainda não priorizado para execução | Materialização multiagente ainda não iniciada | PO confirma ordem de ataque da S3 |
| Bootstrap Windows ainda não endurecido para o serviço systemd do gateway | Risco de drift após reboot | Revisar launcher e rotina operacional do Hermes |

---

## Pontos de validação

| Ponto | Critério | Responsável |
|---|---|---|
| P1 | Todos os nomes de papel estão refletidos na KB canônica | Cindy |
| P2 | MAF aparece como plataforma approved (não "futuro") nos docs | Cindy |
| P3 | `KB/AGENT_TRANSITION_BOARD.md` criado e acessível | Cindy |
| P4 | Backlog da S3 priorizado pelo PO antes de iniciar execução | PO |

---

## Referências

- Baseline: `KB/AIOPS_TEAM_BASELINE.md`
- Plano: `KB/AIOPS_TEAM_ACTION_PLAN.md`
- Memória: `KB/hermes/MEMORY.md`
- Tracking: `Dev_Tracking.md`, `Dev_Tracking_S3.md`

---

*Board criado em 2026-04-14. Atualizar conforme decisões forem tomadas.*
