# WORKSPACE_RULES.md - Regras Locais do Projeto

## Identificacao do Projeto

- Nome: Cindy
- Objetivo: Base portatil para agentes com governanca DOC2.5
- Papel atual: fonte canonica local de regras, contrato, templates, tracking e skills para runtimes locais
- Fonte ativa no Cindy Agent: `rules/WORKSPACE_RULES.md` do workspace ativo da Cindy Agent

## Natureza Operacional

Este arquivo e a fonte operacional obrigatoria da Cindy.

- governa leitura, execucao, alteracao, rastreabilidade e validacao no repositorio
- prevalece sobre resumos de `README.md`, `Cindy_Contract.md` e outros materiais explicativos
- nao depende de scripts locais para ser valido ou executavel como regra

## Regras de Governanca

### Regra 1: Uma Sprint Ativa por Vez

Apenas um arquivo `Dev_Tracking_SX.md` pode estar ativo na raiz do projeto. Quando a sprint terminar, o arquivo deve ser movido para `Sprint/`.

### Regra 2: Estrutura Canonica da Cindy

A Cindy deve preservar, no minimo, a seguinte estrutura operacional:

```text
Cindy/
├── README.md
├── Cindy_Contract.md
├── Dev_Tracking.md
├── Dev_Tracking_SX.md
├── rules/
│   └── WORKSPACE_RULES.md
│   └── docs/
│       ├── SETUP.md
│       ├── ARCHITECTURE.md
│       ├── DEVELOPMENT.md
│       └── OPERATIONS.md
├── tests/
│   └── bugs_log.md
├── Templates/
├── .brand/
├── .agents/
├── .cline/
├── .clinerules/
├── .codex/
└── Sprint/
```

Artefatos auxiliares podem existir, mas nao podem substituir os caminhos canonicos acima.

Nesta base da Cindy Agent, os 4 docs canonicos vivem em `rules/docs/`. Em projetos derivados, a mesma sequencia pode ser materializada em `docs/`.

### Regra 3: Ordem de Precedencia Operacional

Quando houver duvida ou conflito, a ordem de precedencia e:

1. `rules/WORKSPACE_RULES.md`
2. regras do runtime ativo:
   - `AGENTS.md`, `SOUL.md` e `KB/Modo Absoluto.md` para Cindy Agent
   - `.agents/rules` para Antigravity
   - `.codex/rules` para Codex
   - `.clinerules/WORKSPACE_RULES_GLOBAL.md` para Cline
3. `Cindy_Contract.md`
4. `README.md`
5. `Dev_Tracking.md`, `Dev_Tracking_SX.md` e docs canonicos

Nenhum artefato pode relativizar esta regra local.

### Regra 4: Ordem Canonica dos 4 Docs

Sequencia obrigatoria da documentacao canonica:

1. `rules/docs/SETUP.md`
2. `rules/docs/ARCHITECTURE.md`
3. `rules/docs/DEVELOPMENT.md`
4. `rules/docs/OPERATIONS.md`

`docs/README.md` e `docs/INDEX.md` nao fazem parte do modelo canonico DOC2.5.

Em projetos derivados, a mesma ordem pode existir em `docs/` sem alterar a sequencia canonica.

### Regra 5: Modelo de Tracking

- `Dev_Tracking.md` e o indice mestre de sprints
- `Dev_Tracking_SX.md` e o tracking detalhado da sprint ativa
- `Sprint/` recebe apenas sprints encerradas
- `README.md`, `Dev_Tracking.md`, `Dev_Tracking_SX.md` e `tests/bugs_log.md` devem permanecer coerentes entre si

### Regra 6: Backlog e Decisoes da Sprint

O backlog da sprint ativa deve usar tabela simples:

```text
| Status | Estoria |
|---|---|
| To-Do | ST-SX-01 - descricao |
| Done | ST-SX-02 - descricao |
```

Estados permitidos:

- `To-Do`
- `Doing`
- `Done`
- `Accepted`
- `Pending-SX`

Decisoes devem ser registradas no formato:

```text
[D-SX-YY] - descricao da decisao
```

### Regra 7: Timestamp UTC

Todo tracking deve conter a secao `Timestamp UTC` em tabela com 4 colunas:

```text
Event | Start | Finish | Status
```

Formato canonico do carimbo (ISO 8601, 24h, UTC):

- `YYYY-MM-DDTHH:MM:SS-ST` para inicio
- `YYYY-MM-DDTHH:MM:SS-FN` para fim

Exemplo:

