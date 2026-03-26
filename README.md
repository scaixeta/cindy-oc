# Cindy OC

## Operacao DOC2.5

Workspace derivado da Cindy para desenvolvimento local em `VS Code`, com `Codex` e `Cline` como agentes locais, governado por DOC2.5.

---

## 1. Visao Geral

O `Cindy OC` e o repositorio raiz para:

- governanca, contexto e despacho via Cindy
- desenvolvimento local assistido no `VS Code`
- rastreabilidade de decisoes com timestamps UTC
- gates de validacao DOC2.5

## 2. Estado Atual

- Sprint ativa: `S3`
- Estado: `Planning`
- Escopo: `Fluxo Decisorio DOC2.5 - Workflow de bootstrap, gates de governanca, rastreabilidade`
- Validacao: `Sprint S2 concluida com 4 bugs resolvidos, 6 testes passando`

## 3. Controle de Sprints

| Sprint | Periodo | Estado | Tracking | Observacoes |
| --- | --- | --- | --- | --- |
| `S3` | `2026-03-26` | `Planning` | `Dev_Tracking_S3.md` | Fluxo Decisorio DOC2.5 |
| `S2` | `2026-03-24` | `Accepted` | `Sprint/Dev_Tracking_S2.md` | N8N, workflow MVP, skills |
| `S1` | `2026-03-23` | `Accepted` | `Sprint/Dev_Tracking_S1.md` | Telegram MVP |
| `S0` | `2026-03-20` | `Accepted` | `Sprint/Dev_Tracking_S0.md` | Bootstrap |

## 4. Pendencias Ativas (S3)

- [ ] `S3-01`: Analisar fluxo decisorio atual da Cindy
- [ ] `S3-02`: Criar workflow de bootstrap DOC2.5
- [ ] `S3-03`: Implementar gate de governanca
- [ ] `S3-04`: Documentar fluxo decisorio em KB
- [ ] `S3-05`: Validar com caso real

## 5. Skills Disponiveis (Multi-Runtime)

| Skill | .cline | .agents | .codex | c:\cindy |
|-------|--------|---------|--------|----------|
| n8n-workflow-patterns | ✅ | ✅ | ✅ | ✅ |
| n8n-workflow-deployment | ✅ | ✅ | ✅ | ✅ |
| n8n-node-configuration | ✅ | ✅ | ✅ | ✅ |

## 6. Artefatos Canonicos

`README.md` | `Cindy_Contract.md` | `Dev_Tracking.md` | `Dev_Tracking_S3.md` | `tests/bugs_log.md`

---

## Cindy — Orquestradora (Context Router)

A Cindy identifica o orchestrator ativo (Cline/Codex), a superficie de execucao (VSCode/CLI) e o workspace root; em seguida, descobre e seleciona skills/workflows, respeitando gates DOC2.5.

<p align="center">
  <img src=".brand/Cindy.jpg" alt="Cindy" width="220" />
</p>
