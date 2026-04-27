# SETUP

## Proposito

Orientar como preparar o workspace da Cindy para o momento atual da operacao.

## Momento atual

- Data de referencia: `2026-04-27`
- Sprint ativa: `S4` mantida aberta
- Time AIOps canonico: `Cindy`, `AICoders`, `Escriba`, `Gateway`, `QA`
- `OpenCode` executa subagentes independentes para `AICoders`
- `Playwright 1.59.1` e `SonarScanner CLI 8.0.1.6346` estao funcionais no WSL
- `OpenJDK 17.0.18` esta instalado
- O servidor local do SonarQube ainda depende do daemon Docker do host
- Cindy atua como orquestradora, consolidadora e Scrum Master operacional

## Requisitos minimos

- Git
- Bash ou PowerShell
- Editor de texto ou IDE
- Node.js 22+ e npm/npx
- Java 17+
- Redis local
- `OpenCode`
- `Playwright`
- `SonarScanner CLI`

## Estrutura canonica

No workspace base da Cindy, os docs canonicos vivem em `rules/docs/`. Em projetos derivados, vivem em `docs/`.

Arquivos esperados:

- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S4.md` ativo
- `tests/bugs_log.md`
- `rules/WORKSPACE_RULES.md`

## Instalação / verificacao rapida

```powershell
git clone https://github.com/scaixeta/CindyAgent
Set-Location CindyAgent
```

Verificacoes uteis:

```bash
git status
node -v
npm -v
playwright --version
playwright install --list
sonar-scanner --version
java -version
```

## Fluxo de leitura

1. `rules/WORKSPACE_RULES.md`
2. `README.md`
3. `Dev_Tracking.md`
4. `Dev_Tracking_S4.md`
5. `tests/bugs_log.md`
6. `rules/docs/SETUP.md`
7. `rules/docs/ARCHITECTURE.md`
8. `rules/docs/DEVELOPMENT.md`
9. `rules/docs/OPERATIONS.md`

## Inicializacao de projetos derivados

Use os templates canônicos quando um projeto novo for derivado da Cindy:

- `README.md` com rodape da Cindy
- `Dev_Tracking.md` e `Dev_Tracking_S0.md` coerentes
- `tests/bugs_log.md` inicial
- `Cindy_Contract.md` adaptado
- `docs/SETUP.md`, `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`, `docs/OPERATIONS.md`
- `rules/WORKSPACE_RULES.md` alinhado ao contexto do projeto derivado