```text
ST-S1-01 | 2026-03-15T19:36:48-ST | 2026-03-15T19:42:00-FN | Done
D-S1-01  | 2026-03-15T19:42:00-ST | 2026-03-15T19:43:00-FN | Logged
```

No `Dev_Tracking.md`, a coluna `Finish` da sprint ativa representa apenas o ultimo carimbo de reconciliacao do indice. Ela nao encerra a sprint.

### Regra 8: Leitura Segura e Automatica

Comandos de leitura local sao seguros e podem ser executados automaticamente:

- `git status`
- `git log`
- `git show`
- `git branch`
- `ls`
- `find`
- `rg`
- leitura de arquivos

Leitura automatica nao autoriza alteracao.

### Regra 9: Alteracoes Exigem Gate

Comandos de alteracao exigem aprovacao previa do PO quando extrapolarem leitura ou o escopo explicitamente autorizado:

- `git add`
- `git commit`
- `git push`
- criacao ou remocao de arquivos
- instalacao de dependencias
- alteracoes estruturais fora do objetivo aprovado

### Regra 10: Politica de Commit e Remote

Commit e push so podem ocorrer com ordem expressa do PO.

- nunca sugerir commit espontaneamente
- nunca executar `git commit` ou `git push` sem autorizacao textual explicita
- operar em `single remote` por padrao
- usar `dual remote` apenas quando o PO determinar explicitamente
- se nao houver remote identificavel, interromper antes de qualquer commit ou push

### Regra 11: Evidencia, Inferencia e Verdade Canonica

- fatos observaveis devem ser tratados como evidencia
- inferencias devem permanecer rotuladas como inferencia
- confirmacoes do PO prevalecem sobre inferencias
- a verdade canonica so deve ser promovida com base documental suficiente ou confirmacao explicita do PO
- unknowns devem permanecer explicitos

### Regra 12: README Root e Rodape da Cindy

O `README.md` da raiz deve:

- ser o entry point oficial do repositorio
- refletir a sprint ativa e o escopo atual
- terminar com o bloco canonico exato definido em `Templates/README.md`, sem variacoes de titulo, texto, `alt` ou largura da imagem
- exibir a imagem `.brand/Cindy.jpg`
- usar a assinatura curta da Cindy, sem acoplamento a texto legado sobre `.agents/`

Assinatura curta canonica:

`Este repositorio e orquestrado pela Cindy sob a doutrina DOC2.5.`

Bloco canonico obrigatorio:

```md
## Cindy — Orquestradora (Context Router)

A Cindy é o agente principal do projeto. Em cada run, ela identifica o orchestrator ativo (Cline/Codex/Antigravity), a superfície de execução (VSCode/CLI) e o workspace root; em seguida, descobre e seleciona as skills/workflows disponíveis no contexto atual, respeitando os gates DOC2.5 (plano aprovado antes de execução; commit/push apenas sob ordem explícita do PO).

<p align="center">
  <img src=".brand/Cindy.jpg" alt="Cindy — Orquestradora" width="220" />
</p>
```

### Regra 13: Arquivos e Estruturas Proibidas

Nao devem existir como parte do modelo canonico:

- `docs/README.md`
- `docs/INDEX.md`
- `ARCHITECTURE_AND_LOGIC.md`
- `DEPLOYMENT.md`
- arquivos de pack/bootstrap em `Templates/` que nao sejam templates canonicamente necessarios
- estruturas paralelas que dupliquem `README.md`, tracking ou docs canonicos

### Regra 14: Projetos Derivados Devem Adaptar Identidade

Ao derivar um projeto a partir da Cindy:

- o nome do projeto deve refletir o repositorio de destino
- referencias a `Cindy` so podem permanecer quando falarem do orquestrador, do contrato ou do rodape oficial
- placeholders e secoes editoriais nao podem permanecer como estado final
- o projeto derivado nao pode se declarar como se fosse a propria Cindy

### Regra 15: Gate Manual de Conformidade DOC2.5

Antes de alegar conformidade, concluir fase ou reportar "feito", o runtime deve:

1. reler `rules/WORKSPACE_RULES.md`
2. identificar a sprint ativa real na raiz
3. validar presenca de `README.md`, `Dev_Tracking.md`, `Dev_Tracking_SX.md` ativo e `tests/bugs_log.md`
4. validar presenca exata dos 4 docs canonicos em `rules/docs/` nesta base
5. confirmar ausencia de `docs/README.md` e `docs/INDEX.md`
6. validar coerencia cruzada entre `README.md`, `Dev_Tracking.md`, `Dev_Tracking_SX.md` e `tests/bugs_log.md`
7. confirmar que somente o PO pode encerrar sprint
8. executar avaliacao interna de qualidade `0-100`
9. se a nota for menor que `80`, reportar gaps objetivos e nao declarar conclusao satisfatoria

