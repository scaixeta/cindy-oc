# OPERATIONS

## Proposito

Orientar como operar, validar e manter a Cindy.

## Momento atual

- Data de referencia: `2026-04-27`
- Sprint S4 permanece aberta
- Time AIOps canonico: `Cindy`, `AICoders`, `Escriba`, `Gateway`, `QA`
- `OpenCode` e o executor tecnico dos subagentes
- `Playwright` e `SonarScanner CLI` estao funcionais no WSL
- `Gateway` e `QA` formam o ciclo de validacao antes do aceite
- O servidor local do SonarQube ainda depende de um daemon Docker disponivel no host

## Natureza operacional

A Cindy e um repositorio-base de governanca, skills e workflows. Ela opera principalmente em ambiente local para:

- leitura de contexto
- execucao de skills
- validacao estrutural DOC2.5
- manutencao de tracking, bugs e testes
- higiene de contexto para reduzir desperdicio de tokens

## Rotinas operacionais

### 0. Gate de etapa

Antes de agir, a Cindy deve declarar em qual etapa esta operando:

- `analysis`
- `planning`
- `execution`
- `validation`
- `report`

Sem essa declaracao, a Cindy deve permanecer em leitura e sintese.

### 1. Validacao estrutural

Conferencias minimas:

- `README.md` presente e coerente com a sprint ativa
- `rules/docs/` com os 4 arquivos canonicos nesta base
- `rules/WORKSPACE_RULES.md` presente
- `Dev_Tracking.md` e `Dev_Tracking_S4.md` coerentes
- `tests/bugs_log.md` atualizado
- gate manual `doc25-preflight` executado antes de alegar conformidade

### 2. Audit DOC2.5

Conduzir auditoria manual com foco em:

- estrutura canonica obrigatoria
- coerencia entre `README.md`, tracking, regras e `tests/bugs_log.md`
- ausencia de artefatos legados fora do baseline atual
- consistencia de naming, idioma e `Timestamp UTC`

### 3. Verificacao de ferramentas

O ciclo tecnico atual deve ser funcional:

- `OpenCode` para execucao especializada
- `Playwright` para navegacao e smoke/E2E
- `SonarScanner CLI` para analise tecnica
- `Java 17` para suporte ao scanner

Se o daemon Docker do host estiver indisponivel, o scanner continua valido, mas o servidor SonarQube local nao deve ser declarado operacional.

### 4. Verificacao de tracking

- apenas um `Dev_Tracking_SX.md` ativo na raiz
- `Sprint/` so recebe sprints arquivadas
- `Timestamp UTC` deve refletir os eventos relevantes do projeto
- fechamento de sprint e proibido sem ordem explicita do PO

### 5. Seguranca operacional

- nunca versionar credenciais
- nunca documentar segredos
- mascarar valores sensiveis
- respeitar gate do PO para alteracoes e commits

## Resposta a falhas

1. confirmar contexto em `Dev_Tracking_S4.md`
2. interromper o fluxo que falhou
3. registrar bug ou teste em `tests/bugs_log.md`
4. corrigir o artefato minimo necessario
5. atualizar `Timestamp UTC`
6. revalidar docs, skills ou workflows afetados
7. executar passe editorial minimo e autoauditoria antes do relatorio final

Falha operacional inclui:

- comando invalido
- repeticao de erro equivalente
- loop ate interrupcao manual

## Disciplina de verdade canonica

- arquitetura sugerida permanece hipotese ate evidencia ou aprovacao do PO
- stack tecnica permanece pendente ate definicao explicita
- integracoes externas nao devem ser tratadas como reais sem prova documental
- templates sao fonte de geracao, nao autorizacao para bootstrap automatico

## Referencias

- `rules/docs/SETUP.md`
- `rules/docs/ARCHITECTURE.md`
- `rules/docs/DEVELOPMENT.md`
- `Dev_Tracking_S4.md`
- `tests/bugs_log.md`
