# DEVELOPMENT

## Proposito

Descrever como o desenvolvimento deve ser conduzido na Cindy seguindo DOC2.5.

## Principios

- uma sprint ativa por vez
- a Sprint S4 permanece aberta ate ordem explicita do PO
- tracking obrigatorio
- mudanca minima necessaria
- governanca antes de execucao
- sem estruturas paralelas fora do modelo canonico
- `rules/WORKSPACE_RULES.md` e fonte operacional obrigatoria
- preflight DOC2.5 e validacao de contexto antes de alegar conformidade
- `OpenCode` e o executor tecnico de `AICoders`
- subagentes podem divergir e convergir para a mesma decisao

## Time operacional

- `Cindy`: coordena, roteia, consolida e atua como Scrum Master operacional
- `AICoders`: implementa, corrige e automatiza
- `Escriba`: documenta e integra
- `Gateway`: valida qualidade e seguranca
- `QA`: valida comportamento e aceite final
- `PO`: aprova gates grandes e encerra sprint

## Fluxo geral

### 1. Ler contexto

- `README.md`
- `rules/WORKSPACE_RULES.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S4.md`
- `tests/bugs_log.md`
- `rules/docs/SETUP.md`
- `rules/docs/ARCHITECTURE.md`
- `rules/docs/OPERATIONS.md`
- gate `doc25-context-check`

### 2. Planejar antes de editar

- resumir entendimento
- propor plano claro
- obter aprovacao explicita do PO quando houver alteracao ou gate

### 3. Executar

- aplicar a menor mudanca possivel
- atualizar backlog e decisoes quando necessario
- registrar evidencias e testes em `tests/bugs_log.md`
- evitar linguagem de encerramento prematuro sem ordem do PO

### 4. Validar

- `Gateway` valida qualidade tecnica, Playwright, SonarScanner e seguranca
- `QA` valida funcionalidade, regressao e aceite final
- falhas devem voltar ao time de desenvolvimento com evidencia objetiva

### 5. Atualizar rastreabilidade

- refletir o trabalho em `Dev_Tracking_S4.md`
- atualizar `Dev_Tracking.md` se o indice mudar
- atualizar docs canonicos quando a realidade da base mudar
- manter coerencia entre `README.md`, `Dev_Tracking.md`, `Dev_Tracking_S4.md` e `tests/bugs_log.md`

### 6. Preflight e autoauditoria

- executar `doc25-preflight` antes de reportar conclusao
- validar `Timestamp UTC` como gate bloqueante
- incluir autoauditoria final: o que mudou, coerencia dos artefatos e pendencias de governanca

## Politica de leitura vs alteracao

### Leitura permitida

- `git status`
- `git log`
- `git show`
- `git branch`
- leitura de arquivos

### Alteracao exige gate do PO

- `git add`
- `git commit`
- `git push`
- criacao/remocao de arquivos
- instalacao de dependencias
- alteracoes estruturais fora do objetivo aprovado

## Skills e workflows

- skills canonicas devem estar coerentes entre `.agents/`, `.cline/` e `.codex/`
- workflows DOC2.5 ficam em `rules/docs/` e nos runtimes espelho quando aplicavel
- o uso de skills deve preceder improviso
- processos de IA/ML exigem orquestracao via `crisp-dm-workflow-doc25` quando aplicavel

## Tests e bugs

- `tests/bugs_log.md` e o log centralizado
- `Dev_Tracking_S4.md` recebe resumo e referencias cruzadas
- `Timestamp UTC` deve refletir eventos relevantes ja executados
- validacao cruzada curta deve substituir reprocessamento completo quando nao houver mudancas em artefatos estaveis

## Referencias

- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_S4.md`
- `tests/bugs_log.md`
- `rules/WORKSPACE_RULES.md`