Em projetos derivados, a validacao dos 4 docs canonicos deve apontar para `docs/` quando esta for a materializacao escolhida.

Mensagem de referencia:

`DOC2.5 CHECK: sprint ativa identificada, artefatos canonicos verificados, gate do PO obrigatorio, validacao cruzada executada antes da conclusao.`

### Regra 16: Evidencia Minima para Mudanca Estrutural

Mudanca estrutural exige:

- ao menos um registro de validacao em `tests/bugs_log.md`
- resumo coerente em `Dev_Tracking_SX.md`
- `Timestamp UTC` correspondente aos eventos executados
- passe editorial minimo antes do relatorio final

Linguagem de encerramento prematuro deve ser bloqueada ou sinalizada:

- `concluded`
- `sprint concluded`
- `closed`
- `finalizada`
- `encerrada`
- `final state`

### Regra 17: Modelo de Skills e Runtimes

- `.agents/skills/` e a canonical authoring source of truth das skills comuns
- `.cline/skills/` e `.codex/skills/` sao runtimes counterparts
- `Cindy_Contract.md` orienta descoberta e despacho, mas nao substitui a regra local
- nao criar logica paralela de governanca fora do modelo canonico

### Regra 18: Templates Canonicos

`Templates/` deve conter apenas artefatos de geracao canonica do projeto:

- `README.md`
- `SETUP.md`
- `ARCHITECTURE.md`
- `DEVELOPMENT.md`
- `OPERATIONS.md`
- `Dev_Tracking.md`
- `Dev_Tracking_SX.md`
- `bugs_log.md`

Templates devem gerar documentos finais, nao descrever packs, bootstraps ou fluxos extintos.

Para bootstrap de projeto novo, usar a skill `project-bootstrap` que orienta o preenchimento correto dos templates.

### Regra 19: Seguranca e Credenciais

- nunca versionar credenciais
- nunca documentar segredos
- mascarar valores sensiveis
- nao presumir `.env`, `.scr/.env` ou qualquer storage local de secrets se o artefato nao existir

### Regra 20: Camadas Externas Sao Opcionais e Desligadas por Padrao

Qualquer camada externa de gestao, triagem ou integracao:

- e opcional
- nao faz parte do baseline canonico da Cindy
- nao pode sobrepor `Dev_Tracking_SX.md` como source of truth do "feito"
- so pode ser ativada mediante comando explicito do PO e registro em tracking

### Regra 21: Classificacao do Workspace Antes da Leitura Ampla

Antes de abrir artefatos canonicos ou propor escrita, o runtime deve classificar o workspace em um dos modos abaixo:

- `repo materializado`: raiz com `README.md`, `Dev_Tracking.md`, `Dev_Tracking_SX.md` ativo, `docs/` e `tests/bugs_log.md`
- `baseline de geracao`: ausencia dos artefatos canonicos finais na raiz, mas presenca de `Templates/`, `rules/WORKSPACE_RULES.md` e `Cindy_Contract.md`

No modo `baseline de geracao`, a leitura minima obrigatoria e:

1. `rules/WORKSPACE_RULES.md`
2. regra global do runtime ativo
3. `Cindy_Contract.md`
4. `Templates/README.md`
5. apenas os templates adicionais estritamente necessarios ao pedido

No modo `baseline de geracao`:

- nao presumir sprint ativa materializada
- nao presumir `docs/` final ja preenchido
- nao presumir stack, arquitetura, hardware, protocolo, integracao ou automacao
- temas amplos como `IoT`, `web app` ou `automacao` devem permanecer no nivel mais simples possivel ate confirmacao do PO
- para pedido de projeto novo ou bootstrap, ativar a skill `project-bootstrap`

### Regra 22: Explicacao Antes da Primeira Escrita

Em pedido de bootstrap, projeto novo ou mudanca estrutural com escopo amplo, o runtime deve explicar antes da primeira escrita:

- o que pretende criar
- o que ficou indefinido
- o que sera marcado como `Pendente de validacao`

Se o pedido estiver amplo demais para promover detalhes como fato, o runtime deve manter a resposta no nivel minimo util e bloquear invencoes tecnicas.

### Regra 23: Gate de Qualidade e Budget Contextual

