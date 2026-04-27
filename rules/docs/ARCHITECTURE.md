# ARCHITECTURE

## Proposito

Descrever a arquitetura operacional da Cindy como base DOC2.5 para Cline, Codex e Antigravity.

## Momento atual

- Data de referencia: `2026-04-27`
- Sprint ativa: `S4` mantida aberta
- Time AIOps canonico: `Cindy`, `AICoders`, `Escriba`, `Gateway`, `QA`
- `AICoders` usa `OpenCode` com subagentes independentes
- `Gateway` faz o gate tecnico com `Playwright`, `SonarScanner CLI` e seguranca
- `QA` faz validacao funcional e aceite final
- Cindy consolida, roteia e atua como Scrum Master operacional

## Visao geral

A Cindy e organizada em camadas:

- governanca DOC2.5
- runtimes de skills
- workflows operacionais
- documentacao canonica
- tracking e evidencias

Ela funciona como base portavel. O workspace base usa `rules/docs/`; projetos derivados materializam a mesma estrutura em `docs/`.

## Camadas principais

### 1. Governanca

- `rules/WORKSPACE_RULES.md`
- `Cindy_Contract.md`
- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S4.md`
- `tests/bugs_log.md`

A regra local prevalece sobre resumos e sobre qualquer interpretacao informal.

### 2. Time AIOps

- `Cindy`: coordenacao, routing, consolidacao e escalada ao PO
- `AICoders`: implementacao, refatoracao, debug e automacao
- `Escriba`: docs, contratos, KB e runbooks
- `Gateway`: gate tecnico, qualidade e seguranca
- `QA`: validacao e aceite final

### 3. Execucao tecnica

- `OpenCode` e o executor tecnico dos subagentes de `AICoders`
- subagentes podem chegar a mesma decisao por caminhos diferentes
- `Gateway` abre bug quando encontra erro e devolve a correcao ao time de desenvolvimento
- `QA` valida o resultado final antes do aceite

### 4. Workflows

- init
- docs
- dev
- validate
- report

### 5. Documentacao

- `README.md`
- `rules/docs/SETUP.md`
- `rules/docs/ARCHITECTURE.md`
- `rules/docs/DEVELOPMENT.md`
- `rules/docs/OPERATIONS.md`
- `KB/`

## Fluxo arquitetural principal

1. identificar o orchestrator ativo
2. carregar regras globais e locais
3. localizar a sprint ativa
4. consultar skills e workflows
5. propor plano e aguardar aprovacao quando necessario
6. executar o minimo necessario
7. registrar tracking, bugs, testes e `Timestamp UTC`
8. validar com `Gateway` e `QA`
9. consolidar com Cindy e reportar ao PO

## Fronteiras da arquitetura

- nao importar estruturas paralelas de outros projetos
- nao substituir os docs canonicos por arquivos soltos
- nao introduzir workflows sem rastreabilidade
- nao finalizar sprint sem ordem explicita do PO
- nao alegar conformidade sem preflight e evidencia minima

## Relacao com outros artefatos

- `rules/WORKSPACE_RULES.md`: precedencia operacional obrigatoria
- `Cindy_Contract.md`: contrato canonico de descoberta
- `rules/docs/DEVELOPMENT.md`: fluxo de mudanca
- `rules/docs/OPERATIONS.md`: validacao e manutencao
- `Dev_Tracking_S4.md`: sprint ativa
- `tests/bugs_log.md`: evidencias tecnicas

