# Cindy Agent

Repositorio-base local da Cindy no workspace `C:\CindyAgent`. Este repo guarda a governanca DOC2.5, a documentacao canonica, a persona operacional da Cindy e os artefatos de referencia do ecossistema.

## Estado atual

- Data de referencia: `2026-04-27`
- Sprint ativa: `S4` mantida aberta
- Runtime operacional atual: `Cindy Agent 2026.4.14` no WSL2 Ubuntu, com gateway LAN e Telegram habilitados
- Time AIOps canonico: `Cindy`, `AICoders`, `Escriba`, `Gateway`, `QA`
- Cindy atua como orquestradora, consolidacao e Scrum Master operacional
- `AICoders` executa via `OpenCode` com subagentes independentes
- `Gateway` valida codigo, qualidade e seguranca com `Playwright`, `SonarScanner CLI` e `Sec`
- `QA` faz validacao funcional e aceite final
- `Playwright 1.59.1` instalado e browsers baixados no WSL
- `SonarScanner CLI 8.0.1.6346` instalado e funcional
- `OpenJDK 17.0.18` instalado
- O servidor local do SonarQube ainda depende de daemon Docker disponivel no host
- Canal operacional principal: Telegram
- Discord cockpit validado e em uso como superficie de gestao
- `.scr/.env` continua fora de versionamento
- Remote oficial: `https://github.com/scaixeta/CindyAgent`
- Branch principal de trabalho: `main`

## Sprint S4

| Item | Estado |
|---|---|
| Sprint | `S4` |
| Status | Ativa e mantida aberta |
| Foco | Cindy Agent operacional, Discord cockpit e consolidacao da documentacao do time AIOps |
| Base operacional validada | Cindy Agent + Telegram + gateway LAN + tracking DOC2.5 |
| Ferramentas de gate | `OpenCode`, `Playwright`, `SonarScanner CLI`, `OpenJDK 17` |

## Visao operacional AIOps

A Cindy opera como plataforma AIOps sob DOC2.5.

### Papel de cada funcao
- **Cindy:** coordena, roteia, consolida, remove bloqueios e age como Scrum Master operacional.
- **AICoders:** implementa, refatora, depura e automatiza com `OpenCode` e subagentes independentes.
- **Escriba:** documentacao tecnica, contratos, KB e runbooks.
- **Gateway:** gate tecnico antes da subida, incluindo qualidade, testes, `Playwright`, `SonarScanner CLI` e seguranca.
- **QA:** validacao funcional, regressao, smoke e aceite final.

### Fluxo operacional atual
- PO define direcao e aprova gates maiores.
- Cindy classifica, distribui e consolida.
- AICoders executa com subagentes autonomos.
- Gateway bloqueia, aprova ou devolve bugs.
- QA confirma comportamento e aceite.
- Cindy fecha a consolidacao e apresenta o resultado ao PO.

## Operacao rapida

### Subir o gateway do runtime

```powershell
# Execute o script de inicializacao do gateway da Cindy Agent no workspace
```

### OpenCode

```bash
./run_opencode.bat "prompt aqui"
```

## Estrutura canonica

No workspace base da Cindy, os docs canonicos vivem em `rules/docs/`. Em projetos derivados, a mesma estrutura aparece em `docs/`.

- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S4.md`
- `Dev_Tracking_S5.md`
- `rules/docs/SETUP.md`
- `rules/docs/ARCHITECTURE.md`
- `rules/docs/DEVELOPMENT.md`
- `rules/docs/OPERATIONS.md`
- `tests/bugs_log.md`
- `rules/WORKSPACE_RULES.md`
- `KB/`

## Leitura recomendada

1. `rules/WORKSPACE_RULES.md`
2. `Cindy_Contract.md`
3. `README.md`
4. `rules/docs/SETUP.md`
5. `rules/docs/ARCHITECTURE.md`
6. `rules/docs/DEVELOPMENT.md`
7. `rules/docs/OPERATIONS.md`
8. `Dev_Tracking.md`
9. `Dev_Tracking_S4.md`
10. `Dev_Tracking_S5.md`
11. `KB/aiops/AIOPS_TEAM_BASELINE.md`
12. `KB/aiops/AIOPS_TEAM_ACTION_PLAN.md`

---

## Cindy - Orquestradora (Context Router)

A Cindy e o agente principal do projeto. Em cada run, ela identifica o orchestrator ativo (Cline/Codex/Antigravity), a superficie de execucao (VSCode/CLI) e o workspace root; em seguida, descobre e seleciona as skills e workflows disponiveis no contexto atual, respeitando os gates DOC2.5.

<p align="center">
  <img src=".brand/Cindy.jpg" alt="Cindy - Orquestradora" width="220" />
</p>