Toda execucao de bootstrap, geracao documental, ajuste estrutural ou declaracao de conclusao deve produzir avaliacao interna de qualidade em escala `0-100`.

- qualidade esperada minima para alegar resultado bom: `80`
- abaixo de `80`, o runtime nao deve reportar conclusao como satisfatoria; deve apontar gaps objetivos
- a nota deve refletir: leitura correta, aderencia aos templates, coerencia cruzada, rastreabilidade, controle de inferencias e ausencia de invencao
- budget contextual alvo: ate `30%`
- se o runtime projetar passar de `30%`, deve resumir o contexto, reduzir leitura e evitar expandir escopo
- evidencia prevalece sobre inferencia; unknowns permanecem explicitos
- e proibido inventar fatos, simular validacoes ou omitir incerteza relevante

### Regra 24: Plataforma e Exemplos de Comando

Os exemplos de comando presentes em documentos finais devem refletir a plataforma realmente em uso no projeto.

- quando o baseline atual for Windows-only, priorizar exemplos em PowerShell
- nao misturar path de Windows com comandos tipicos de Linux ou Bash em documentos finais
- evitar `ls`, `cat`, `pwd` e similares quando a operacao esperada do projeto for PowerShell
- usar exemplos neutros apenas quando a plataforma ainda nao estiver validada

### Regra 25: Template e Concisao

Templates canonicos devem orientar a estrutura final, mas nao devem induzir copia mecanica de boilerplate.

- preferir documentos finais curtos, objetivos e coerentes
- remover ou condensar secoes que nao agreguem informacao real
- quando o dado nao existir, registrar apenas o minimo necessario como `Pendente de validacao`
- evitar repetir as mesmas regras em `README.md`, docs canonicos, tracking e `tests/bugs_log.md`
- em tema amplo ou escopo vago, a ausencia de detalhe e melhor que a invencao

### Regra 26: Integracao GSD (Get Shit Done)

- O framework GSD e o sistema operacional oficial de execucao tecnica
- A Cindy deve invocar workflows GSD (`.agents/get-shit-done/workflows/` ou `workflows/get-shit-done/workflows/` no workspace ativo da Cindy Agent) para planejar, pesquisar e executar fases
- A pasta `.planning/` e o orgao de memoria da IA e deve ser mantida integra
- Sincronizacao: O GSD planeja e executa; a Cindy valida e documenta no `Dev_Tracking_SX.md`
- Comandos `/gsd:*` sao cidadaos de primeira classe no fluxo operacional

### Regra 27: Equipe Operacional de Agentes

A Cindy orquestra agentes autonomos por funcao. O PO aprova planos e decisoes grandes; os agentes executam com autonomia dentro do plano aprovado.

**Modelo de Operacao:**

```
┌─────────────────────────────────────────────────────────────┐
│                        PO                                    │
│          Aprova planos + decide mudancas grandes             │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌───────────────▼───────────────┐
          │  Cindy                           │
          │  Coordenacao + routing           │
          │  Triagem -> plano -> execucao    │
          └─────────────────────────────────┘
```

**Agentes:**

| Agente | Papel | Escopo |
|---|---|---|
| Cindy | Coordenacao / routing / Scrum Master operacional | Triagem, contexto, plano, despacho, consolidacao |
| AICoders | Codigo / AI / Test / automacao | Implementacao, debug, testes tecnicos, subagentes independentes via OpenCode |
| Escriba | Docs / API | Documentacao canonica, API, Swagger/OpenAPI, KB, runbooks |
| Gateway | Gate tecnico / seguranca | Playwright, SonarScanner, Sec, bloqueio, aprovacao ou devolucao de bugs |
| QA | Validacao funcional / aceite | Regressao, smoke, conformidade funcional e aceite final |
| PO | Aprovacao | Aprova planos, gates, encerramentos, decisoes grandes, commit e push |

**Fluxo Operacional:**

1. PO da direcao geral
2. Cindy classifica o pedido e seleciona agentes/workflows
3. Cindy gera ou consolida plano
4. PO aprova o plano quando houver gate
5. Agentes executam com autonomia dentro do escopo aprovado
6. Gateway verifica qualidade tecnica, Playwright, SonarScanner e seguranca
7. QA verifica funcionalidade, regressao e aceite final
8. Cindy consolida evidencias, pendencias e proximo passo
9. Decisao grande retorna ao PO

**RACI:**

| Atividade | Cindy | AICoders | Escriba | Gateway | QA | PO |
|---|---|---|---|---|---|---|
| Triagem e routing | R | I | I | I | I | A |
| Plano de acao | A | C | C | C | C | A |
| Execucao codigo/AI | C | R | I | C | I | I |
| Teste tecnico | C | R | I | A | C | I |
| Documentacao tecnica/API | C | C | R | I | I | I |
| Validacao DOC2.5/QA | C | I | I | C | R | A |
| Detectar loop/risco | R | C | C | C | C | I |
| Correcao | A | R | C | C | I | I |
| Decisao grande | C | C | C | C | C | A |
| Aprovacao final | R | I | I | C | C | A |

**Gate de iteracao:** limite de 3-5 ciclos. Deteccao por qualquer agente escala para Cindy. Apos limite, escala para PO.

**Criterios de classificacao:**

| Tipo de tarefa | Destino | Suporte |
|---|---|---|
| Codigo, debug, Python, AI | AICoders | Gateway |
| Testes tecnicos e gate | AICoders | Gateway |
| Docs, Swagger, API | Escriba | Gateway |
| Validacao, QA, auditoria | QA | Cindy |
| Routing, contexto, consolidacao | Cindy | Gateway |
| Nao classificado | Cindy | AICoders |

**Gate de classificação:** `.agents/skills/dual-model-orchestrator/scripts/dual_model_gate.py`

### Regra 28: ACP - Agent Communication Protocol

O protocolo oficial de comunicacao entre agentes da Cindy Agent e o ACP via Redis.

**Fontes canonicas:** `KB/aiops/ACP_PROTO.md` e `KB/aiops/ACP_REDIS_INVESTIGATION.md`

**Backbone:**

- Redis local em `localhost:6379`
- namespace exclusivo `acp:*`
- Pub/Sub para eventos efemeros
- Streams para tarefas persistidas, ordenadas, idempotentes e com ack

**Canais e streams:**

| Recurso | Uso |
|---|---|
| `acp:messages` | broadcast Pub/Sub |
| `acp:stream:{agent_id}` | fila persistida por agente |
| consumer group `agents` | consumo sem double-delivery |

**Formato obrigatorio:**

- mensagens entre agentes devem ser JSON estruturado
- agentes nao devem usar linguagem humana entre si
- tipos permitidos: `TASK`, `COMMAND`, `EVENT`, `RESPONSE`, `PLAN`
- Cindy centraliza coordenacao e consolidacao
- PO so e consultado para planos, gates e decisoes grandes

**Scripts operacionais:**

- `.agents/scripts/acp_redis.py`
- `.agents/scripts/test_acp_multi_agent.py`
- `.agents/scripts/acp/acp_mesh.py`
- `.agents/scripts/acp/acp_observability.py`

**Validacao minima:**

Antes de declarar ACP operacional, validar:

1. `redis-cli ping` retorna `PONG`
2. `python3 .agents/scripts/test_acp_multi_agent.py` conclui sem erro
3. Pub/Sub recebe mensagem real em `acp:messages`
4. Stream consome e confirma mensagem em `acp:stream:{agent_id}`
5. ACPMesh cria, consome, executa e conclui task lifecycle

### Regra 29: Gates Formais do PO

As fronteiras formais do PO seguem a politica `KB/aiops/PO_GATES_POLICY.md`.

**Gates obrigatorios:**

| Gate | Momento | Responsabilidade do PO |
|---|---|---|
| `G1` | Sprint | Aprovar escopo macro, objetivo e backlog |
| `G2` | Plano | Aprovar planejamento consolidado antes da execucao |
| `G3` | Decisao | Aprovar mudanca relevante de escopo, arquitetura, custo ou risco |
| `G4` | Aceite Final | Validar testes/HANDOFF e autorizar commit/push e fechamento |

**Regra operacional:**

- qualquer escalação ao PO deve indicar o gate acionado quando houver
- tasks em `escalated` devem registrar `escalation_gate` e `escalation_reason`
- o log do mesh deve manter rastreabilidade da barreira que travou a etapa
- o PO atua por excecao e aprovacao de fronteiras, nao por microgestao

## Relação com Regras Globais

Este arquivo complementa as regras globais do workspace em `.clinerules/WORKSPACE_RULES_GLOBAL.md`. Em caso de conflito, estas regras locais prevalecem para o projeto Cindy.

## Referencias

- `.clinerules/WORKSPACE_RULES_GLOBAL.md`
- `.agents/rules`
- `.codex/rules`
- `Cindy_Contract.md`
- `README.md`
- `Dev_Tracking.md`
- `Dev_Tracking_SX.md`
